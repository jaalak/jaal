import 'package:flutter_test/flutter_test.dart';
import 'package:jaal_mobile/app/updater.dart';

void main() {
  test('versions compare numerically, not as text', () {
    expect(Updater.compare('0.1.1', '0.1.0'), 1);
    expect(Updater.compare('0.10.0', '0.9.9'), 1);
    expect(Updater.compare('1.0.0', '1.0.0'), 0);
    expect(Updater.compare('0.1.0', '0.2.0'), -1);
    expect(Updater.compare('0.2', '0.2.0'), 0);
    expect(Updater.compare('0.2.0+5', '0.2.0'), 0);
  });
}
