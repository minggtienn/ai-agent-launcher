import 'package:ai_agent_launcher/core/result/result.dart';

final class AppVersion {
  const AppVersion(this.value);
  final String value;
}

abstract interface class LauncherUpdateRepository {
  Future<Result<AppVersion?>> checkForUpdate(String channel);
  Future<Result<void>> installUpdate(AppVersion version);
}
