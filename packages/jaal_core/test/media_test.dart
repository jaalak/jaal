import 'dart:typed_data';

import 'package:image/image.dart' as img;
import 'package:jaal_core/jaal_core.dart';
import 'package:test/test.dart';

import 'helpers.dart';

/// A noisy synthetic "photo" that doesn't compress trivially.
Uint8List fakePhoto({int w = 3000, int h = 2000, int seed = 1}) {
  final im = img.Image(width: w, height: h);
  var x = seed;
  for (final p in im) {
    x = (x * 1103515245 + 12345) & 0x7fffffff;
    p
      ..r = (p.x * 255 ~/ w + (x & 31)) & 255
      ..g = (p.y * 255 ~/ h + ((x >> 5) & 31)) & 255
      ..b = (x >> 10) & 255;
  }
  return img.encodeJpg(im, quality: 95);
}

void main() {
  late TestMesh mesh;
  final photo = PhotoCompressor.compress(fakePhoto(), targetBytes: 300 * 1024);

  test('compressor fits the budget and the long edge', () {
    expect(photo.bytes.length, lessThanOrEqualTo(300 * 1024));
    expect(photo.width, 1440);
    expect(photo.height, 960);
    final x = PhotoCompressor.compress(fakePhoto(w: 800, h: 1200),
        filter: PhotoFilter.xerox);
    final d = img.decodeJpg(x.bytes)!;
    final px = d.getPixel(400, 600);
    expect((px.r - px.g).abs() <= 3 && (px.g - px.b).abs() <= 3, isTrue,
        reason: 'xerox output is grayscale');
  });

  group('photo posts', () {
    tearDown(() => mesh.dispose());

    Future<bool> hasPhoto(JaalNode n, String hash) async =>
        await n.media.read(hash) != null;

    test('chunks travel with the post and reassemble byte-exact', () async {
      mesh = await TestMesh.create(['A', 'B']);
      final e = await mesh['A'].postPhotos('summit selfie', [photo]);
      final m = JaalNode.mediaOf((await mesh['A'].db.post(e.id))!).single;
      expect(m.chunks.length, (photo.bytes.length / defaultChunkSize).ceil());

      mesh.link('A', 'B');
      await eventually(() => hasPhoto(mesh['B'], m.hash), reason: 'B assembled photo');
      expect(await mesh['B'].media.read(m.hash), photo.bytes);
    });

    test('store-and-forward: C gets the photo from B, never meeting A', () async {
      mesh = await TestMesh.create(['A', 'B', 'C']);
      await mesh['B'].follow(mesh['A'].rootId);
      await mesh['C'].follow(mesh['A'].rootId);
      final e = await mesh['A'].postPhotos('postcard', [photo]);
      final hash = JaalNode.mediaOf((await mesh['A'].db.post(e.id))!).single.hash;
      mesh.link('A', 'B');
      await eventually(() => hasPhoto(mesh['B'], hash));
      mesh.unlink('A', 'B');
      mesh.link('B', 'C');
      await eventually(() => hasPhoto(mesh['C'], hash), reason: 'C via B');
    });

    test('resumes across a link that keeps breaking', () async {
      mesh = await TestMesh.create(['A', 'B']);
      final big = PhotoCompressor.compress(fakePhoto(seed: 7), targetBytes: 600 * 1024);
      final e = await mesh['A'].postPhotos('big one', [big]);
      final hash = JaalNode.mediaOf((await mesh['A'].db.post(e.id))!).single.hash;
      mesh.link('A', 'B', config: const LinkConfig(dropChance: 0.15));
      await eventually(() => hasPhoto(mesh['B'], hash),
          timeout: const Duration(seconds: 60), reason: 'resumed to completion');
      expect(await mesh['B'].media.read(hash), big.bytes);
    });

    test('corrupt or unknown chunks are rejected', () async {
      mesh = await TestMesh.create(['A', 'B'], start: false);
      final e = await mesh['A'].postPhotos('x', [photo]);
      final m = JaalNode.mediaOf((await mesh['A'].db.post(e.id))!).single;
      await MediaStore.expect(mesh['B'].db, m.toJson(), owner: mesh['A'].rootId, now: 1);
      final good = (await mesh['A'].media.chunk(m.hash, 0))!;
      final bad = Uint8List.fromList(good)..[10] ^= 0xff;
      expect(await mesh['B'].media.addChunk(m.hash, 0, bad), isFalse);
      expect(await mesh['B'].media.addChunk('nope', 0, good), isFalse);
      expect(await mesh['B'].media.addChunk(m.hash, 0, good), isTrue);
      expect(await mesh['B'].media.addChunk(m.hash, 0, good), isFalse, reason: 'dupe');
      final p = await mesh['B'].media.watch(m.hash).first;
      expect((p!.held, p.complete), (1, false));
    });

    test('deleting a post drops its photo on every phone', () async {
      mesh = await TestMesh.create(['A', 'B']);
      mesh.link('A', 'B');
      final e = await mesh['A'].postPhotos('regret', [photo]);
      final hash = JaalNode.mediaOf((await mesh['A'].db.post(e.id))!).single.hash;
      await eventually(() => hasPhoto(mesh['B'], hash));
      await mesh['A'].delete(e.id);
      await eventually(() async => await mesh['B'].media.blob(hash) == null,
          reason: 'B dropped the photo');
      expect(await mesh['A'].media.blob(hash), isNull);
    });
  });
}
