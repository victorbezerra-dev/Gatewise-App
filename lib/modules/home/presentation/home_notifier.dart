import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/providers/custom_http_client_provider.dart';
import '../domain/entities/open_lab_request.dart';
import '../domain/interfaces/signing_service.dart';
import '../infra/lab_repository.dart';
import 'rsa_signing_service_provider.dart';

final labRepositoryProvider = Provider<LabRepository>(
  (ref) => LabRepository(ref.read(customHttpClientProvider)),
);

final labOpenNotifierProvider =
    StateNotifierProvider<LabOpenNotifier, AsyncValue<void>>(
      (ref) => LabOpenNotifier(
        ref.read(labRepositoryProvider),
        ref.read(signingServiceProvider),
      ),
    );

class LabOpenNotifier extends StateNotifier<AsyncValue<void>> {
  final LabRepository _repository;
  final SigningService _signingService;

  LabOpenNotifier(this._repository, this._signingService)
    : super(const AsyncData(null));

  Future<void> openLab() async {
    state = const AsyncLoading();
    try {
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final signature = await _signingService.signOpenLock(timestamp);

      final request = OpenLabRequest(
        timestamp: timestamp,
        signature: signature,
      );

      await _repository.openLab(request: request);
      state = const AsyncData(null);
    } catch (e, st) {
      state = AsyncError(e, st);
    }
  }
}
