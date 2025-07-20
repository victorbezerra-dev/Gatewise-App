import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../infra/user_repository.dart';
import 'custom_http_client_provider.dart';

final userRepositoryProvider = Provider<UserRepository>((ref) {
  final customHttpClient = ref.watch(customHttpClientProvider);
  return UserRepository(customHttpClient);
});
