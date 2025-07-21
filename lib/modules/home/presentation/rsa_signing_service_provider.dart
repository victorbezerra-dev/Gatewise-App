import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../domain/interfaces/signing_service.dart';
import '../infra/signing_service_impl.dart';

final signingServiceProvider = Provider<SigningService>(
  (ref) => RSASigningService(),
);
