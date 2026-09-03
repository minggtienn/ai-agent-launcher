import 'package:ai_agent_launcher/core/result/result.dart';
import 'package:ai_agent_launcher/features/authentication/domain/entities/user_session.dart';

abstract interface class AuthRepository {
  Future<Result<UserSession>> signIn({
    required String username,
    required String password,
  });
  Future<Result<UserSession?>> restoreSession();
  Future<Result<void>> signOut();
}
