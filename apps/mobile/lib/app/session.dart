import 'dart:async';
import 'dart:io';

import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:jaal_core/jaal_core.dart';
import 'package:jaal_sim/jaal_sim.dart';
import 'package:logging/logging.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

import 'secure_key_store.dart';

/// A running local node plus the simulated network it is attached to.
///
/// In milestone 1 the only transport is the Network Lab's simulated radio;
/// Bluetooth / Wi-Fi Direct transports will be added to [JaalNode.open]'s
/// `transports` list without any change above this file.
class JaalSession {
  JaalSession(this.node, this.lab);
  final JaalNode node;
  final NetworkLab lab;

  Future<void> dispose() async {
    await lab.dispose();
    await node.close();
  }
}

/// App-level services that tests can override.
class AppEnv {
  const AppEnv({required this.keyStore, required this.openDatabase});

  final KeyStore keyStore;
  final Future<JaalDatabase> Function() openDatabase;

  static AppEnv device() => AppEnv(
        keyStore: SecureKeyStore(),
        openDatabase: () async {
          final dir = await getApplicationSupportDirectory();
          return JaalDatabase.file(File(p.join(dir.path, 'jaal.sqlite')));
        },
      );

  static AppEnv memory() => AppEnv(
        keyStore: MemoryKeyStore(),
        openDatabase: () async => JaalDatabase.memory(),
      );
}

final appEnvProvider = Provider<AppEnv>((ref) => AppEnv.device());

/// Captured logs for the Network Lab wire view.
final logBufferProvider = Provider<LogBuffer>((ref) {
  final b = LogBuffer()..attach(level: Level.INFO);
  ref.onDispose(b.detach);
  return b;
});

/// Null while no identity exists (→ onboarding).
class SessionNotifier extends AsyncNotifier<JaalSession?> {
  @override
  Future<JaalSession?> build() async {
    ref.watch(logBufferProvider);
    final env = ref.watch(appEnvProvider);
    final id = await LocalIdentity.load(env.keyStore);
    if (id == null) return null;
    return _open(id, env);
  }

  Future<JaalSession> _open(LocalIdentity id, AppEnv env) async {
    // The lab brings its own genesis moderators (on top of the production
    // ones) so moderation can be exercised before real genesis keys exist.
    final lab = await NetworkLab.create(
        retryDelay: const Duration(milliseconds: 600), photos: await _labPhotos());
    final transport = lab.transportFor('you');
    final node = await JaalNode.open(
      identity: id,
      db: await env.openDatabase(),
      transports: [transport],
      moderationConfig: lab.moderationConfig,
      name: 'you',
    );
    await node.start();
    lab.adopt('you', node, transport);
    ref.onDispose(() => unawaited(JaalSession(node, lab).dispose()));
    return JaalSession(node, lab);
  }

  static Future<List<Uint8List>> _labPhotos() async {
    try {
      return [
        for (var i = 1; i <= 5; i++)
          (await rootBundle.load('assets/lab/photo-$i.jpg')).buffer.asUint8List(),
      ];
    } on Object {
      return const []; // tests / missing assets: text-only chatter
    }
  }

  /// Creates a brand-new identity and profile. Returns the recovery phrase.
  Future<String> create({required String name, required String handle}) async {
    final env = ref.read(appEnvProvider);
    final id = await LocalIdentity.createAndSave(env.keyStore,
        now: DateTime.now().millisecondsSinceEpoch);
    final session = await _open(id, env);
    await session.node.setProfile(name: name, handle: handle);
    state = AsyncData(session);
    return id.root.recoveryPhrase;
  }

  /// Restores an identity from a 24-word phrase on this (new) device.
  Future<void> restore(String phrase, {required String name, required String handle}) async {
    final env = ref.read(appEnvProvider);
    final id = await LocalIdentity.createAndSave(env.keyStore,
        now: DateTime.now().millisecondsSinceEpoch, phrase: phrase);
    final session = await _open(id, env);
    await session.node.setProfile(name: name, handle: handle);
    state = AsyncData(session);
  }
}

final sessionProvider =
    AsyncNotifierProvider<SessionNotifier, JaalSession?>(SessionNotifier.new);

/// Convenience: the running session (only valid below the onboarding gate).
final requireSessionProvider = Provider<JaalSession>((ref) {
  final s = ref.watch(sessionProvider).value;
  if (s == null) throw StateError('no session');
  return s;
});

/// Lab change ticks (peers added/removed, links changed) for rebuilding.
final labTickProvider = StreamProvider<int>((ref) {
  final lab = ref.watch(requireSessionProvider).lab;
  var n = 0;
  return lab.log.map((_) => ++n);
});
