import 'dart:typed_data';

import '../crypto/crypto.dart';
import '../util/bytes.dart';

/// Default chunk size: fits comfortably in one transport frame.
const int defaultChunkSize = 64 * 1024;

/// Content-addressed description of a media blob (protocol/SPEC.md §8).
/// Posts reference media by manifest; chunks travel separately and are
/// verified one by one, so transfers can resume from any chunk.
///
/// Milestone 1 implements splitting, verification and resumable assembly.
/// Compression, per-file encryption and the `media.*` sync messages are
/// milestone 2.
class MediaManifest {
  const MediaManifest({
    required this.hash,
    required this.mime,
    required this.size,
    required this.chunkSize,
    required this.chunks,
    this.width,
    this.height,
    this.durationMs,
  });

  /// base64url SHA-256 of the full content.
  final String hash;
  final String mime;
  final int size;
  final int chunkSize;

  /// base64url SHA-256 of each chunk, in order.
  final List<String> chunks;
  final int? width, height, durationMs;

  Map<String, Object?> toJson() => {
        'hash': hash,
        'mime': mime,
        'size': size,
        'chunkSize': chunkSize,
        'chunks': chunks,
        'w': width,
        'h': height,
        'dur': durationMs,
      };

  static MediaManifest fromJson(Map<String, Object?> j) => MediaManifest(
        hash: j['hash']! as String,
        mime: j['mime']! as String,
        size: j['size']! as int,
        chunkSize: j['chunkSize']! as int,
        chunks: (j['chunks']! as List).cast<String>(),
        width: j['w'] as int?,
        height: j['h'] as int?,
        durationMs: j['dur'] as int?,
      );
}

abstract final class Chunker {
  static MediaManifest manifestFor(Uint8List data,
      {required String mime, int chunkSize = defaultChunkSize, int? width, int? height}) {
    return MediaManifest(
      hash: b64(JaalCrypto.sha256(data)),
      mime: mime,
      size: data.length,
      chunkSize: chunkSize,
      chunks: [
        for (final c in split(data, chunkSize)) b64(JaalCrypto.sha256(c)),
      ],
      width: width,
      height: height,
    );
  }

  static List<Uint8List> split(Uint8List data, int chunkSize) => [
        for (var o = 0; o < data.length; o += chunkSize)
          Uint8List.sublistView(
              data, o, o + chunkSize > data.length ? data.length : o + chunkSize),
      ];
}

/// Collects chunks in any order, verifying each against the manifest.
/// Persist [received] to resume after an interrupted transfer.
class ChunkAssembler {
  ChunkAssembler(this.manifest)
      : _chunks = List<Uint8List?>.filled(manifest.chunks.length, null);

  final MediaManifest manifest;
  final List<Uint8List?> _chunks;

  Set<int> get received => {
        for (var i = 0; i < _chunks.length; i++)
          if (_chunks[i] != null) i,
      };

  List<int> get missing => [
        for (var i = 0; i < _chunks.length; i++)
          if (_chunks[i] == null) i,
      ];

  bool get isComplete => _chunks.every((c) => c != null);

  double get progress =>
      _chunks.isEmpty ? 1 : received.length / _chunks.length;

  /// Returns false (and discards the data) if the chunk fails verification.
  bool add(int index, Uint8List data) {
    if (index < 0 || index >= _chunks.length) return false;
    if (b64(JaalCrypto.sha256(data)) != manifest.chunks[index]) return false;
    _chunks[index] = data;
    return true;
  }

  /// Joins the chunks and verifies the whole-file hash.
  Uint8List assemble() {
    if (!isComplete) throw StateError('missing chunks $missing');
    final out = concatBytes(_chunks.cast<Uint8List>());
    if (b64(JaalCrypto.sha256(out)) != manifest.hash) {
      throw StateError('assembled content hash mismatch');
    }
    return out;
  }
}
