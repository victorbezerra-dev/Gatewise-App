import 'package:http/http.dart' as http;

import '../domain/interfaces/custom_http_client.dart';
import 'secure_storage.dart';

class CustomHttpClientImpl implements CustomHttpClient {
  final String baseUrl;
  final http.Client _inner;

  CustomHttpClientImpl({required this.baseUrl, http.Client? inner})
    : _inner = inner ?? http.Client();

  @override
  Future<http.Response> get(String path, {Map<String, String>? headers}) async {
    return _inner.get(
      Uri.parse('$baseUrl$path'),
      headers: await _buildHeaders(headers),
    );
  }

  @override
  Future<http.Response> post(
    String path, {
    Map<String, String>? headers,
    Object? body,
  }) async {
    return _inner.post(
      Uri.parse('$baseUrl$path'),
      headers: await _buildHeaders(headers),
      body: body,
    );
  }

  @override
  Future<http.Response> patch(
    String path, {
    Map<String, String>? headers,
    Object? body,
  }) async {
    return _inner.patch(
      Uri.parse('$baseUrl$path'),
      headers: await _buildHeaders(headers),
      body: body,
    );
  }

  Future<Map<String, String>> _buildHeaders(
    Map<String, String>? customHeaders,
  ) async {
    final token = await SecureStore.accessToken;
    return {
      'Authorization': token != null ? 'Bearer $token' : '',
      'Content-Type': 'application/json',
      'Accept': 'application/json',
      ...?customHeaders,
    };
  }
}
