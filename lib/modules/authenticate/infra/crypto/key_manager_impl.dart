import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:asn1lib/asn1lib.dart';
import 'package:pointycastle/export.dart';

import '../../../../core/infra/secure_storage.dart';
import '../../domain/interfaces/key_manager.dart';

class KeyManagerImpl implements KeyManager {
  static const _keySize = 2048;
  static const _exponent = '65537';

  @override
  Future<void> ensureKeyPairExists() async {
    debugPrint("[KeyManager] Checking if key pair exists...");
    final existingPrivateKey = await getPrivateKey();
    final existingPublicKey = await getPublicKey();

    if (existingPrivateKey != null && existingPublicKey != null) {
      debugPrint("[KeyManager] Existing key pair found.");
      return;
    }

    debugPrint("[KeyManager] Generating new RSA key pair...");
    final pair = _generateRSAKeyPair();
    final privateKey = pair.privateKey as RSAPrivateKey;
    final publicKey = pair.publicKey as RSAPublicKey;

    debugPrint("[KeyManager] Encoding private key to PEM...");
    final privatePem = _encodePrivateKeyToPem(privateKey);

    debugPrint("[KeyManager] Encoding public key to PEM...");
    final publicPem = _encodePublicKeyToPem(publicKey);

    debugPrint("[KeyManager] Saving keys to SecureStore...");
    await SecureStore.saveKeys(
      privateKeyPem: privatePem,
      publicKeyPem: publicPem,
    );

    debugPrint("[KeyManager] Key pair saved successfully.");
  }

  @override
  Future<String?> getPrivateKey() => SecureStore.privateKey;

  @override
  Future<String?> getPublicKey() => SecureStore.publicKey;

  AsymmetricKeyPair<PublicKey, PrivateKey> _generateRSAKeyPair() {
    final keyGen = RSAKeyGenerator()
      ..init(
        ParametersWithRandom(
          RSAKeyGeneratorParameters(BigInt.parse(_exponent), _keySize, 12),
          _secureRandom(),
        ),
      );

    return keyGen.generateKeyPair();
  }

  FortunaRandom _secureRandom() {
    final random = FortunaRandom();
    final seed = Uint8List.fromList(
      List<int>.generate(
        32,
        (_) => DateTime.now().millisecondsSinceEpoch % 256,
      ),
    );
    random.seed(KeyParameter(seed));
    return random;
  }

  String _encodePublicKeyToPem(RSAPublicKey publicKey) {
    try {
      debugPrint("[KeyManager] Building ASN1 public key sequence...");
      final algorithmSeq = ASN1Sequence()
        ..add(ASN1ObjectIdentifier.fromComponentString('1.2.840.113549.1.1.1'))
        ..add(ASN1Null());

      final publicKeySeq = ASN1Sequence()
        ..add(ASN1Integer(publicKey.modulus!))
        ..add(ASN1Integer(publicKey.exponent!));

      debugPrint("[KeyManager] Encoding publicKeySeq...");
      final encoded = publicKeySeq.encodedBytes;
      final publicKeyBitString = ASN1BitString(Uint8List.fromList(encoded));

      final topLevelSeq = ASN1Sequence()
        ..add(algorithmSeq)
        ..add(publicKeyBitString);

      debugPrint("[KeyManager] Public key ASN1 sequence created successfully.");
      return _pemWrap('PUBLIC KEY', topLevelSeq.encodedBytes);
    } catch (e, st) {
      debugPrint("[KeyManager] Error encoding public key: $e\n$st");
      rethrow;
    }
  }

  String _encodePrivateKeyToPem(RSAPrivateKey privateKey) {
    try {
      debugPrint("[KeyManager] Building ASN1 private key sequence...");
      final privateKeySeq = ASN1Sequence()
        ..add(ASN1Integer(BigInt.from(0)))
        ..add(ASN1Integer(privateKey.n!))
        ..add(ASN1Integer(privateKey.exponent!))
        ..add(ASN1Integer(privateKey.p!))
        ..add(ASN1Integer(privateKey.q!))
        ..add(ASN1Integer(privateKey.exponent! % (privateKey.p! - BigInt.one)))
        ..add(ASN1Integer(privateKey.exponent! % (privateKey.q! - BigInt.one)))
        ..add(ASN1Integer(privateKey.q!.modInverse(privateKey.p!)));

      final topLevelSeq = ASN1Sequence()..add(privateKeySeq);

      debugPrint(
        "[KeyManager] Private key ASN1 sequence created successfully.",
      );
      return _pemWrap('RSA PRIVATE KEY', topLevelSeq.encodedBytes);
    } catch (e, st) {
      debugPrint("[KeyManager] Error encoding private key: $e\n$st");
      rethrow;
    }
  }

  String _pemWrap(String label, List<int> bytes) {
    final base64String = base64.encode(bytes);
    final lines = RegExp(
      '.{1,64}',
    ).allMatches(base64String).map((m) => m.group(0)!);
    return '-----BEGIN $label-----\n${lines.join('\n')}\n-----END $label-----';
  }
}
