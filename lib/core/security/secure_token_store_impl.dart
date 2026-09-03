import 'package:ai_agent_launcher/core/security/secure_token_store.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:injectable/injectable.dart';

@LazySingleton(as: SecureTokenStore)
final class SecureTokenStoreImpl implements SecureTokenStore {
  SecureTokenStoreImpl(this._storage);

  static const _accessKey = 'session.access_token';
  static const _refreshKey = 'session.refresh_token';
  final FlutterSecureStorage _storage;

  @override
  Future<void> clear() => _storage.deleteAll();

  @override
  Future<({String accessToken, String refreshToken})?> read() async {
    final accessToken = await _storage.read(key: _accessKey);
    final refreshToken = await _storage.read(key: _refreshKey);
    if (accessToken == null || refreshToken == null) return null;
    return (accessToken: accessToken, refreshToken: refreshToken);
  }

  @override
  Future<void> save({
    required String accessToken,
    required String refreshToken,
  }) async {
    await Future.wait([
      _storage.write(key: _accessKey, value: accessToken),
      _storage.write(key: _refreshKey, value: refreshToken),
    ]);
  }
}
