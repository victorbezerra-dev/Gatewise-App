import 'dart:convert';
import '../../../core/domain/interfaces/custom_http_client.dart';
import '../../../core/infra/secure_storage.dart';
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
}
