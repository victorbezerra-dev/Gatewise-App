import 'package:http/http.dart' as http;

abstract class CustomHttpClient {
  Future<http.Response> get(String path, {Map<String, String>? headers});

  Future<http.Response> post(
    String path, {
    Map<String, String>? headers,
    Object? body,
  });

  Future<http.Response> patch(
    String path, {
    Map<String, String>? headers,
    Object? body,
  });
}
