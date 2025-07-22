import 'dart:convert';
import '../../../core/domain/entities/user_entity.dart';
import '../../../core/domain/interfaces/custom_http_client.dart';
import '../../../core/infra/secure_storage.dart';
import '../domain/entities/access_grant.dart';
import '../domain/entities/open_lab_request.dart';

class LabRepository {
  final CustomHttpClient httpClient;

  LabRepository(this.httpClient);

  Future<void> openLab({required OpenLabRequest request}) async {
    final accessToken = await SecureStore.accessToken;
    if (accessToken == null) {
      throw Exception('Access token not found');
    }

    final response = await httpClient.post(
      '/api/Labs/1/open',
      body: jsonEncode(request.toJson()),
      headers: {
        'Authorization': 'Bearer $accessToken',
        'Content-Type': 'application/json',
      },
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to open lab: ${response.body}');
    }
  }

  Future<List<AccessGrant>> getAccessGrants() async {
    final accessToken = await SecureStore.accessToken;
    final userJson = await SecureStore.getUserJson();

    if (userJson == null) {
      throw Exception('An error occurred while retrieving access permissions');
    }

    final userMap = jsonDecode(userJson) as Map<String, dynamic>;
    final user = User.fromJson(userMap);

    if (accessToken == null) {
      throw Exception('Access token not found');
    }

    final response = await httpClient.get('/api/AccessGrants/user/${user.id}');

    if (response.statusCode == 200) {
      final List<dynamic> jsonList = jsonDecode(response.body);
      return jsonList.map((json) => AccessGrant.fromJson(json)).toList();
    } else {
      throw Exception('Failed to fetch access grants: ${response.body}');
    }
  }

  Future<void> requestAccess() async {
    final accessToken = await SecureStore.accessToken;
    if (accessToken == null) {
      throw Exception('Access token not found');
    }

    final body = jsonEncode({
      'labId': 1,
      'reason': 'Student needs access to the laboratory',
    });

    final response = await httpClient.post(
      '/api/AccessGrants/request-access',
      body: body,
    );

    if (response.statusCode != 201) {
      throw Exception('Failed to request access: ${response.body}');
    }
  }
}
