enum AppEnvironment {
  development('dev'),
  staging('staging'),
  production('prod');

  const AppEnvironment(this.updateChannel);
  final String updateChannel;
}

final class AppConfig {
  const AppConfig({required this.environment, required this.apiBaseUrl});

  factory AppConfig.fromEnvironment(AppEnvironment environment) {
    const apiBaseUrl = String.fromEnvironment(
      'API_BASE_URL',
      defaultValue: 'https://example.invalid',
    );
    return AppConfig(environment: environment, apiBaseUrl: apiBaseUrl);
  }

  final AppEnvironment environment;
  final String apiBaseUrl;
}
