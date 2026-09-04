import 'package:ai_agent_launcher/core/result/result.dart';
import 'package:ai_agent_launcher/features/updater/domain/entities/launcher_update.dart';

abstract interface class LauncherUpdateRepository {
  Future<Result<LauncherUpdateManifest?>> checkForUpdate();

  Stream<Result<LauncherUpdateProgress>> downloadAndStage(
    LauncherUpdateManifest manifest,
  );

  Future<Result<void>> apply(
    LauncherUpdateManifest manifest,
    String stagedDirectory,
  );
}
