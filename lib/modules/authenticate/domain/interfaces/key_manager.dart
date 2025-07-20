abstract class KeyManager {
  Future<void> ensureKeyPairExists();
  Future<String?> getPublicKey();
  Future<String?> getPrivateKey();
}
