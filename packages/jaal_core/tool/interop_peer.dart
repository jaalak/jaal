// A Dart Jaal peer reachable over WebSocket, driven via stdin, for the
// cross-language interop test in apps/pwa/test/interop.test.ts.
//
//   dart run tool/interop_peer.dart
//   → prints {"ready": <port>, "root": "...", "post": "..."}
//   ← stdin: "dm <rootId> <text>" | "dump" | "quit"
import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:jaal_core/jaal_core.dart';

Future<void> main() async {
  final ws = WebSocketTransport();
  final node = await JaalNode.open(
    identity: await LocalIdentity.create(await RootIdentity.generate(), now: DateTime.now().millisecondsSinceEpoch),
    db: JaalDatabase.memory(),
    transports: [ws],
    name: 'dart',
  );
  await node.setProfile(name: 'Dart', handle: 'dart_peer', bio: 'hello from flutter land');
  final photo = Uint8List.fromList(List.generate(150000, (i) => (i * 7) & 255));
  final post = await node.postPhotos('posted from dart', [CompressedPhoto(photo, 900, 900, photo.length)]);
  await node.start();
  stdout.writeln(jsonEncode({'ready': ws.boundPort, 'root': node.rootId, 'post': post.id}));

  await for (final line in stdin.transform(utf8.decoder).transform(const LineSplitter())) {
    final parts = line.split(' ');
    switch (parts.first) {
      case 'dm':
        await node.sendDm(parts[1], parts.sublist(2).join(' '));
        stdout.writeln(jsonEncode({'ok': 'dm'}));
      case 'dump':
        final posts = await node.db.select(node.db.posts).get();
        final msgs = await node.db.select(node.db.messages).get();
        final profiles = await node.db.select(node.db.profiles).get();
        final photos = <String>[];
        for (final p in posts) {
          for (final m in JaalNode.mediaOf(p)) {
            final b = await node.media.read(m.hash);
            if (b != null) photos.add(b64(JaalCrypto.sha256(b)));
          }
        }
        stdout.writeln(jsonEncode({
          'posts': [for (final p in posts) p.body],
          'messages': [for (final m in msgs) {'body': m.body, 'outgoing': m.outgoing, 'delivered': m.delivered}],
          'profiles': [for (final p in profiles) p.handle],
          'photos': photos,
        }));
      case 'quit':
        await node.close();
        exit(0);
    }
  }
}
