import 'dart:async';

import 'package:ai_agent_launcher/app/app.dart';
import 'package:ai_agent_launcher/app/config/app_environment.dart';
import 'package:ai_agent_launcher/app/di/service_locator.dart';
import 'package:flutter/widgets.dart';

Future<void> bootstrap(AppEnvironment environment) async {
  WidgetsFlutterBinding.ensureInitialized();
  await configureDependencies(environment);
  runZonedGuarded(
    () => runApp(const LauncherApp()),
    appLogger.handle,
  );
}
