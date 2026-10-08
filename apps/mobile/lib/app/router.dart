import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../features/chat/chat_screen.dart';
import '../features/compose/compose_screen.dart';
import '../features/explore/explore_screen.dart';
import '../features/feed/home_screen.dart';
import '../features/inbox/inbox_screen.dart';
import '../features/lab/lab_screen.dart';
import '../features/lab/peer_inspector_screen.dart';
import '../features/meet/connect_iphone_screen.dart';
import '../features/meet/meet_screen.dart';
import '../features/moderation/become_moderator_screen.dart';
import '../features/moderation/moderation_desk_screen.dart';
import '../features/nearby/nearby_screen.dart';
import '../features/onboarding/create_screen.dart';
import '../features/onboarding/phrase_screen.dart';
import '../features/onboarding/restore_screen.dart';
import '../features/onboarding/splash_screen.dart';
import '../features/onboarding/welcome_screen.dart';
import '../features/post/post_detail_screen.dart';
import '../features/pouch/pouch_screen.dart';
import '../features/profile/profile_screen.dart';
import '../features/settings/settings_screen.dart';
import '../features/share/share_screen.dart';
import '../features/shell/app_shell.dart';
import 'session.dart';

abstract final class Routes {
  static const splash = '/';
  static const welcome = '/welcome';
  static const create = '/welcome/create';
  static const restore = '/welcome/restore';
  static const phrase = '/welcome/phrase';

  static const home = '/home';
  static const explore = '/explore';
  static const inbox = '/inbox';
  static const me = '/me';

  static const compose = '/new';
  static const nearby = '/nearby';
  static const pouch = '/pouch';
  static const meet = '/meet';
  static const settings = '/settings';
  static const becomeMod = '/mod/become';
  static const modDesk = '/mod/desk';
  static const lab = '/lab';
  static const share = '/share';
  static const link = '/link';

  static String post(String id) => '/post/$id';
  static String profile(String root) => '/u/$root';
  static String chat(String root) => '/chat/$root';
  static String peer(int index) => '/lab/peer/$index';
}

final routerProvider = Provider<GoRouter>((ref) {
  final refresh = ValueNotifier(0);
  ref.listen(sessionProvider, (_, _) => refresh.value++);
  ref.onDispose(refresh.dispose);

  return GoRouter(
    initialLocation: Routes.splash,
    refreshListenable: refresh,
    redirect: (context, state) {
      final s = ref.read(sessionProvider);
      final loc = state.matchedLocation;
      if (s.isLoading && !s.hasValue) return loc == Routes.splash ? null : Routes.splash;
      final hasIdentity = s.value != null;
      final inOnboarding = loc.startsWith(Routes.welcome);
      if (!hasIdentity && !inOnboarding) return Routes.welcome;
      if (hasIdentity && loc == Routes.splash) return Routes.home;
      if (hasIdentity && inOnboarding && loc != Routes.phrase) return Routes.home;
      return null;
    },
    routes: [
      GoRoute(path: Routes.splash, builder: (_, _) => const SplashScreen()),
      GoRoute(
        path: Routes.welcome,
        builder: (_, _) => const WelcomeScreen(),
        routes: [
          GoRoute(path: 'create', builder: (_, _) => const CreateScreen()),
          GoRoute(path: 'restore', builder: (_, _) => const RestoreScreen()),
          GoRoute(path: 'phrase', builder: (_, s) => PhraseScreen(phrase: s.extra! as String)),
        ],
      ),
      StatefulShellRoute.indexedStack(
        builder: (_, _, shell) => AppShell(shell: shell),
        branches: [
          StatefulShellBranch(routes: [GoRoute(path: Routes.home, builder: (_, _) => const HomeScreen())]),
          StatefulShellBranch(routes: [GoRoute(path: Routes.explore, builder: (_, _) => const ExploreScreen())]),
          StatefulShellBranch(routes: [GoRoute(path: Routes.inbox, builder: (_, _) => const InboxScreen())]),
          StatefulShellBranch(routes: [GoRoute(path: Routes.me, builder: (_, _) => const ProfileScreen(root: null))]),
        ],
      ),
      GoRoute(path: Routes.compose, builder: (_, _) => const ComposeScreen()),
      GoRoute(path: '/post/:id', builder: (_, s) => PostDetailScreen(id: s.pathParameters['id']!)),
      GoRoute(path: '/u/:root', builder: (_, s) => ProfileScreen(root: s.pathParameters['root'])),
      GoRoute(path: '/chat/:root', builder: (_, s) => ChatScreen(peer: s.pathParameters['root']!)),
      GoRoute(path: Routes.nearby, builder: (_, _) => const NearbyScreen()),
      GoRoute(path: Routes.pouch, builder: (_, _) => const PouchScreen()),
      GoRoute(
          path: Routes.meet,
          builder: (_, s) => MeetScreen(moderatorConsent: s.uri.queryParameters['mode'] == 'mod')),
      GoRoute(path: Routes.settings, builder: (_, _) => const SettingsScreen()),
      GoRoute(path: Routes.share, builder: (_, _) => const ShareScreen()),
      GoRoute(path: Routes.link, builder: (_, _) => const ConnectIphoneScreen()),
      GoRoute(path: Routes.becomeMod, builder: (_, _) => const BecomeModeratorScreen()),
      GoRoute(path: Routes.modDesk, builder: (_, _) => const ModerationDeskScreen()),
      GoRoute(
        path: Routes.lab,
        builder: (_, _) => const LabScreen(),
        routes: [
          GoRoute(
            path: 'peer/:index',
            builder: (_, s) => PeerInspectorScreen(index: int.parse(s.pathParameters['index']!)),
          ),
        ],
      ),
    ],
  );
});
