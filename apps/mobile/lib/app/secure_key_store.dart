import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:jaal_core/jaal_core.dart';

/// [KeyStore] backed by the Android Keystore via flutter_secure_storage.
/// Root and device seeds never touch the SQLite database.
class SecureKeyStore implements KeyStore {
  SecureKeyStore([FlutterSecureStorage? storage])
      : _s = storage ?? const FlutterSecureStorage();

  final FlutterSecureStorage _s;

  @override
  Future<String?> read(String key) => _s.read(key: key);

  @override
  Future<void> write(String key, String value) => _s.write(key: key, value: value);

  @override
  Future<void> delete(String key) => _s.delete(key: key);
}
