import 'dart:async';

import 'package:drift/drift.dart';

import '../crypto/crypto.dart';
import '../db/database.dart';
import '../identity/identity.dart';
import '../util/bytes.dart';
import '../util/canonical_json.dart';
import '../util/clock.dart';
import 'chunking.dart';

/// Download progress of one blob.
class MediaProgress {
  const MediaProgress(this.held, this.total, this.complete);
  final int held;
  final int total;
  final bool complete;
  double get fraction => total == 0 ? 1 : held / total;
}

/// Local store of content-addressed media (protocol/SPEC.md §8).
///
/// Posts carry [MediaManifest]s; when a post is projected its blobs are
/// *expected*. Chunks then arrive from any peer that holds them, in any
/// order, each verified against the manifest, so transfers resume after
/// interruptions and any phone can forward media it holds.
class MediaStore {
  MediaStore(this.db, this.clock);

  final JaalDatabase db;
  final Clock clock;
  final _changes = StreamController<String>.broadcast(sync: true);
  final Mutex _lock = Mutex();

  /// Emits a blob hash whenever chunks are added or a blob is registered.
  Stream<String> get changes => _changes.stream;

  /// Stores a photo authored on this device (already compressed) and
  /// returns its manifest for the post body.
  Future<MediaManifest> putLocal(Uint8List bytes,
      {required String mime, required RootId owner, int? width, int? height}) async {
    final m = Chunker.manifestFor(bytes, mime: mime, width: width, height: height);
    final chunks = Chunker.split(bytes, m.chunkSize);
    await db.transaction(() async {
      await _register(m, owner, complete: true, held: chunks.length);
      for (var i = 0; i < chunks.length; i++) {
        await db.into(db.mediaChunks).insert(
            MediaChunksCompanion.insert(hash: m.hash, idx: i, data: chunks[i]),
            mode: InsertMode.insertOrIgnore);
      }
    });
    _emit(m.hash);
    return m;
  }

  /// Registers media referenced by a post or profile we just stored.
  /// Called by the Projector inside the ingest transaction.
  static Future<void> expect(JaalDatabase db, Object? manifestJson,
      {required RootId owner, required int now}) async {
    if (manifestJson is! Map) return;
    final MediaManifest m;
    try {
      m = MediaManifest.fromJson(manifestJson.cast<String, Object?>());
    } on Object {
      return; // malformed ref: render as missing media
    }
    if (m.chunks.isEmpty || m.chunks.length > 4096) return;
    await db.into(db.mediaBlobs).insert(
        MediaBlobsCompanion.insert(
          hash: m.hash,
          manifest: CanonicalJson.encode(m.toJson()),
          mime: m.mime,
          size: m.size,
          chunkCount: m.chunks.length,
          rootId: owner,
          createdAt: now,
        ),
        mode: InsertMode.insertOrIgnore);
  }

  Future<void> _register(MediaManifest m, RootId owner,
      {bool complete = false, int held = 0}) {
    return db.into(db.mediaBlobs).insertOnConflictUpdate(MediaBlobsCompanion.insert(
          hash: m.hash,
          manifest: CanonicalJson.encode(m.toJson()),
          mime: m.mime,
          size: m.size,
          chunkCount: m.chunks.length,
          chunksHeld: Value(held),
          complete: Value(complete),
          rootId: owner,
          createdAt: clock.nowMs(),
        ));
  }

  Future<MediaBlobRow?> blob(String hash) =>
      (db.select(db.mediaBlobs)..where((b) => b.hash.equals(hash))).getSingleOrNull();

  Future<MediaManifest?> manifest(String hash) async {
    final b = await blob(hash);
    return b == null
        ? null
        : MediaManifest.fromJson(
            (CanonicalJson.decode(b.manifest)! as Map).cast<String, Object?>());
  }

  Future<Uint8List?> chunk(String hash, int idx) async =>
      (await (db.select(db.mediaChunks)
                ..where((c) => c.hash.equals(hash) & c.idx.equals(idx)))
              .getSingleOrNull())
          ?.data;

  Future<Set<int>> heldIndices(String hash) async =>
      (await (db.selectOnly(db.mediaChunks)
                ..addColumns([db.mediaChunks.idx])
                ..where(db.mediaChunks.hash.equals(hash)))
              .get())
          .map((r) => r.read(db.mediaChunks.idx)!)
          .toSet();

  /// Verifies and stores one chunk. Returns false if unknown, already held
  /// or corrupt.
  Future<bool> addChunk(String hash, int idx, Uint8List data) =>
      _lock.run(() => _addChunk(hash, idx, data));

  Future<bool> _addChunk(String hash, int idx, Uint8List data) async {
    final b = await blob(hash);
    if (b == null || b.complete || idx < 0 || idx >= b.chunkCount) return false;
    final m = MediaManifest.fromJson(
        (CanonicalJson.decode(b.manifest)! as Map).cast<String, Object?>());
    if (b64(JaalCrypto.sha256(data)) != m.chunks[idx]) return false;
    var added = false;
    await db.transaction(() async {
      if (await chunk(hash, idx) != null) return; // already held
      await db.into(db.mediaChunks).insert(
          MediaChunksCompanion.insert(hash: hash, idx: idx, data: data));
      added = true;
      final held = b.chunksHeld + 1;
      var complete = held >= b.chunkCount;
      if (complete) {
        // Whole-file check before declaring it done.
        final whole = await _assemble(hash, b.chunkCount);
        complete = whole != null && b64(JaalCrypto.sha256(whole)) == hash;
        if (!complete) {
          await (db.delete(db.mediaChunks)..where((c) => c.hash.equals(hash))).go();
        }
      }
      await (db.update(db.mediaBlobs)..where((x) => x.hash.equals(hash))).write(
          MediaBlobsCompanion(
              chunksHeld: Value(complete || held < b.chunkCount ? held : 0),
              complete: Value(complete)));
    });
    if (added) _emit(hash);
    return added;
  }

  Future<Uint8List?> _assemble(String hash, int count) async {
    final rows = await (db.select(db.mediaChunks)
          ..where((c) => c.hash.equals(hash))
          ..orderBy([(c) => OrderingTerm.asc(c.idx)]))
        .get();
    if (rows.length != count) return null;
    return concatBytes(rows.map((r) => r.data).toList());
  }

  /// The full file, or null until every chunk is here.
  Future<Uint8List?> read(String hash) async {
    final b = await blob(hash);
    if (b == null || !b.complete) return null;
    return _assemble(hash, b.chunkCount);
  }

  Stream<MediaProgress?> watch(String hash) =>
      (db.select(db.mediaBlobs)..where((b) => b.hash.equals(hash)))
          .watchSingleOrNull()
          .map((b) => b == null ? null : MediaProgress(b.chunksHeld, b.chunkCount, b.complete));

  /// Missing chunks of incomplete blobs, newest first, up to [maxChunks].
  Future<List<(String, List<int>)>> wanted({int maxChunks = 16, Set<String> skip = const {}}) async {
    final blobs = await (db.select(db.mediaBlobs)
          ..where((b) => b.complete.equals(false))
          ..orderBy([(b) => OrderingTerm.desc(b.createdAt)])
          ..limit(64))
        .get();
    final out = <(String, List<int>)>[];
    var budget = maxChunks;
    for (final b in blobs) {
      if (budget <= 0) break;
      final held = await heldIndices(b.hash);
      final missing = [
        for (var i = 0; i < b.chunkCount; i++)
          if (!held.contains(i) && !skip.contains('${b.hash}:$i')) i,
      ].take(budget).toList();
      if (missing.isNotEmpty) {
        out.add((b.hash, missing));
        budget -= missing.length;
      }
    }
    return out;
  }

  /// Drops a blob and its chunks (post deleted / author banned).
  static Future<void> drop(JaalDatabase db, String hash) async {
    await (db.delete(db.mediaChunks)..where((c) => c.hash.equals(hash))).go();
    await (db.delete(db.mediaBlobs)..where((b) => b.hash.equals(hash))).go();
  }

  static Future<void> dropOwnedBy(JaalDatabase db, RootId root) async {
    final hashes = (await (db.select(db.mediaBlobs)
              ..where((b) => b.rootId.equals(root)))
            .get())
        .map((b) => b.hash);
    for (final h in hashes) {
      await drop(db, h);
    }
  }

  void _emit(String hash) {
    if (!_changes.isClosed) _changes.add(hash);
  }

  Future<void> dispose() => _changes.close();
}
