import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../app/router.dart';
import '../../design/tokens.dart';
import '../../design/zine.dart';
import '../shared/people.dart';
import '../shared/providers.dart';
import '../shell/app_shell.dart';
import 'post_card.dart';

/// Home (design 04): radar wall of people nearby, then the mesh feed.
class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  bool _everything = false;
  final _openedAt = DateTime.now().millisecondsSinceEpoch;

  @override
  Widget build(BuildContext context) {
    final posts = (_everything ? ref.watch(allPostsProvider) : ref.watch(homeFeedProvider)).value;
    final me = ref.watch(nodeProvider).rootId;
    final fresh = (ref.watch(allPostsProvider).value ?? const [])
        .where((p) => p.rootId != me && p.firstSeenAt > _openedAt)
        .length;

    return Scaffold(
      appBar: const JaalTopBar(),
      body: Grain(
        child: RefreshIndicator(
          onRefresh: () async => ref.invalidate(homeFeedProvider),
          child: CustomScrollView(slivers: [
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(JaalSpace.s4, JaalSpace.s3, JaalSpace.s4, 0),
              sliver: SliverList.list(children: [
                if (fresh > 0) ...[
                  _NewFromMesh(count: fresh),
                  const SizedBox(height: JaalSpace.s4),
                ],
                const RadarWall(),
                const SizedBox(height: JaalSpace.s4),
                Row(children: [
                  Expanded(
                    child: _Toggle(
                        label: 'mesh feed (live)', on: !_everything, onTap: () => setState(() => _everything = false)),
                  ),
                  const SizedBox(width: JaalSpace.s2),
                  Expanded(
                    child: _Toggle(
                        label: 'everything here', on: _everything, onTap: () => setState(() => _everything = true)),
                  ),
                ]),
                const SizedBox(height: JaalSpace.s5),
              ]),
            ),
            if (posts == null)
              const SliverToBoxAdapter(child: Center(child: Padding(padding: EdgeInsets.all(40), child: Text('…'))))
            else if (posts.isEmpty)
              const SliverToBoxAdapter(child: _EmptyFeed())
            else
              SliverPadding(
                padding: const EdgeInsets.symmetric(horizontal: JaalSpace.s4),
                sliver: SliverList.separated(
                  itemCount: posts.length,
                  separatorBuilder: (_, _) => const SizedBox(height: JaalSpace.s5),
                  itemBuilder: (_, i) => PostCard(post: posts[i], index: i),
                ),
              ),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: JaalSpace.s6),
                child: Column(children: [
                  Text('end of local radio buffer · ${posts?.length ?? 0} cached',
                      style: monoStyle(11, color: JaalColors.xerox)),
                  const SizedBox(height: 6),
                  const HandNote('no internet, no trace, just pocket to pocket.', color: JaalColors.pink),
                ]),
              ),
            ),
          ]),
        ),
      ),
    );
  }
}

class _NewFromMesh extends StatelessWidget {
  const _NewFromMesh({required this.count});
  final int count;

  @override
  Widget build(BuildContext context) => ZineBox(
        color: JaalColors.acid,
        shadow: JaalStroke.shadowSmall,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        child: Row(children: [
          const Icon(Icons.south, color: JaalColors.ink),
          const SizedBox(width: 8),
          Expanded(
            child: Text('$count new from the mesh', style: monoStyle(13, color: JaalColors.ink, bold: true)),
          ),
        ]),
      );
}

class _Toggle extends StatelessWidget {
  const _Toggle({required this.label, required this.on, required this.onTap});
  final String label;
  final bool on;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 10),
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: on ? JaalColors.acid : Theme.of(context).scaffoldBackgroundColor,
            border: Border.all(color: inkOf(context), width: on ? JaalStroke.thick : JaalStroke.hairline),
            boxShadow: on ? [BoxShadow(color: inkOf(context), offset: JaalStroke.shadowSmall)] : null,
          ),
          child: Text(label, style: monoStyle(12, color: on ? JaalColors.ink : JaalColors.xerox, bold: on)),
        ),
      );
}

/// Corkboard of polaroids: people physically near you right now.
class RadarWall extends ConsumerWidget {
  const RadarWall({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final sessions = ref.watch(sessionsProvider).value ?? const [];
    final roots = [for (final s in sessions) ?s.peerRoot];
    final newEvents = sessions.fold<int>(0, (a, s) => a + s.stats.eventsIn);
    return GestureDetector(
      onTap: () => context.push(Routes.nearby),
      child: Container(
        height: 196,
        decoration: BoxDecoration(
          border: Border.all(color: JaalColors.ink, width: JaalStroke.thick),
          boxShadow: const [BoxShadow(color: JaalColors.ink, offset: JaalStroke.shadow)],
        ),
        margin: const EdgeInsets.only(right: 6, bottom: 6),
        child: Halftone(
          color: const Color(0xFFDDD3B8),
          child: Stack(children: [
            const Positioned(left: 8, top: 8, child: _Pin()),
            const Positioned(right: 8, top: 8, child: _Pin(color: JaalColors.blue)),
            Positioned(
              left: 18,
              top: 14,
              child: TapeStrip(
                width: 240,
                angle: -0.02,
                label: roots.isEmpty
                    ? 'nobody around · posts wait in your pocket'
                    : 'syncing… ${roots.length} nearby · $newEvents new',
              ),
            ),
            Positioned.fill(
              top: 46,
              child: roots.isEmpty
                  ? Padding(
                      padding: const EdgeInsets.all(JaalSpace.s4),
                      child: Row(children: [
                        Container(
                          width: 80,
                          height: 100,
                          decoration: BoxDecoration(
                            border: Border.all(color: JaalColors.xerox, width: 2),
                            color: JaalColors.paper.withValues(alpha: 0.6),
                          ),
                          alignment: Alignment.center,
                          child: const Icon(Icons.qr_code_scanner, color: JaalColors.xerox),
                        ),
                        const SizedBox(width: JaalSpace.s3),
                        const Expanded(
                          child: HandNote(
                              'nobody around. they\'ll leave when someone walks by. tap to meet someone →',
                              size: 18),
                        ),
                      ]),
                    )
                  : ListView(
                      scrollDirection: Axis.horizontal,
                      padding: const EdgeInsets.fromLTRB(16, 4, 16, 8),
                      children: [
                        for (final (i, r) in roots.indexed)
                          Padding(
                            padding: const EdgeInsets.only(right: 16),
                            child: Polaroid(root: r, size: 78, tilt: (i.isEven ? -1 : 1) * 0.05),
                          ),
                        GestureDetector(
                          onTap: () => context.push(Routes.meet),
                          child: Container(
                            width: 90,
                            margin: const EdgeInsets.only(top: 4, bottom: 10),
                            decoration: BoxDecoration(border: Border.all(color: JaalColors.ink, width: 2)),
                            alignment: Alignment.center,
                            child: Text('+ meet\nsomeone\n(qr)',
                                textAlign: TextAlign.center, style: monoStyle(11, color: JaalColors.ink)),
                          ),
                        ),
                      ],
                    ),
            ),
          ]),
        ),
      ),
    );
  }
}

class _Pin extends StatelessWidget {
  const _Pin({this.color = JaalColors.pink});
  final Color color;

  @override
  Widget build(BuildContext context) => Container(
        width: 18,
        height: 18,
        decoration: BoxDecoration(
          color: color,
          shape: BoxShape.circle,
          border: Border.all(color: JaalColors.paper, width: 4),
        ),
      );
}

class _EmptyFeed extends StatelessWidget {
  const _EmptyFeed();

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.all(JaalSpace.s4),
        child: ZineBox(
          dashed: true,
          padding: const EdgeInsets.all(JaalSpace.s5),
          child: Column(children: [
            Text('quiet out here.', style: displayStyle(JaalSize.h2, color: inkOf(context))),
            const SizedBox(height: JaalSpace.s2),
            const Text('follow people you meet. scan their qr — their posts reach you through anyone in between.',
                textAlign: TextAlign.center),
            const SizedBox(height: JaalSpace.s4),
            ZineButton(
              label: 'show my qr',
              icon: Icons.qr_code_2,
              onPressed: () => context.push(Routes.meet),
            ),
          ]),
        ),
      );
}
