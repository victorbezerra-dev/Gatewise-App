import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/providers/custom_http_client_provider.dart';
import '../domain/entities/open_lab_request.dart';
import '../domain/interfaces/signing_service.dart';
import '../domain/value_objects/access_grant_status_vo.dart';
import '../infra/lab_repository.dart';
import 'rsa_signing_service_provider.dart';

enum AccessStatusUi { pendingRequest, pending, granted, rejected }

class HomeState {
  final AccessStatusUi accessStatus;
  final AsyncValue<void> openLabStatus;
  final AsyncValue<void> requestAccessStatus;

  HomeState({
    required this.accessStatus,
    required this.openLabStatus,
    required this.requestAccessStatus,
  });

  HomeState copyWith({
    AccessStatusUi? accessStatus,
    AsyncValue<void>? openLabStatus,
    AsyncValue<void>? requestAccessStatus,
  }) {
    return HomeState(
      accessStatus: accessStatus ?? this.accessStatus,
      openLabStatus: openLabStatus ?? this.openLabStatus,
      requestAccessStatus: requestAccessStatus ?? this.requestAccessStatus,
    );
  }
}

final labRepositoryProvider = Provider<LabRepository>(
  (ref) => LabRepository(ref.read(customHttpClientProvider)),
);
final homeNotifierProvider = StateNotifierProvider<HomeNotifier, HomeState>(
  (ref) => HomeNotifier(
    ref.read(labRepositoryProvider),
    ref.read(signingServiceProvider),
  ),
);

class HomeNotifier extends StateNotifier<HomeState> {
  final LabRepository _repository;
  final SigningService _signingService;

  HomeNotifier(this._repository, this._signingService)
    : super(
        HomeState(
          accessStatus: AccessStatusUi.pendingRequest,
          openLabStatus: const AsyncData(null),
          requestAccessStatus: const AsyncData(null),
        ),
      );

  Future<void> fetchAccessGrants() async {
    try {
      await Future.delayed(Duration(seconds: 1));
      final grants = await _repository.getAccessGrants();
      AccessStatusUi status;
      if (grants.isEmpty) {
        status = AccessStatusUi.pendingRequest;
      } else {
        switch (grants.first.status) {
          case AccessGrantStatusVO.pending:
            status = AccessStatusUi.pending;
            break;
          case AccessGrantStatusVO.granted:
            status = AccessStatusUi.granted;
            break;
          case AccessGrantStatusVO.rejected:
            status = AccessStatusUi.rejected;
            break;
        }
      }
      state = state.copyWith(accessStatus: status);
    } catch (_) {
      state = state.copyWith(accessStatus: AccessStatusUi.pendingRequest);
    }
  }

  Future<void> requestAccess() async {
    try {
      state = state.copyWith(requestAccessStatus: const AsyncLoading());
      await Future.delayed(Duration(seconds: 1));
      await _repository.requestAccess();
      state = state.copyWith(requestAccessStatus: const AsyncData(null));
      state = state.copyWith(accessStatus: AccessStatusUi.pending);
    } catch (e) {
      state = state.copyWith(accessStatus: AccessStatusUi.pendingRequest);
    }
  }

  Future<void> openLab() async {
    state = state.copyWith(openLabStatus: const AsyncLoading());
    try {
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final signature = await _signingService.signOpenLock(timestamp);

      final request = OpenLabRequest(
        timestamp: timestamp,
        signature: signature,
      );

      await _repository.openLab(request: request);
      state = state.copyWith(openLabStatus: const AsyncData(null));
    } catch (e, st) {
      state = state.copyWith(openLabStatus: AsyncError(e, st));
    }
  }
}
