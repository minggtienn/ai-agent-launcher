import 'package:ai_agent_launcher/core/result/result.dart';
import 'package:ai_agent_launcher/features/authentication/domain/entities/user_session.dart';
import 'package:ai_agent_launcher/features/authentication/domain/repositories/auth_repository.dart';
import 'package:injectable/injectable.dart';

@injectable
final class SignIn {
  const SignIn(this._repository);
  final AuthRepository _repository;

  Future<Result<UserSession>> call({
    required String username,
    required String password,
  }) => _repository.signIn(username: username, password: password);
}
