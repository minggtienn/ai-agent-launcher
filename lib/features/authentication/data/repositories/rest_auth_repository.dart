import 'package:ai_agent_launcher/core/error/failure.dart';
import 'package:ai_agent_launcher/core/result/result.dart';
import 'package:ai_agent_launcher/core/security/secure_token_store.dart';
import 'package:ai_agent_launcher/features/authentication/domain/entities/user_session.dart';
import 'package:ai_agent_launcher/features/authentication/domain/repositories/auth_repository.dart';
import 'package:dio/dio.dart';
import 'package:injectable/injectable.dart';

@LazySingleton(as: AuthRepository)
final class RestAuthRepository implements AuthRepository {
  const RestAuthRepository(this._client, this._tokenStore);

  final Dio _client;
  final SecureTokenStore _tokenStore;

  @override
  Future<Result<UserSession>> signIn({
    required String username,
    required String password,
  }) async {
    try {
      final response = await _client.post<Map<String, dynamic>>(
        '/auth/login',
        data: {'username': username, 'password': password},
      );
      final data = response.data;
      if (data == null) {
        return const FailureResult(
          Failure(FailureType.unknown, 'Empty response'),
        );
      }
      await _tokenStore.save(
        accessToken: data['accessToken'] as String,
        refreshToken: data['refreshToken'] as String,
      );
      return Success(
        UserSession(
          userId: data['userId'] as String,
          displayName: data['displayName'] as String? ?? username,
        ),
      );
    } on DioException catch (error) {
      final type = error.response?.statusCode == 401
          ? FailureType.unauthorized
          : FailureType.network;
      return FailureResult(
        Failure(
          type,
          'Unable to sign in',
          code: '${error.response?.statusCode ?? ''}',
        ),
      );
    } on Object {
      return const FailureResult(
        Failure(FailureType.unknown, 'Invalid authentication response'),
      );
    }
  }

  @override
  Future<Result<UserSession?>> restoreSession() async {
    try {
      final tokens = await _tokenStore.read();
      if (tokens == null) return const Success(null);
      final response = await _client.get<Map<String, dynamic>>(
        '/auth/session',
        options: Options(
          headers: {'Authorization': 'Bearer ${tokens.accessToken}'},
        ),
      );
      final data = response.data;
      if (data == null) return const Success(null);
      return Success(
        UserSession(
          userId: data['userId'] as String,
          displayName: data['displayName'] as String,
        ),
      );
    } on Object {
      await _tokenStore.clear();
      return const Success(null);
    }
  }

  @override
  Future<Result<void>> signOut() async {
    await _tokenStore.clear();
    return const Success(null);
  }
}
