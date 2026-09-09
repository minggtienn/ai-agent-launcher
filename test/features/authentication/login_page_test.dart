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
import 'package:ai_agent_launcher/features/updater/domain/entities/launcher_update.dart';
import 'package:ai_agent_launcher/features/updater/domain/repositories/launcher_update_repository.dart';
import 'package:ai_agent_launcher/features/updater/presentation/bloc/launcher_update_bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:package_info_plus/package_info_plus.dart';

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

final class _FakeUpdateRepository implements LauncherUpdateRepository {
  @override
  Future<Result<void>> apply(
    LauncherUpdateManifest manifest,
    String stagedDirectory,
  ) async => const Success(null);

  @override
  Future<Result<LauncherUpdateManifest?>> checkForUpdate() async =>
      const Success(null);

  @override
  Stream<Result<LauncherUpdateProgress>> downloadAndStage(
    LauncherUpdateManifest manifest,
  ) => const Stream.empty();

  @override
  Future<Result<void>> repairFailedUpdate() async => const Success(null);
}

void main() {
  setUp(() async {
    PackageInfo.setMockInitialValues(
      appName: 'AI Agent Launcher',
      packageName: 'ai_agent_launcher',
      version: '1.2.3',
      buildNumber: '4',
      buildSignature: '',
    );
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
      MultiBlocProvider(
        providers: [
          BlocProvider(
            create: (_) => SessionBloc(
              SignIn(repository),
              RestoreSession(repository),
              SignOut(repository),
            ),
          ),
          BlocProvider(
            create: (_) => LauncherUpdateBloc(_FakeUpdateRepository()),
          ),
        ],
        child: const MaterialApp(home: LoginPage()),
      ),
    );
    await tester.pump();

    expect(find.text('CHIẾN DỊCH\nTHẦN LONG'), findsOneWidget);
    expect(find.text('ĐĂNG NHẬP'), findsNWidgets(2));
    expect(find.text('ĐĂNG KÝ'), findsOneWidget);
    expect(find.text('KIỂM TRA CẬP NHẬT LAUNCHER'), findsOneWidget);
    expect(find.text('Phiên bản: 1.2.3+4 • dev'), findsOneWidget);

    await tester.enterText(find.byKey(const Key('usernameField')), 'leader');
    await tester.enterText(find.byKey(const Key('passwordField')), '123');
    await tester.tap(find.byKey(const Key('loginButton')));
    await tester.pump();

    expect(find.text('Mật khẩu phải từ 6 đến 18 ký tự'), findsOneWidget);
  });
}
