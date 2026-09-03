import 'package:ai_agent_launcher/core/result/result.dart';
import 'package:ai_agent_launcher/features/authentication/domain/entities/user_session.dart';
import 'package:ai_agent_launcher/features/authentication/domain/repositories/auth_repository.dart';
import 'package:ai_agent_launcher/features/authentication/domain/usecases/restore_session.dart';
import 'package:ai_agent_launcher/features/authentication/domain/usecases/sign_in.dart';
import 'package:ai_agent_launcher/features/authentication/domain/usecases/sign_out.dart';
import 'package:ai_agent_launcher/features/authentication/presentation/bloc/session_bloc.dart';
import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';

final class FakeAuthRepository implements AuthRepository {
  @override
  Future<Result<UserSession?>> restoreSession() async => const Success(null);

  @override
  Future<Result<UserSession>> signIn({
    required String username,
    required String password,
  }) async => Success(UserSession(userId: '1', displayName: username));

  @override
  Future<Result<void>> signOut() async => const Success(null);
}

void main() {
  final repository = FakeAuthRepository();

  blocTest<SessionBloc, SessionState>(
    'restores an anonymous session',
    build: () => SessionBloc(
      SignIn(repository),
      RestoreSession(repository),
      SignOut(repository),
    ),
    act: (bloc) => bloc.add(const SessionRestoreRequested()),
    expect: () => [isA<SessionLoading>(), isA<SessionAnonymous>()],
  );

  blocTest<SessionBloc, SessionState>(
    'signs in and emits authenticated state',
    build: () => SessionBloc(
      SignIn(repository),
      RestoreSession(repository),
      SignOut(repository),
    ),
    act: (bloc) => bloc.add(const SessionSignInRequested('leader', 'secret')),
    expect: () => [isA<SessionLoading>(), isA<SessionAuthenticated>()],
  );
}
