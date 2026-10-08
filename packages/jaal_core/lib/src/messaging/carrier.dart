import 'dart:async';

import 'package:drift/drift.dart';
import 'package:logging/logging.dart';

import '../db/database.dart';
import '../identity/identity.dart';
import '../util/canonical_json.dart';
import '../util/clock.dart';
import 'envelope.dart';

/// Counter keys in the `stats` table.
abstract final class StatKey {
  /// Envelopes we carried for strangers that were later delivered.
  static const courierDelivered = 'courier.delivered';
  static const courierCarried = 'courier.carried';
}

sealed class CarrierChange {
  const CarrierChange();
}

class EnvelopeStored extends CarrierChange {
  const EnvelopeStored(this.id, this.exp);
  final String id;
  final int exp;
}

class AckLearned extends CarrierChange {
  const AckLearned(this.secret, this.exp);
  final String secret;
  final int exp;
}

class MessageReceived extends CarrierChange {
  const MessageReceived(this.message);
  final OpenedMessage message;
}

/// The store-and-forward layer: seals outgoing DMs, accepts envelopes from
/// peers (opening those addressed to us, carrying the rest), and processes
/// delivery receipts (protocol/SPEC.md §6).
class Carrier {
  Carrier({
    required this.db,
    required this.me,
    required this.clock,
    this.maxCarryBytes = 20 * 1024 * 1024,
    Logger? log,
  }) : _log = log ?? Logger('jaal.carrier');

  final JaalDatabase db;
  final LocalIdentity me;
  final Clock clock;
  final int maxCarryBytes;
  final Logger _log;
  final Mutex _lock = Mutex();
  final _changes = StreamController<CarrierChange>.broadcast(sync: true);

  Stream<CarrierChange> get changes => _changes.stream;

  /// Seals [text] to [to] and queues it for delivery. Requires the
  /// recipient's profile (for their DM key) to be known locally.
  Future<MessageRow> sendDm(RootId to, String text) => _lock.run(() async {
        final profile = await db.profile(to);
        if (profile == null) {
          throw StateError('no profile (DM key) known for $to');
        }
        final now = clock.nowMs();
        final sealed = await Sealer.sealDm(
          sender: me,
          to: to,
          recipientDmKey: profile.dmKey,
          text: text,
          now: now,
        );
        final env = sealed.envelope;
        final msg = MessagesCompanion.insert(
          id: env.id,
          peerRoot: to,
          outgoing: true,
          body: text,
          sentAt: now,
          ackHash: env.ackHash,
        );
        await db.transaction(() async {
          await _insertEnvelope(env, origin: EnvelopeOrigin.sent, hops: 0);
          await db.into(db.messages).insert(msg);
        });
        _changes.add(EnvelopeStored(env.id, env.exp));
        return (await (db.select(db.messages)
                  ..where((m) => m.id.equals(env.id)))
                .getSingle());
      });

  /// True if we already hold (or know the delivery of) envelope [id].
  Future<bool> knows(String id) async => await db.envelope(id) != null;

  /// Handles an envelope received from a peer. Returns true if it was new.
  Future<bool> accept(SealedEnvelope env, {required int hops}) =>
      _lock.run(() async {
        final id = env.id;
        final now = clock.nowMs();
        if (env.exp <= now) return false;
        if (await db.envelope(id) != null) return false;
        final known = await (db.select(db.acks)
              ..where((a) => a.ackHash.equals(env.ackHash)))
            .getSingleOrNull();
        if (known != null) return false; // already delivered elsewhere

        final opened = env.hint == me.dmHint ? await Sealer.open(env, me) : null;
        if (opened != null) {
          await _receive(env, opened, hops);
          return true;
        }

        if (env.sizeBytes > maxCarryBytes) return false;
        await _makeRoom(env.sizeBytes);
        await _insertEnvelope(env, origin: EnvelopeOrigin.carried, hops: hops + 1);
        await db.bumpStat(StatKey.courierCarried);
        _changes.add(EnvelopeStored(id, env.exp));
        return true;
      });

  Future<void> _receive(SealedEnvelope env, OpenedMessage m, int hops) async {
    // Blocked (by me) or banned (by moderators): accept + ack silently so
    // carriers stop holding it, but never show it.
    final blocked = (await db.blockedRoots()).contains(m.from) ||
        (await db.bannedRoots()).contains(m.from);
    await db.transaction(() async {
      await _insertEnvelope(env,
          origin: EnvelopeOrigin.received, hops: hops + 1, acked: true);
      if (!blocked) {
        await db.into(db.messages).insert(
              MessagesCompanion.insert(
                id: env.id,
                peerRoot: m.from,
                outgoing: false,
                body: m.text,
                sentAt: m.sentAt,
                receivedAt: Value(clock.nowMs()),
                ackHash: env.ackHash,
                delivered: const Value(true),
              ),
              mode: InsertMode.insertOrIgnore,
            );
      }
      await db.into(db.acks).insert(
          AcksCompanion.insert(
              ackHash: env.ackHash, secret: m.ackSecret, exp: env.exp),
          mode: InsertMode.insertOrIgnore);
    });
    _log.fine('received DM ${env.id.substring(0, 8)} from ${m.from.substring(0, 6)}');
    if (!blocked) _changes.add(MessageReceived(m));
    _changes.add(AckLearned(m.ackSecret, env.exp));
  }

  /// Handles a revealed ack secret. Returns true if it was new to us.
  Future<bool> acceptAck(String secret, int exp) => _lock.run(() async {
        if (exp <= clock.nowMs()) return false;
        final hash = Sealer.ackHashOf(secret);
        final existing = await (db.select(db.acks)
              ..where((a) => a.ackHash.equals(hash)))
            .getSingleOrNull();
        if (existing != null) return false;
        await db.transaction(() async {
          await db.into(db.acks).insert(
              AcksCompanion.insert(ackHash: hash, secret: secret, exp: exp));
          final envs = await (db.select(db.envelopes)
                ..where((e) => e.ackHash.equals(hash) & e.acked.equals(false)))
              .get();
          for (final e in envs) {
            // Delivered: drop the ciphertext, keep the row for dedupe/clout.
            await (db.update(db.envelopes)..where((x) => x.id.equals(e.id)))
                .write(const EnvelopesCompanion(acked: Value(true), raw: Value('')));
            if (e.origin == EnvelopeOrigin.carried) {
              await db.bumpStat(StatKey.courierDelivered);
            }
          }
          await (db.update(db.messages)
                ..where((m) => m.ackHash.equals(hash) & m.outgoing.equals(true)))
              .write(const MessagesCompanion(delivered: Value(true)));
        });
        _changes.add(AckLearned(secret, exp));
        return true;
      });

  /// Reads a stored envelope for forwarding.
  Future<SealedEnvelope?> read(String id) async {
    final row = await db.envelope(id);
    if (row == null || row.acked || row.raw.isEmpty) return null;
    return SealedEnvelope.fromJson(
        (CanonicalJson.decode(row.raw)! as Map).cast<String, Object?>());
  }

  /// Drops expired envelopes and acks.
  Future<int> sweep() => _lock.run(() async {
        final now = clock.nowMs();
        final a = await (db.delete(db.envelopes)
              ..where((e) => e.exp.isSmallerOrEqualValue(now)))
            .go();
        final b = await (db.delete(db.acks)
              ..where((e) => e.exp.isSmallerOrEqualValue(now)))
            .go();
        return a + b;
      });

  Future<void> _insertEnvelope(SealedEnvelope env,
      {required int origin, required int hops, bool acked = false}) {
    return db.into(db.envelopes).insert(EnvelopesCompanion.insert(
          id: env.id,
          raw: CanonicalJson.encode(env.toJson()),
          hint: env.hint,
          ackHash: env.ackHash,
          exp: env.exp,
          size: env.sizeBytes,
          receivedAt: clock.nowMs(),
          hops: Value(hops),
          origin: origin,
          acked: Value(acked),
        ));
  }

  /// Evicts the oldest carried envelopes until [incoming] bytes fit.
  Future<void> _makeRoom(int incoming) async {
    var used = await db.carriedBytes();
    if (used + incoming <= maxCarryBytes) return;
    final oldest = await (db.select(db.envelopes)
          ..where((e) =>
              e.origin.equals(EnvelopeOrigin.carried) & e.acked.equals(false))
          ..orderBy([(e) => OrderingTerm.asc(e.receivedAt)]))
        .get();
    for (final e in oldest) {
      if (used + incoming <= maxCarryBytes) break;
      await (db.delete(db.envelopes)..where((x) => x.id.equals(e.id))).go();
      used -= e.size;
      _log.fine('evicted carried envelope ${e.id.substring(0, 8)}');
    }
  }

  Future<void> dispose() => _changes.close();
}
