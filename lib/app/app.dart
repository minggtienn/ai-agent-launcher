import 'package:ai_agent_launcher/app/di/service_locator.dart';
import 'package:ai_agent_launcher/app/router/app_router.dart';
import 'package:ai_agent_launcher/app/theme/app_theme.dart';
import 'package:ai_agent_launcher/features/authentication/presentation/bloc/session_bloc.dart';
import 'package:ai_agent_launcher/features/updater/presentation/bloc/launcher_update_bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

final class LauncherApp extends StatelessWidget {
  const LauncherApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (_) =>
              serviceLocator<SessionBloc>()
                ..add(const SessionRestoreRequested()),
        ),
        BlocProvider(
          create: (_) =>
              serviceLocator<LauncherUpdateBloc>()
                ..add(const LauncherUpdateCheckRequested()),
        ),
      ],
      child: MaterialApp.router(
        title: 'AI Agent Launcher',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.light,
        darkTheme: AppTheme.dark,
        routerConfig: appRouter,
        supportedLocales: const [Locale('en'), Locale('vi')],
        localizationsDelegates: const [
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
      ),
    );
  }
}
