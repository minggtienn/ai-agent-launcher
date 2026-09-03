import 'package:ai_agent_launcher/core/result/result.dart';
import 'package:ai_agent_launcher/features/settings/domain/entities/launcher_settings.dart';

abstract interface class SettingsRepository {
  Future<Result<LauncherSettings>> load();
  Future<Result<void>> save(LauncherSettings settings);
}
