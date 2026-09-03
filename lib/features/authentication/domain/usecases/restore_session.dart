import 'package:ai_agent_launcher/core/result/result.dart';
import 'package:ai_agent_launcher/features/authentication/domain/entities/user_session.dart';
import 'package:ai_agent_launcher/features/authentication/domain/repositories/auth_repository.dart';
import 'package:injectable/injectable.dart';

@injectable
final class RestoreSession {
  const RestoreSession(this._repository);
  final AuthRepository _repository;

  Future<Result<UserSession?>> call() => _repository.restoreSession();
}
