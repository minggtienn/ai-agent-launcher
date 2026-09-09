import 'dart:async';

import 'package:ai_agent_launcher/app/app.dart';
import 'package:ai_agent_launcher/app/config/app_environment.dart';
import 'package:ai_agent_launcher/app/di/service_locator.dart';
import 'package:ai_agent_launcher/features/updater/infrastructure/launcher_update_applier.dart';
import 'package:flutter/widgets.dart';
import 'package:window_manager/window_manager.dart';

Future<void> bootstrap(
  AppEnvironment environment,
  List<String> arguments,
) async {
  if (await LauncherUpdateApplier.handleCommandLine(arguments)) return;
  await configureDependencies(environment);
  await runZonedGuarded<Future<void>>(
    () async {
      WidgetsFlutterBinding.ensureInitialized();
      await windowManager.ensureInitialized();
      const windowOptions = WindowOptions(
        size: Size(440, 300),
        minimumSize: Size(440, 300),
        center: true,
        backgroundColor: Color(0x00000000),
        titleBarStyle: TitleBarStyle.hidden,
      );
      await windowManager.waitUntilReadyToShow(windowOptions, () async {
        await windowManager.show();
        await windowManager.focus();
      });
      await LauncherUpdateApplier.writeHealthMarker(arguments);
      runApp(const LauncherApp());
    },
    appLogger.handle,
  )!;
}
