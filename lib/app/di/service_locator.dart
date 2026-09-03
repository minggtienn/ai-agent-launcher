import 'package:ai_agent_launcher/app/config/app_environment.dart';
import 'package:ai_agent_launcher/app/di/service_locator.config.dart';
import 'package:get_it/get_it.dart';
import 'package:injectable/injectable.dart';
import 'package:talker_flutter/talker_flutter.dart';

final GetIt serviceLocator = GetIt.instance;
Talker get appLogger => serviceLocator<Talker>();

@InjectableInit(ignoreUnregisteredTypes: [AppConfig])
Future<void> configureDependencies(AppEnvironment environment) async {
  await GetIt.instance.reset();
  serviceLocator
    ..registerSingleton<AppConfig>(AppConfig.fromEnvironment(environment))
    ..init(environment: environment.updateChannel);
}
