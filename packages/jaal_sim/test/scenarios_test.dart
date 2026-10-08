import 'package:jaal_sim/jaal_sim.dart';
import 'package:test/test.dart';

void main() {
  late NetworkLab lab;
  setUp(() => lab = NetworkLab(retryDelay: const Duration(milliseconds: 20)));
  tearDown(() => lab.dispose());

  Future<void> run(Future<ScenarioResult> Function(NetworkLab) s) async {
    final r = await s(lab);
    expect(r.passed, isTrue, reason: r.lines.join('\n'));
  }

  test('mesh converges', () => run(meshScenario));
  test('courier delivers across a gap', () => run(courierScenario));
  test('flaky link resumes', () => run((l) => flakyScenario(l, posts: 80)));
  test('moderation removes a troll', () async {
    await lab.dispose();
    lab = await NetworkLab.create(retryDelay: const Duration(milliseconds: 20));
    await run(moderationScenario);
  });
  test('market moves DMs', () => run((l) => marketScenario(l,
      peers: 6, duration: const Duration(seconds: 4))));
}
