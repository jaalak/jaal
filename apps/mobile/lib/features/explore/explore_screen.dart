import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:jaal_core/jaal_core.dart';

import '../../app/router.dart';
import '../../design/tokens.dart';
import '../../design/zine.dart';
import '../shared/media.dart';
import '../shared/people.dart';
import '../shared/providers.dart';
import '../shell/app_shell.dart';

/// Explore (design 14): only what has reached your phone — no cloud, no
/// algorithm. Friends-of-friends, filtered by how far things travelled.
class ExploreScreen extends ConsumerStatefulWidget {
  const ExploreScreen({super.key});

  @override
  ConsumerState<ExploreScreen> createState() => _ExploreScreenState();
}

class _ExploreScreenState extends ConsumerState<ExploreScreen> {
  final _q = TextEditingController();
  String _query = '';
  int _filter = 0;

  @override
  void dispose() {
    _q.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final node = ref.watch(nodeProvider);
    final following = ref.watch(followingProvider).value ?? const {};
    final source = _query.isEmpty ? ref.watch(allPostsProvider) : ref.watch(searchProvider(_query));
    final nearby = ref.watch(nearbyRootsProvider);
    final filters = <(String, bool Function(PostRow))>[
      ('all', (_) => true),
      ('1 hop away', (p) => p.hops == 1),
      ('2+ hops', (p) => p.hops >= 2),
      ('nearby today', (p) => nearby.contains(p.rootId)),
    ];
    final posts = (source.value ?? const [])
        .where((p) => p.rootId != node.rootId && (_query.isNotEmpty || !following.contains(p.rootId)))
        .where(filters[_filter].$2)
        .toList();

    final people = ref.watch(_fofProvider).value ?? const [];

    return Scaffold(
      appBar: const JaalTopBar(),
      body: Grain(
        child: ListView(padding: const EdgeInsets.all(JaalSpace.s4), children: [
          const Highlighted('explore', size: 44),
          const SizedBox(height: 6),
          const HandNote('scavenged from local phone pockets & bikes ★', size: 20),
          const SizedBox(height: JaalSpace.s4),
          ZineBox(
            padding: const EdgeInsets.all(12),
            child: Column(children: [
              Row(children: [
                const Icon(Icons.search),
                const SizedBox(width: 8),
                Expanded(
                  child: TextField(
                    controller: _q,
                    decoration: const InputDecoration(
                      hintText: 'search what\'s on your phone',
                      border: InputBorder.none,
                      enabledBorder: InputBorder.none,
                      focusedBorder: InputBorder.none,
                      filled: false,
                    ),
                    onSubmitted: (v) => setState(() => _query = v.trim()),
                  ),
                ),
                GestureDetector(
                  onTap: () => setState(() => _query = _q.text.trim()),
                  child: const InkLabel('find'),
                ),
              ]),
              const Divider(),
              Row(children: [
                Expanded(child: Text('no cloud. only what\'s reached you.', style: monoStyle(11, color: JaalColors.xerox))),
                MonoChip('${(source.value ?? const []).length} local'),
              ]),
            ]),
          ),
          const SizedBox(height: JaalSpace.s4),
          SizedBox(
            height: 46,
            child: ListView(scrollDirection: Axis.horizontal, children: [
              for (final (i, (l, _)) in filters.indexed)
                GestureDetector(
                  onTap: () => setState(() => _filter = i),
                  child: Container(
                    margin: const EdgeInsets.only(right: 8, bottom: 4),
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: _filter == i ? JaalColors.acid : Theme.of(context).scaffoldBackgroundColor,
                      border: Border.all(color: inkOf(context), width: 2.5),
                      boxShadow: [BoxShadow(color: inkOf(context), offset: JaalStroke.shadowSmall)],
                    ),
                    child: Text(_filter == i ? '[✓ $l]' : l,
                        style: monoStyle(12, bold: true, color: _filter == i ? JaalColors.ink : inkOf(context))),
                  ),
                ),
            ]),
          ),
          const SizedBox(height: JaalSpace.s3),
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: JaalColors.tape,
              border: Border.all(color: JaalColors.ink, width: 2.5),
              boxShadow: const [BoxShadow(color: JaalColors.ink, offset: JaalStroke.shadowSmall)],
            ),
            child: Column(children: [
              Row(children: [
                Flexible(child: Text('← closer (1 hop)', style: monoStyle(10, bold: true, color: JaalColors.ink))),
                const SizedBox(width: 8),
                Flexible(
                  child: Text('further (3+ hops) →',
                      textAlign: TextAlign.right, style: monoStyle(10, bold: true, color: JaalColors.ink)),
                ),
              ]),
              const SizedBox(height: 6),
              CustomPaint(size: const Size(double.infinity, 12), painter: _Ruler()),
            ]),
          ),
          if (people.isNotEmpty && _query.isEmpty) ...[
            const SizedBox(height: JaalSpace.s5),
            Row(children: [
              const InkLabel('p2p', color: JaalColors.pink),
              const SizedBox(width: 8),
              Flexible(child: Text('people around your people', style: monoStyle(13, bold: true))),
            ]),
            const SizedBox(height: JaalSpace.s3),
            SizedBox(
              height: 252,
              child: ListView(scrollDirection: Axis.horizontal, children: [
                for (final (root, by) in people)
                  Container(
                    width: 170,
                    margin: const EdgeInsets.only(right: 12, bottom: 8),
                    child: ZineBox(
                      padding: const EdgeInsets.all(10),
                      child: Column(children: [
                        Polaroid(root: root, size: 96, caption: false),
                        const SizedBox(height: 6),
                        Text(handleOf(ref, root), maxLines: 1, overflow: TextOverflow.ellipsis, style: monoStyle(10)),
                        Text(by == 0 ? 'met nearby' : 'followed by $by of yours',
                            style: handStyle(size: 16, color: by == 0 ? JaalColors.pink : JaalColors.blue)),
                        const Spacer(),
                        ZineButton(
                          small: true,
                          label: 'follow',
                          onPressed: () => node.follow(root),
                        ),
                      ]),
                    ),
                  ),
              ]),
            ),
          ],
          const SizedBox(height: JaalSpace.s5),
          Row(children: [
            Flexible(child: Text(_query.isEmpty ? 'pasted dispatches' : 'found', style: monoStyle(14, bold: true))),
            const SizedBox(width: 8),
            MonoChip('${posts.length}', color: JaalColors.acid),
          ]),
          const SizedBox(height: JaalSpace.s3),
          if (posts.isEmpty)
            const HandNote('nothing here yet. explore fills up as phones meet.', color: JaalColors.xerox, size: 19)
          else
            _Masonry(posts: posts),
          const SizedBox(height: JaalSpace.s6),
        ]),
      ),
    );
  }
}

/// People around your people: known profiles you don't follow, ranked by
/// how many of your follows follow them.
final _fofProvider = FutureProvider.autoDispose<List<(String, int)>>((ref) async {
  final node = ref.watch(nodeProvider);
  final profiles = ref.watch(profilesProvider).value ?? const {};
  final following = ref.watch(followingProvider).value ?? const <String>{};
  final out = <(String, int)>[];
  for (final p in profiles.keys) {
    if (p == node.rootId || following.contains(p)) continue;
    final by = (await node.db.followersOf(p)).intersection(following).length;
    out.add((p, by));
  }
  out.sort((a, b) => b.$2.compareTo(a.$2));
  return out.take(12).toList();
});

class _Ruler extends CustomPainter {
  @override
  void paint(Canvas canvas, Size s) {
    final p = Paint()
      ..color = JaalColors.ink
      ..strokeWidth = 1.5;
    canvas.drawLine(Offset(0, s.height), Offset(s.width, s.height), p);
    for (var x = 0.0, i = 0; x <= s.width; x += 6, i++) {
      canvas.drawLine(Offset(x, s.height), Offset(x, i % 5 == 0 ? 0 : s.height / 2), p);
    }
  }

  @override
  bool shouldRepaint(_) => false;
}

class _Masonry extends StatelessWidget {
  const _Masonry({required this.posts});
  final List<PostRow> posts;

  @override
  Widget build(BuildContext context) {
    final left = [for (var i = 0; i < posts.length; i += 2) posts[i]];
    final right = [for (var i = 1; i < posts.length; i += 2) posts[i]];
    return Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Expanded(child: Column(children: [for (final (i, p) in left.indexed) _Tile(post: p, i: i)])),
      const SizedBox(width: 12),
      Expanded(child: Column(children: [for (final (i, p) in right.indexed) _Tile(post: p, i: i + 1)])),
    ]);
  }
}

class _Tile extends ConsumerWidget {
  const _Tile({required this.post, required this.i});
  final PostRow post;
  final int i;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final media = JaalNode.mediaOf(post);
    final lime = media.isEmpty && i % 3 == 0;
    return GestureDetector(
      onTap: () => context.push(Routes.post(post.id)),
      child: Padding(
        padding: const EdgeInsets.only(bottom: 16),
        child: Stack(clipBehavior: Clip.none, children: [
          ZineBox(
            tilt: (i.isEven ? -1 : 1) * 0.012,
            color: lime ? JaalColors.acid : null,
            padding: const EdgeInsets.all(8),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              if (media.isNotEmpty)
                AspectRatio(
                  aspectRatio: 1,
                  child: DecoratedBox(
                    decoration: BoxDecoration(border: Border.all(color: JaalColors.ink, width: 2)),
                    child: ClipRect(child: JaalPhoto(manifest: media.first)),
                  ),
                ),
              const SizedBox(height: 6),
              Text(handleOf(ref, post.rootId),
                  maxLines: 1, overflow: TextOverflow.ellipsis, style: monoStyle(10, bold: true, color: JaalColors.ink)),
              const SizedBox(height: 4),
              Text(post.body,
                  maxLines: media.isEmpty ? 7 : 3,
                  overflow: TextOverflow.ellipsis,
                  style: lime
                      ? displayStyle(17, color: JaalColors.ink)
                      : Theme.of(context).textTheme.bodyMedium),
            ]),
          ),
          if (post.hops > 0)
            Positioned(
              right: -4,
              top: -10,
              child: Container(
                width: 34,
                height: 34,
                decoration: BoxDecoration(
                  color: JaalColors.paper,
                  shape: BoxShape.circle,
                  border: Border.all(color: JaalColors.stamp, width: 2),
                ),
                alignment: Alignment.center,
                child: Text('${post.hops}h', style: monoStyle(11, color: JaalColors.stamp, bold: true)),
              ),
            ),
        ]),
      ),
    );
  }
}
