import 'dart:typed_data';

import '../crypto/crypto.dart';
import '../identity/identity.dart';
import '../util/bytes.dart';
import '../util/canonical_json.dart';

/// Default time a carrier keeps an undelivered envelope.
const Duration envelopeTtl = Duration(days: 14);

/// A sealed, store-and-forward message (protocol/SPEC.md §6).
///
/// What a carrier can see: `v`, `kind`, a 2-byte recipient `hint`, the
/// ephemeral key, the ack hash, the expiry and the ciphertext length.
/// Sender identity, recipient identity and content are all inside `ct`.
class SealedEnvelope {
  const SealedEnvelope({
    required this.kind,
    required this.hint,
    required this.epk,
    required this.ackHash,
    required this.exp,
    required this.nonce,
    required this.ct,
    this.v = 1,
  });

  final int v;
  final String kind;
  final String hint;
  final String epk;
  final String ackHash;
  final int exp;
  final String nonce;
  final String ct;

  Map<String, Object?> headerJson() =>
      {'v': v, 'kind': kind, 'hint': hint, 'epk': epk, 'ack': ackHash, 'exp': exp};

  Map<String, Object?> toJson() => {...headerJson(), 'nonce': nonce, 'ct': ct};

  String get id => b64(JaalCrypto.sha256(CanonicalJson.encodeBytes(toJson())));

  int get sizeBytes => CanonicalJson.encodeBytes(toJson()).length;

  static SealedEnvelope fromJson(Map<String, Object?> j) {
    T req<T>(String k) {
      final v = j[k];
      if (v is! T) throw FormatException('envelope.$k missing or wrong type');
      return v;
    }

    return SealedEnvelope(
      v: req<int>('v'),
      kind: req<String>('kind'),
      hint: req<String>('hint'),
      epk: req<String>('epk'),
      ackHash: req<String>('ack'),
      exp: req<int>('exp'),
      nonce: req<String>('nonce'),
      ct: req<String>('ct'),
    );
  }
}

/// Decrypted, verified contents of a DM envelope.
class OpenedMessage {
  const OpenedMessage({
    required this.envelopeId,
    required this.from,
    required this.fromDevice,
    required this.to,
    required this.sentAt,
    required this.text,
    required this.ackSecret,
  });

  final String envelopeId;
  final RootId from;
  final FeedId fromDevice;
  final RootId to;
  final int sentAt;
  final String text;
  final String ackSecret;
}

/// Result of sealing: the envelope to carry plus the ack secret the sender
/// keeps (so it can recognise the delivery receipt).
class SealResult {
  const SealResult(this.envelope, this.ackSecret);
  final SealedEnvelope envelope;
  final String ackSecret;
}

abstract final class Sealer {
  static const _info = 'jaal-seal-v1';

  static String ackHashOf(String ackSecret) =>
      b64(JaalCrypto.sha256(unb64(ackSecret)));

  static Future<Uint8List> _key(
      List<int> shared, List<int> epk, List<int> recipientPk) {
    return JaalCrypto.hkdf(
      ikm: shared,
      salt: concatBytes([epk, recipientPk]),
      info: _info,
    );
  }

  static Future<SealResult> sealDm({
    required LocalIdentity sender,
    required RootId to,
    required String recipientDmKey,
    required String text,
    required int now,
    Duration ttl = envelopeTtl,
  }) async {
    final rpk = unb64(recipientDmKey);
    final eph = await JaalCrypto.newDhKey();
    final ackSecret = b64(randomBytes(32));

    final inner = <String, Object?>{
      'to': to,
      'from': sender.rootId,
      'cert': sender.cert.toJson(),
      'sentAt': now,
      'text': text,
      'ackSecret': ackSecret,
    };
    final sig = await sender.device.sign(concatBytes([
      SigDomain.dm.codeUnits,
      CanonicalJson.encodeBytes(inner),
    ]));
    inner['sig'] = b64(sig);

    final header = {
      'v': 1,
      'kind': 'dm',
      'hint': dmHintOf(rpk),
      'epk': b64(eph.publicKey),
      'ack': ackHashOf(ackSecret),
      'exp': now + ttl.inMilliseconds,
    };
    final key = await _key(await eph.agree(rpk), eph.publicKey, rpk);
    final nonce = randomBytes(JaalCrypto.nonceLength);
    final ct = await JaalCrypto.seal(
      key: key,
      nonce: nonce,
      plaintext: CanonicalJson.encodeBytes(inner),
      aad: CanonicalJson.encodeBytes(header),
    );
    return SealResult(
      SealedEnvelope(
        kind: 'dm',
        hint: header['hint']! as String,
        epk: header['epk']! as String,
        ackHash: header['ack']! as String,
        exp: header['exp']! as int,
        nonce: b64(nonce),
        ct: b64(ct),
      ),
      ackSecret,
    );
  }

  /// Attempts to open [env] as [me]. Returns null if it isn't for us or any
  /// check fails (bad MAC, bad signatures, mismatched recipient).
  static Future<OpenedMessage?> open(
      SealedEnvelope env, LocalIdentity me) async {
    if (env.kind != 'dm' || env.hint != me.dmHint) return null;
    try {
      final epk = unb64(env.epk);
      final key = await _key(
          await me.root.dm.agree(epk), epk, me.root.dm.publicKey);
      final clear = await JaalCrypto.open(
        key: key,
        nonce: unb64(env.nonce),
        sealed: unb64(env.ct),
        aad: CanonicalJson.encodeBytes(env.headerJson()),
      );
      if (clear == null) return null;
      final inner =
          (CanonicalJson.decodeBytes(clear)! as Map).cast<String, Object?>();
      final sig = inner.remove('sig')! as String;
      final cert = DeviceCert.fromJson(
          (inner['cert']! as Map).cast<String, Object?>());

      if (inner['to'] != me.rootId) return null; // re-sealed / misaddressed
      if (cert.root != inner['from']) return null;
      if (!await cert.verify()) return null;
      final ok = await JaalCrypto.verify(
        message: concatBytes(
            [SigDomain.dm.codeUnits, CanonicalJson.encodeBytes(inner)]),
        signature: unb64(sig),
        publicKey: unb64(cert.device),
      );
      if (!ok) return null;
      final ackSecret = inner['ackSecret']! as String;
      if (ackHashOf(ackSecret) != env.ackHash) return null;

      return OpenedMessage(
        envelopeId: env.id,
        from: cert.root,
        fromDevice: cert.device,
        to: me.rootId,
        sentAt: inner['sentAt']! as int,
        text: inner['text']! as String,
        ackSecret: ackSecret,
      );
    } on Object {
      return null;
    }
  }
}
