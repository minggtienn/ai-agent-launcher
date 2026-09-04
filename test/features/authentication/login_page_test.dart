import 'package:ai_agent_launcher/app/config/app_environment.dart';
import 'package:ai_agent_launcher/app/di/service_locator.dart';
import 'package:ai_agent_launcher/core/result/result.dart';
import 'package:ai_agent_launcher/features/authentication/domain/entities/user_session.dart';
import 'package:ai_agent_launcher/features/authentication/domain/repositories/auth_repository.dart';
import 'package:ai_agent_launcher/features/authentication/domain/usecases/restore_session.dart';
import 'package:ai_agent_launcher/features/authentication/domain/usecases/sign_in.dart';
import 'package:ai_agent_launcher/features/authentication/domain/usecases/sign_out.dart';
import 'package:ai_agent_launcher/features/authentication/presentation/bloc/session_bloc.dart';
import 'package:ai_agent_launcher/features/authentication/presentation/pages/login_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';

final class _FakeAuthRepository implements AuthRepository {
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
  setUp(() async {
    await serviceLocator.reset();
    serviceLocator.registerSingleton<AppConfig>(
      const AppConfig(
        environment: AppEnvironment.development,
        apiBaseUrl: 'https://example.invalid',
        launcherUpdateManifestUrl: '',
        launcherUpdatePublicKey: '',
        allowUnsignedUpdates: false,
      ),
    );
  });

  tearDown(serviceLocator.reset);

  testWidgets('shows the desktop login composition and validates password', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(1280, 720);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    final repository = _FakeAuthRepository();

    await tester.pumpWidget(
      BlocProvider(
        create: (_) => SessionBloc(
          SignIn(repository),
          RestoreSession(repository),
          SignOut(repository),
        ),
        child: const MaterialApp(home: LoginPage()),
      ),
    );

    expect(find.text('CHIẾN DỊCH\nTHẦN LONG'), findsOneWidget);
    expect(find.text('ĐĂNG NHẬP'), findsNWidgets(2));
    expect(find.text('ĐĂNG KÝ'), findsOneWidget);

    await tester.enterText(find.byKey(const Key('usernameField')), 'leader');
    await tester.enterText(find.byKey(const Key('passwordField')), '123');
    await tester.tap(find.byKey(const Key('loginButton')));
    await tester.pump();

    expect(find.text('Mật khẩu phải từ 6 đến 18 ký tự'), findsOneWidget);
  });
}
