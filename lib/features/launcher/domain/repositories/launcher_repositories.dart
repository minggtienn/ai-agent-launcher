import 'package:ai_agent_launcher/core/result/result.dart';
import 'package:ai_agent_launcher/features/launcher/domain/entities/application_manifest.dart';

abstract interface class InstallationRepository {
  Future<Result<InstalledApplication?>> findInstalled(String applicationId);
  Future<Result<InstalledApplication>> install(ApplicationManifest manifest);
  Future<Result<void>> rollback(String applicationId);
}

abstract interface class LaunchRepository {
  Future<Result<int>> launch(LaunchConfiguration configuration);
  Future<Result<bool>> isRunning(String applicationId);
}

abstract interface class FileIntegrityVerifier {
  Future<Result<void>> verify({
    required String filePath,
    required ApplicationManifest manifest,
  });
}

abstract interface class WindowsProcessService {
  Future<Result<int>> start(LaunchConfiguration configuration);
  Future<Result<bool>> isRunning(String executablePath);
}
