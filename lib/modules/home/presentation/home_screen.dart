import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'home_notifier.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(labOpenNotifierProvider);
    final notifier = ref.read(labOpenNotifierProvider.notifier);
    final logoWidth = MediaQuery.of(context).size.width * 0.38;

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Center(
        child: state.when(
          loading: () => const CircularProgressIndicator(),
          error: (err, _) => Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.error, color: Colors.red, size: 48),
              const SizedBox(height: 8),
              Text('Erro: ${err.toString()}'),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () => notifier.openLab(),
                child: const Text('Tentar novamente'),
              ),
            ],
          ),
          data: (_) => Container(
            padding: EdgeInsets.symmetric(horizontal: 20),
            width: double.infinity,
            child: Column(
              children: [
                Transform.translate(
                  offset: const Offset(0, -30),
                  child: Image.asset(
                    'assets/images/gatewise-logo.png',
                    width: logoWidth,
                    fit: BoxFit.contain,
                  ),
                ),
                ElevatedButton(
                  onPressed: () => notifier.openLab(),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Color(0xFF217641),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 20,
                    ),
                  ),
                  child: SizedBox(
                    width: double.infinity,
                    child: Text(
                      'Entrar no laborátorio',
                      style: TextStyle(color: Colors.white),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
