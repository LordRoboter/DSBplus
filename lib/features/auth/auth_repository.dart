import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../../core/storage/secure_storage.dart';

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return AuthRepository(storage: ref.watch(secureStorageProvider));
});

class AuthRepository {
  AuthRepository({required this.storage});

  final FlutterSecureStorage storage;

  static const _usernameKey = 'username';
  static const _passwordKey = 'password';

  Future<void> saveCredentials({
    required String username,
    required String password,
  }) async {
    await storage.write(key: _usernameKey, value: username);

    await storage.write(key: _passwordKey, value: password);
  }

  Future<String?> getUsername() {
    return storage.read(key: _usernameKey);
  }

  Future<String?> getPassword() {
    return storage.read(key: _passwordKey);
  }

  Future<void> clearCredenetials() async {
    await Future.wait([
      storage.delete(key: _usernameKey),
      storage.delete(key: _passwordKey),
    ]);
  }
}
