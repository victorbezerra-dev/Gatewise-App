import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../modules/authenticate/domain/interfaces/key_manager.dart';
import '../../modules/authenticate/infra/crypto/key_manager_impl.dart';

final keyManagerProvider = Provider<KeyManager>((ref) => KeyManagerImpl());
