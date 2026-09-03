import 'dart:async';

import 'package:ai_agent_launcher/app/app.dart';
import 'package:ai_agent_launcher/app/config/app_environment.dart';
import 'package:ai_agent_launcher/app/di/service_locator.dart';
import 'package:flutter/widgets.dart';
import 'package:window_manager/window_manager.dart';

Future<void> bootstrap(AppEnvironment environment) async {
  WidgetsFlutterBinding.ensureInitialized();
  await configureDependencies(environment);
  await windowManager.ensureInitialized();
  const windowOptions = WindowOptions(
    size: Size(1280, 720),
    minimumSize: Size(980, 620),
    center: true,
    backgroundColor: Color(0xFF10141D),
    titleBarStyle: TitleBarStyle.hidden,
  );
  await windowManager.waitUntilReadyToShow(windowOptions, () async {
    await windowManager.show();
    await windowManager.focus();
  });
  runZonedGuarded(
    () => runApp(const LauncherApp()),
    appLogger.handle,
  );
}
