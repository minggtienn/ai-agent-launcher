import 'package:ai_agent_launcher/app/config/app_environment.dart';
import 'package:ai_agent_launcher/bootstrap.dart';

Future<void> main(List<String> arguments) =>
    bootstrap(AppEnvironment.staging, arguments);
