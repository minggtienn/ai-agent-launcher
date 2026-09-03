final class LauncherSettings {
  const LauncherSettings({
    required this.launchAtStartup,
    required this.minimizeToTray,
    required this.installDirectory,
    required this.locale,
  });
  final bool launchAtStartup;
  final bool minimizeToTray;
  final String installDirectory;
  final String locale;
}
