import 'dart:convert';
import '../domain/entities/user_entity.dart';
import '../domain/interfaces/custom_http_client.dart';
import 'secure_storage.dart';

class UserRepository {
  final CustomHttpClient httpClient;

  UserRepository(this.httpClient);

  Future<User> fetchAndSaveUserProfile() async {
    final response = await httpClient.get('/api/Users/me');

    if (response.statusCode != 200) {
      throw Exception('Error fetching user data');
    }
    final user = User.fromJson(jsonDecode(response.body));
    await SecureStore.saveUserJson(jsonEncode(user.toJson()));
    return user;
  }

  Future<User?> loadCachedUser() async {
    final userJson = await SecureStore.getUserJson();
    if (userJson == null) return null;
    return User.fromJson(jsonDecode(userJson));
  }

  Future<void> clearUser() => SecureStore.clearUser();

  Future<void> updatePublicKey(String newPublicKeyPem) async {
    final body = jsonEncode({'devicePublicKeyPem': newPublicKeyPem});
    final response = await httpClient.patch(
      '/api/Users/me/public-key',
      body: body,
    );

    if (response.statusCode != 204) {
      throw Exception('Error updating public key');
    }
  }
}
