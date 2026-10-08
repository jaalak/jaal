import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../app/router.dart';
import '../../design/tokens.dart';
import '../../design/zine.dart';
import '../safety/removed_page.dart';
import '../shared/providers.dart';

/// Bottom-nav shell: home · explore · + · inbox · you (DESIGN.md "Android
/// Navigation Bar": 68px, 3px top rule, active tab is a lime block).
class AppShell extends ConsumerWidget {
  const AppShell({super.key, required this.shell});
  final StatefulNavigationShell shell;

  static const _tabs = [
    (Icons.home_outlined, 'home'),
    (Icons.explore_outlined, 'explore'),
    (Icons.add, ''),
    (Icons.mail_outline, 'inbox'),
    (Icons.fingerprint, 'you'),
  ];

  int get _navIndex => switch (shell.currentIndex) {
    0 => 0,
    1 => 1,
    2 => 3,
    _ => 4,
  };

  void _tap(BuildContext context, int i) {
    if (i == 2) {
      context.push(Routes.compose);
      return;
    }
    final branch = switch (i) {
      0 => 0,
      1 => 1,
      3 => 2,
      _ => 3,
    };
    shell.goBranch(branch, initialLocation: branch == shell.currentIndex);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final removed = ref.watch(meBannedProvider);
    final ink = inkOf(context);
    return Scaffold(
      body: removed ? const RemovedPage() : shell,
      bottomNavigationBar: Container(
        height: 68 + MediaQuery.paddingOf(context).bottom,
        padding: EdgeInsets.only(bottom: MediaQuery.paddingOf(context).bottom),
        decoration: BoxDecoration(
          color: Theme.of(context).scaffoldBackgroundColor,
          border: Border(
            top: BorderSide(color: ink, width: JaalStroke.thick),
          ),
        ),
        child: Row(
          children: [
            for (final (i, (icon, label)) in _tabs.indexed)
              Expanded(
                child: Semantics(
                  button: true,
                  selected: i == _navIndex,
                  label: label.isEmpty ? 'new post' : label,
                  child: GestureDetector(
                    behavior: HitTestBehavior.opaque,
                    onTap: () => _tap(context, i),
                    child: i == 2
                        ? Center(
                            child: Container(
                              width: 56,
                              height: 56,
                              decoration: BoxDecoration(
                                color: JaalColors.pink,
                                border: Border.all(
                                  color: ink,
                                  width: JaalStroke.thick,
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: ink,
                                    offset: JaalStroke.shadowSmall,
                                  ),
                                ],
                              ),
                              child: const Icon(
                                Icons.add,
                                color: JaalColors.paper,
                                size: 32,
                              ),
                            ),
                          )
                        : Container(
                            margin: const EdgeInsets.symmetric(
                              horizontal: 6,
                              vertical: 5,
                            ),
                            decoration: i == _navIndex
                                ? BoxDecoration(
                                    color: JaalColors.acid,
                                    border: Border.all(
                                      color: JaalColors.ink,
                                      width: JaalStroke.thick,
                                    ),
                                  )
                                : null,
                            child: FittedBox(
                              fit: BoxFit.scaleDown,
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    icon,
                                    color: i == _navIndex
                                        ? JaalColors.ink
                                        : ink,
                                    size: 22,
                                  ),
                                  Text(
                                    label,
                                    style: monoStyle(
                                      10.5,
                                      color: i == _navIndex
                                          ? JaalColors.ink
                                          : ink,
                                      bold: i == _navIndex,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

/// Top bar used on tab roots: wordmark + inbox/pouch badges + avatar.
class JaalTopBar extends ConsumerWidget implements PreferredSizeWidget {
  const JaalTopBar({super.key, this.title});

  /// Defaults to the "jaal" wordmark.
  final Widget? title;

  @override
  Size get preferredSize => const Size.fromHeight(72);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final inbox = ref.watch(inboxProvider).value ?? const [];
    final unread = inbox.where((m) => !m.outgoing).length;
    final pouch = ref.watch(carryPouchProvider).value?.length ?? 0;
    return SafeArea(
      bottom: false,
      child: SizedBox(
        height: 72,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: JaalSpace.s4),
          child: Row(
            children: [
              title ?? const Wordmark(),
              const Spacer(),
              ZineIconButton(
                icon: Icons.mail_outline,
                badge: unread,
                tooltip: 'letters',
                onPressed: () => context.go(Routes.inbox),
              ),
              const SizedBox(width: JaalSpace.s3),
              ZineIconButton(
                icon: Icons.inventory_2_outlined,
                badge: pouch,
                badgeColor: JaalColors.blue,
                tooltip: 'carry pouch',
                onPressed: () => context.push(Routes.pouch),
              ),
              const SizedBox(width: JaalSpace.s3),
              GestureDetector(
                onTap: () => context.go(Routes.me),
                child: Container(
                  width: 46,
                  height: 46,
                  decoration: const BoxDecoration(
                    color: Color(0xFF4E6700),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.person_outline,
                    color: JaalColors.paper,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class Wordmark extends StatelessWidget {
  const Wordmark({super.key, this.size = 30});
  final double size;

  @override
  Widget build(BuildContext context) => Stack(
    clipBehavior: Clip.none,
    children: [
      Positioned(
        left: -3,
        right: -5,
        bottom: size * 0.05,
        height: size * 0.42,
        child: Transform(
          transform: Matrix4.skewX(-0.105),
          child: const ColoredBox(color: JaalColors.acid),
        ),
      ),
      Text(
        'jaal',
        style: TextStyle(
          fontFamily: JaalFonts.wordmark,
          fontSize: size,
          height: 1,
          color: inkOf(context),
        ),
      ),
    ],
  );
}

/// Back-button app bar for pushed screens: [←] title  …actions.
class ZineAppBar extends StatelessWidget implements PreferredSizeWidget {
  const ZineAppBar({
    super.key,
    required this.title,
    this.subtitle,
    this.actions = const [],
    this.close = false,
  });
  final String title;
  final String? subtitle;
  final List<Widget> actions;
  final bool close;

  @override
  Size get preferredSize => const Size.fromHeight(76);

  @override
  Widget build(BuildContext context) {
    final ink = inkOf(context);
    return SafeArea(
      bottom: false,
      child: Container(
        height: 76,
        padding: const EdgeInsets.symmetric(horizontal: JaalSpace.s4),
        decoration: BoxDecoration(
          border: Border(
            bottom: BorderSide(color: ink, width: JaalStroke.thick),
          ),
        ),
        child: Row(
          children: [
            ZineIconButton(
              icon: close ? Icons.close : Icons.arrow_back,
              color: Theme.of(context).scaffoldBackgroundColor,
              onPressed: () =>
                  context.canPop() ? context.pop() : context.go(Routes.home),
              tooltip: close ? 'close' : 'back',
            ),
            const SizedBox(width: JaalSpace.s4),
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (subtitle != null)
                    Text(
                      subtitle!,
                      style: monoStyle(11, color: JaalColors.xerox),
                    ),
                  Text(
                    title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: displayStyle(
                      subtitle == null ? JaalSize.h2 : 18,
                      color: ink,
                    ),
                  ),
                ],
              ),
            ),
            for (final a in actions) ...[
              const SizedBox(width: JaalSpace.s2),
              a,
            ],
          ],
        ),
      ),
    );
  }
}
