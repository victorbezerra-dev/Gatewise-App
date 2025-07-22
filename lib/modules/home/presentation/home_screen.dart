import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'home_notifier.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(
      () => ref.read(homeNotifierProvider.notifier).fetchAccessGrants(),
    );
  }

  String getStatusText(AccessStatusUi status) {
    switch (status) {
      case AccessStatusUi.pendingRequest:
        return 'Pendente de requisição';
      case AccessStatusUi.pending:
        return 'Pendente';
      case AccessStatusUi.granted:
        return 'Autorizado';
      case AccessStatusUi.rejected:
        return 'Rejeitado';
    }
  }

  ({Color color, String text, VoidCallback? onPressed}) getButtonProps(
    AccessStatusUi status,
    HomeNotifier notifier,
    HomeState state,
  ) {
    switch (status) {
      case AccessStatusUi.granted:
        return (
          color: const Color(0xFF217641),
          text: 'Entrar no laboratório',
          onPressed: () => notifier.openLab(),
        );
      case AccessStatusUi.pendingRequest:
        return (
          color: Colors.blue,
          text: 'Solicitar acesso',
          onPressed: state.requestAccessStatus.isLoading
              ? null
              : () => notifier.requestAccess(),
        );
      case AccessStatusUi.rejected:
        return (
          color: Colors.grey,
          text: 'Solicitação de Acesso Rejeitada',
          onPressed: null,
        );
      case AccessStatusUi.pending:
        return (
          color: Colors.grey,
          text: 'Aguardando aprovação',
          onPressed: null,
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(homeNotifierProvider);
    final notifier = ref.read(homeNotifierProvider.notifier);
    final logoWidth = MediaQuery.of(context).size.width * 0.38;

    final buttonProps = getButtonProps(state.accessStatus, notifier, state);

    Widget buildMainButton() {
      final isLoading =
          state.accessStatus == AccessStatusUi.pendingRequest &&
          state.requestAccessStatus.isLoading;
      return ElevatedButton(
        onPressed: buttonProps.onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: buttonProps.color,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
        ),
        child: SizedBox(
          width: double.infinity,
          child: isLoading
              ? Center(
                  child: const SizedBox(
                    height: 20,
                    width: 20,
                    child: CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      strokeWidth: 2.3,
                    ),
                  ),
                )
              : Text(
                  buttonProps.text,
                  style: const TextStyle(color: Colors.white),
                  textAlign: TextAlign.center,
                ),
        ),
      );
    }

    Widget buildContent() {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Laboratório: Automação 66',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 5),
          RichText(
            text: TextSpan(
              children: [
                const TextSpan(
                  text: 'Status: ',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                TextSpan(
                  text: getStatusText(state.accessStatus),
                  style: TextStyle(
                    fontSize: 16,
                    color: state.accessStatus == AccessStatusUi.rejected
                        ? Colors.red
                        : Colors.white70,
                    fontWeight: FontWeight.normal,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          state.openLabStatus.when(
            loading: () => const CircularProgressIndicator(),
            error: (err, _) => Column(
              children: [
                const Icon(Icons.error, color: Colors.red, size: 48),
                const SizedBox(height: 8),
                Text('Erro: ${err.toString()}'),
                const SizedBox(height: 16),
                buildMainButton(),
              ],
            ),
            data: (_) => buildMainButton(),
          ),
        ],
      );
    }

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Transform.translate(
            offset: const Offset(0, -30),
            child: Center(
              child: Image.asset(
                'assets/images/gatewise-logo.png',
                width: logoWidth,
                fit: BoxFit.contain,
              ),
            ),
          ),
          Expanded(
            child: Transform.translate(
              offset: const Offset(0, -40),
              child: RefreshIndicator(
                onRefresh: () async => await notifier.fetchAccessGrants(),
                child: SingleChildScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  child: buildContent(),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
