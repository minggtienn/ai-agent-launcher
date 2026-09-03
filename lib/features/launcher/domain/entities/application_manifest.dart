final class ApplicationManifest {
  const ApplicationManifest({
    required this.applicationId,
    required this.version,
    required this.downloadUrl,
    required this.size,
    required this.sha256,
    required this.signature,
  });
  final String applicationId;
  final String version;
  final Uri downloadUrl;
  final int size;
  final String sha256;
  final String signature;
}

final class InstalledApplication {
  const InstalledApplication({
    required this.applicationId,
    required this.version,
    required this.installPath,
  });
  final String applicationId;
  final String version;
  final String installPath;
}

final class LaunchConfiguration {
  const LaunchConfiguration({
    required this.executablePath,
    this.arguments = const [],
  });
  final String executablePath;
  final List<String> arguments;
}
