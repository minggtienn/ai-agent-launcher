enum AppEnvironment {
  development('dev'),
  staging('staging'),
  production('prod');

  const AppEnvironment(this.updateChannel);
  final String updateChannel;
}

final class AppConfig {
  const AppConfig({
    required this.environment,
    required this.apiBaseUrl,
    required this.launcherUpdateManifestUrl,
    required this.launcherUpdatePublicKey,
    required this.allowUnsignedUpdates,
  });

  factory AppConfig.fromEnvironment(AppEnvironment environment) {
    const apiBaseUrl = String.fromEnvironment(
      'API_BASE_URL',
      defaultValue: 'https://example.invalid',
    );
    const launcherUpdateManifestUrl = String.fromEnvironment(
      'LAUNCHER_UPDATE_MANIFEST_URL',
    );
    const launcherUpdatePublicKey = String.fromEnvironment(
      'LAUNCHER_UPDATE_PUBLIC_KEY',
    );
    const allowUnsignedUpdates = bool.fromEnvironment(
      'ALLOW_UNSIGNED_UPDATES',
    );
    return AppConfig(
      environment: environment,
      apiBaseUrl: apiBaseUrl,
      launcherUpdateManifestUrl: launcherUpdateManifestUrl,
      launcherUpdatePublicKey: launcherUpdatePublicKey,
      allowUnsignedUpdates: allowUnsignedUpdates,
    );
  }

  final AppEnvironment environment;
  final String apiBaseUrl;
  final String launcherUpdateManifestUrl;
  final String launcherUpdatePublicKey;
  final bool allowUnsignedUpdates;
}
