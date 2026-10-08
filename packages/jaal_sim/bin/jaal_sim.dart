import 'dart:io';

import 'package:args/args.dart';
import 'package:jaal_core/jaal_core.dart';
import 'package:jaal_sim/jaal_sim.dart';
import 'package:logging/logging.dart';

/// jaal_sim — run decentralized scenarios on a simulated peer network.
///
///   dart run jaal_sim                 # run every scenario
///   dart run jaal_sim courier -v      # one scenario, with sync logs
///   dart run jaal_sim --list
Future<void> main(List<String> argv) async {
  final parser = ArgParser()
    ..addFlag('list', abbr: 'l', negatable: false, help: 'List scenarios')
    ..addFlag('verbose', abbr: 'v', negatable: false, help: 'Print sync logs')
    ..addFlag('timeline', abbr: 't', negatable: false, help: 'Print lab timeline')
    ..addOption('seed', defaultsTo: '7')
    ..addFlag('help', abbr: 'h', negatable: false);
  final args = parser.parse(argv);

  if (args.flag('help')) {
    stdout.writeln('usage: jaal_sim [scenario...] [options]\n${parser.usage}');
    return;
  }
  if (args.flag('list')) {
    for (final MapEntry(:key, value: (desc, _)) in scenarios.entries) {
      stdout.writeln('  ${key.padRight(10)} $desc');
    }
    return;
  }

  final logs = LogBuffer();
  if (args.flag('verbose')) {
    logs.attach(level: Level.INFO);
    logs.stream.listen((r) => stdout.writeln('    ${LogBuffer.format(r)}'));
  }

  final names = args.rest.isEmpty ? scenarios.keys.toList() : args.rest;
  var failed = 0;
  for (final name in names) {
    final entry = scenarios[name];
    if (entry == null) {
      stderr.writeln('unknown scenario "$name" (try --list)');
      exitCode = 64;
      return;
    }
    final lab = await NetworkLab.create(
        seed: int.parse(args.option('seed')!),
        retryDelay: const Duration(milliseconds: 50));
    if (args.flag('timeline')) {
      lab.log.listen((e) => stdout.writeln('    $e'));
    }
    stdout.writeln('▶ $name — ${entry.$1}');
    final result = await entry.$2(lab);
    for (final l in result.lines) {
      stdout.writeln('  $l');
    }
    stdout.writeln(
        '  ${result.passed ? 'PASS' : 'FAIL'} in ${result.clock.elapsedMilliseconds}ms\n');
    if (!result.passed) failed++;
    await lab.dispose();
  }
  await logs.detach();
  exit(failed == 0 ? 0 : 1);
}
