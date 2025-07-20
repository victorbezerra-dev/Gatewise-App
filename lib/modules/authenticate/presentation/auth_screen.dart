import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gatewise_app/modules/authenticate/presentation/auth_flow_notifier.dart';
import '../../../core/auth/auth_notifier.dart';
import '../../../core/auth/auth_state.dart';

class AuthLoginScreen extends ConsumerWidget {
  const AuthLoginScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authProvider);
    final loginState = ref.watch(authFlowNotifierProvider);
    final loginNotifier = ref.read(authFlowNotifierProvider.notifier);

    ref.listen<AuthState>(authProvider, (previous, next) {
      if (next is AuthAuthenticated) {
        log("User authenticated.");
      } else if (next is AuthUnauthenticated && next.error != null) {
        log("Authentication error: ${next.error}");
      }
    });

    ref.listen<AsyncValue<void>>(authFlowNotifierProvider, (prev, next) {
      next.whenOrNull(
        data: (_) {
          log("Login flow completed successfully.");
          // Navigator.of(context).pushReplacementNamed('/home');
        },
        error: (err, _) {
          log("Login flow failed: $err");
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text("Login failed: $err")));
        },
      );
    });

    final isLoading = loginState is AsyncLoading;

    return Scaffold(
      backgroundColor: const Color(0xFF0B1C2C),
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 380),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.lock, color: Colors.white, size: 60),
                  const SizedBox(height: 16),
                  const Text(
                    'GateWise',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 12),
                  if (authState is AuthUnauthenticated &&
                      authState.error != null)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 16),
                      child: Text(
                        'Erro: ${authState.error}',
                        style: const TextStyle(color: Colors.redAccent),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  const Text(
                    'Acesse sua conta com segurança.',
                    style: TextStyle(color: Colors.white70, fontSize: 16),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 32),
                  SizedBox(
                    width: double.infinity,
                    height: 48,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF4D9EF6),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(24),
                        ),
                      ),
                      onPressed: isLoading
                          ? null
                          : () => loginNotifier.loginFlow(),
                      child: isLoading
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor: AlwaysStoppedAnimation<Color>(
                                  Colors.white,
                                ),
                              ),
                            )
                          : const Text(
                              'Entrar com GateWise',
                              style: TextStyle(
                                fontSize: 16,
                                color: Colors.white,
                              ),
                            ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
