enum LauncherUpdateStage {
  checking,
  downloading,
  verifying,
  extracting,
  readyToApply,
}

final class AppVersion implements Comparable<AppVersion> {
  const AppVersion(this.value);
  final String value;

  List<int> get _parts => value
      .split('+')
      .first
      .split('-')
      .first
      .split('.')
      .map((part) => int.tryParse(part) ?? 0)
      .toList();

  @override
  int compareTo(AppVersion other) {
    final length = _parts.length > other._parts.length
        ? _parts.length
        : other._parts.length;
    for (var index = 0; index < length; index++) {
      final left = index < _parts.length ? _parts[index] : 0;
      final right = index < other._parts.length ? other._parts[index] : 0;
      if (left != right) return left.compareTo(right);
    }
    return 0;
  }
}

final class LauncherUpdateManifest {
  const LauncherUpdateManifest({
    required this.version,
    required this.downloadUrl,
    required this.size,
    required this.sha256,
    required this.signature,
    required this.entryExecutable,
    required this.mandatory,
    required this.releaseNotes,
  });

  final AppVersion version;
  final Uri downloadUrl;
  final int size;
  final String sha256;
  final String signature;
  final String entryExecutable;
  final bool mandatory;
  final List<String> releaseNotes;
}

final class LauncherUpdateProgress {
  const LauncherUpdateProgress({
    required this.stage,
    required this.receivedBytes,
    required this.totalBytes,
    this.stagedDirectory,
  });

  final LauncherUpdateStage stage;
  final int receivedBytes;
  final int totalBytes;
  final String? stagedDirectory;
  double get fraction => totalBytes <= 0 ? 0 : receivedBytes / totalBytes;
}
