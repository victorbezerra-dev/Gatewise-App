import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../domain/interfaces/custom_http_client.dart';
import '../infra/custom_htp_client_impl.dart';

final baseUrlProvider = Provider<String>((ref) {
  return 'http://10.0.2.2:8081';
});

final customHttpClientProvider = Provider<CustomHttpClient>((ref) {
  final baseUrl = ref.watch(baseUrlProvider);
  return CustomHttpClientImpl(baseUrl: baseUrl);
});
