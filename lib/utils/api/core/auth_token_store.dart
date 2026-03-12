import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class AuthTokenStore {
  static const _key = 'auth_access_token';

  final FlutterSecureStorage _storage;

  AuthTokenStore({FlutterSecureStorage? storage})
      : _storage = storage ??
            const FlutterSecureStorage(
              webOptions: WebOptions(
                dbName: 'iam_ecomm_secure',
                publicKey: 'iam_ecomm_public',
              ),
            );

  Future<void> write(String token) => _storage.write(key: _key, value: token);

  Future<String?> read() => _storage.read(key: _key);

  Future<void> clear() => _storage.delete(key: _key);
}

