abstract interface class SecureTokenStore {
  Future<void> save({
    required String accessToken,
    required String refreshToken,
  });
  Future<({String accessToken, String refreshToken})?> read();
  Future<void> clear();
}
