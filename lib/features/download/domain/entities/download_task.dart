enum DownloadStatus {
  queued,
  downloading,
  paused,
  verifying,
  completed,
  failed,
  cancelled,
}

final class DownloadTask {
  const DownloadTask({
    required this.id,
    required this.url,
    required this.targetPath,
    required this.status,
  });
  final String id;
  final Uri url;
  final String targetPath;
  final DownloadStatus status;
}

final class DownloadProgress {
  const DownloadProgress({
    required this.receivedBytes,
    required this.totalBytes,
  });
  final int receivedBytes;
  final int totalBytes;
  double get fraction => totalBytes == 0 ? 0 : receivedBytes / totalBytes;
}
