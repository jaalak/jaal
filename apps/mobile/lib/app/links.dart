/// Public addresses. The iPhone web app is the PWA built from apps/pwa and
/// deployed to GitHub Pages by .github/workflows/pages.yml.
abstract final class JaalLinks {
  /// Set at build time: `flutter build apk --dart-define=JAAL_WEB_URL=https://<user>.github.io/jaal/`
  static const webApp = String.fromEnvironment('JAAL_WEB_URL', defaultValue: 'https://jaalak.github.io/jaal/');
}
