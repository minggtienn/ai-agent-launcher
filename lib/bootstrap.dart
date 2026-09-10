import 'dart:async';

import 'package:ai_agent_launcher/app/app.dart';
import 'package:ai_agent_launcher/app/config/app_environment.dart';
import 'package:ai_agent_launcher/app/di/service_locator.dart';
import 'package:ai_agent_launcher/features/updater/infrastructure/launcher_update_applier.dart';
import 'package:bitsdojo_window/bitsdojo_window.dart';
import 'package:flutter/widgets.dart';

Future<void> bootstrap(
  AppEnvironment environment,
  List<String> arguments,
) async {
  if (await LauncherUpdateApplier.handleCommandLine(arguments)) return;
  await configureDependencies(environment);
  await runZonedGuarded<Future<void>>(
    () async {
      WidgetsFlutterBinding.ensureInitialized();
      await LauncherUpdateApplier.writeHealthMarker(arguments);
      runApp(const LauncherApp());
      doWhenWindowReady(() {
        const splashSize = Size(440, 300);
        appWindow
          ..minSize = splashSize
          ..size = splashSize
          ..alignment = Alignment.center
          ..show();
      });
    },
    appLogger.handle,
  )!;
}
