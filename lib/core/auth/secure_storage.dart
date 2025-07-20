import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class SecureStore {
  SecureStore._();
  static const _storage = FlutterSecureStorage();

  static const _kAccessToken = 'access_token';
  static const _kRefreshToken = 'refresh_token';
  static const _kIdToken = 'id_token';

  static Future<void> saveTokens({
    required String accessToken,
    String? refreshToken,
    String? idToken,
  }) async {
    await _storage.write(key: _kAccessToken, value: accessToken);
    if (refreshToken != null) {
      await _storage.write(key: _kRefreshToken, value: refreshToken);
    }
    if (idToken != null) {
      await _storage.write(key: _kIdToken, value: idToken);
    }
  }

  static Future<String?> get accessToken async =>
      _storage.read(key: _kAccessToken);

  static Future<String?> get refreshToken async =>
      _storage.read(key: _kRefreshToken);

  static Future<void> clear() async {
    await _storage.deleteAll();
  }
}
