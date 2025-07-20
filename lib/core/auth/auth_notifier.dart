import 'dart:developer';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_web_auth_2/flutter_web_auth_2.dart';
import 'package:openid_client/openid_client_io.dart';
import 'auth_config.dart';
import 'auth_state.dart';
import '../infra/secure_storage.dart';

final authProvider = StateNotifierProvider<AuthNotifier, AuthState>(
  (ref) => AuthNotifier(),
);

class AuthNotifier extends StateNotifier<AuthState> {
  AuthNotifier() : super(AuthInitial()) {
    _bootstrap();
  }
  late Flow _flow;

  Future<void> _bootstrap() async {
    final token = await SecureStore.accessToken;
    if (token != null) {
      state = AuthAuthenticated(token);
    } else {
      state = AuthUnauthenticated();
    }
  }

  Future<void> login() async {
    state = AuthLoading();
    try {
      final issuer = await Issuer.discover(Uri.parse(AuthConfig.issuer));
      final client = Client(issuer, AuthConfig.clientId);
      _flow = Flow.authorizationCodeWithPKCE(client, scopes: AuthConfig.scopes);
      _flow.redirectUri = Uri.parse(AuthConfig.redirectUri);

      final result = await FlutterWebAuth2.authenticate(
        url: _flow.authenticationUri.toString(),
        callbackUrlScheme: AuthConfig.redirectUri.split('://').first,
      );

      final uri = Uri.parse(result);
      final params = uri.queryParameters;
      final credential = await _flow.callback(params);
      final tokenResponse = await credential.getTokenResponse();

      log(tokenResponse.accessToken ?? '');

      await SecureStore.saveTokens(
        accessToken: tokenResponse.accessToken!,
        refreshToken: tokenResponse.refreshToken ?? '',
        idToken: tokenResponse.idToken.toCompactSerialization(),
      );

      state = AuthAuthenticated(tokenResponse.accessToken!);
    } catch (e) {
      log("Error authenticating: $e");
      state = AuthUnauthenticated(error: e.toString());
    }
  }

  Future<void> refresh() async {
    try {
      final refreshToken = await SecureStore.refreshToken;
      if (refreshToken == null) {
        state = AuthUnauthenticated();
        return;
      }

      final issuer = await Issuer.discover(Uri.parse(AuthConfig.issuer));
      final client = Client(issuer, AuthConfig.clientId);
      final credential = client.createCredential(refreshToken: refreshToken);
      final tokenResponse = await credential.getTokenResponse();

      await SecureStore.saveTokens(
        accessToken: tokenResponse.accessToken!,
        refreshToken: tokenResponse.refreshToken ?? refreshToken,
        idToken: tokenResponse.idToken.toCompactSerialization(),
      );

      state = AuthAuthenticated(tokenResponse.accessToken!);
    } catch (e) {
      state = AuthUnauthenticated(error: e.toString());
    }
  }

  Future<void> logout() async {
    await SecureStore.clearAll();
    state = AuthUnauthenticated();
  }
}
