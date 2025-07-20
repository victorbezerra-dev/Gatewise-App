import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/auth/auth_notifier.dart';
import '../../../core/infra/secure_storage.dart';
import '../../../core/infra/user_repository.dart';
import '../../../core/providers/key_manager_provider.dart';
import '../../../core/providers/user_repository_provider.dart';
import '../domain/interfaces/key_manager.dart';

final authFlowNotifierProvider =
    StateNotifierProvider<AuthFlowNotifier, AsyncValue<void>>(
      (ref) => AuthFlowNotifier(
        ref.read(authProvider.notifier),
        ref.read(userRepositoryProvider),
        ref.read(keyManagerProvider),
      ),
    );

class AuthFlowNotifier extends StateNotifier<AsyncValue<void>> {
  final AuthNotifier _authNotifier;
  final UserRepository _userRepository;
  final KeyManager _keyManager;

  AuthFlowNotifier(this._authNotifier, this._userRepository, this._keyManager)
    : super(const AsyncData(null));

  Future<void> loginFlow() async {
    state = const AsyncLoading();
    try {
      await _authNotifier.login();

      final token = await SecureStore.accessToken;
      if (token == null) throw Exception("Token inválido após login.");

      await _userRepository.fetchAndSaveUserProfile();

      await _keyManager.ensureKeyPairExists();
      final publicKey = await _keyManager.getPublicKey();
      if (publicKey == null) throw Exception("Erro ao obter chave pública.");

      await _userRepository.updatePublicKey(publicKey);

      state = const AsyncData(null);
    } catch (e, st) {
      state = AsyncError(e, st);
    }
  }
}
