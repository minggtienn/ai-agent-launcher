import 'package:ai_agent_launcher/core/error/failure.dart';
import 'package:ai_agent_launcher/core/result/result.dart';
import 'package:ai_agent_launcher/features/authentication/domain/entities/user_session.dart';
import 'package:ai_agent_launcher/features/authentication/domain/usecases/restore_session.dart';
import 'package:ai_agent_launcher/features/authentication/domain/usecases/sign_in.dart';
import 'package:ai_agent_launcher/features/authentication/domain/usecases/sign_out.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';

sealed class SessionEvent {
  const SessionEvent();
}

final class SessionRestoreRequested extends SessionEvent {
  const SessionRestoreRequested();
}

final class SessionSignInRequested extends SessionEvent {
  const SessionSignInRequested(this.username, this.password);
  final String username;
  final String password;
}

final class SessionSignOutRequested extends SessionEvent {
  const SessionSignOutRequested();
}

sealed class SessionState {
  const SessionState();
}

final class SessionInitial extends SessionState {
  const SessionInitial();
}

final class SessionLoading extends SessionState {
  const SessionLoading();
}

final class SessionAnonymous extends SessionState {
  const SessionAnonymous();
}

final class SessionAuthenticated extends SessionState {
  const SessionAuthenticated(this.session);
  final UserSession session;
}

final class SessionFailure extends SessionState {
  const SessionFailure(this.failure);
  final Failure failure;
}

@injectable
final class SessionBloc extends Bloc<SessionEvent, SessionState> {
  SessionBloc(this._signIn, this._restoreSession, this._signOut)
    : super(const SessionInitial()) {
    on<SessionRestoreRequested>(_onRestore);
    on<SessionSignInRequested>(_onSignIn);
    on<SessionSignOutRequested>(_onSignOut);
  }

  final SignIn _signIn;
  final RestoreSession _restoreSession;
  final SignOut _signOut;

  Future<void> _onRestore(
    SessionRestoreRequested event,
    Emitter<SessionState> emit,
  ) async {
    emit(const SessionLoading());
    final result = await _restoreSession();
    switch (result) {
      case Success(value: final session):
        emit(
          session == null
              ? const SessionAnonymous()
              : SessionAuthenticated(session),
        );
      case FailureResult(:final error):
        emit(SessionFailure(error as Failure));
    }
  }

  Future<void> _onSignIn(
    SessionSignInRequested event,
    Emitter<SessionState> emit,
  ) async {
    emit(const SessionLoading());
    final result = await _signIn(
      username: event.username,
      password: event.password,
    );
    switch (result) {
      case Success(value: final session):
        emit(SessionAuthenticated(session));
      case FailureResult(:final error):
        emit(SessionFailure(error as Failure));
    }
  }

  Future<void> _onSignOut(
    SessionSignOutRequested event,
    Emitter<SessionState> emit,
  ) async {
    await _signOut();
    emit(const SessionAnonymous());
  }
}
