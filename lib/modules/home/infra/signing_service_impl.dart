import 'dart:convert';
import 'dart:typed_data';

import 'package:asn1lib/asn1lib.dart';
import 'package:pointycastle/api.dart';
import 'package:pointycastle/asymmetric/api.dart';
import 'package:pointycastle/digests/sha256.dart';
import 'package:pointycastle/signers/rsa_signer.dart';

import '../domain/interfaces/signing_service.dart';
import '../../../core/infra/secure_storage.dart';

class RSASigningService implements SigningService {
  @override
  Future<String> signOpenLock(int timestamp) async {
    final privateKeyPem = await SecureStore.privateKey;
    if (privateKeyPem == null) throw Exception("Private key not found");

    final privateKey = _parsePrivateKeyFromPem(privateKeyPem);
    final message = utf8.encode('open:$timestamp');

    final signer = RSASigner(SHA256Digest(), '0609608648016503040201')
      ..init(true, PrivateKeyParameter<RSAPrivateKey>(privateKey));

    final signature = signer.generateSignature(Uint8List.fromList(message));
    return base64Encode(signature.bytes);
  }

  RSAPrivateKey _parsePrivateKeyFromPem(String pem) {
    final stripped = pem
        .replaceAll('-----BEGIN RSA PRIVATE KEY-----', '')
        .replaceAll('-----END RSA PRIVATE KEY-----', '')
        .replaceAll('\n', '')
        .replaceAll('\r', '');

    final bytes = base64.decode(stripped);
    final parser = ASN1Parser(Uint8List.fromList(bytes));
    final topLevel = parser.nextObject();

    final sequence = topLevel is ASN1Sequence && topLevel.elements.length == 1
        ? topLevel.elements.first as ASN1Sequence
        : topLevel as ASN1Sequence;

    final values = sequence.elements;
    if (values.length < 8) {
      throw FormatException(
        "Invalid RSA private key structure. Expected at least 8 elements, got ${values.length}",
      );
    }

    final n = (values[1] as ASN1Integer).valueAsBigInteger;
    final d = (values[2] as ASN1Integer).valueAsBigInteger;
    final p = (values[3] as ASN1Integer).valueAsBigInteger;
    final q = (values[4] as ASN1Integer).valueAsBigInteger;

    return RSAPrivateKey(n, d, p, q);
  }
}
