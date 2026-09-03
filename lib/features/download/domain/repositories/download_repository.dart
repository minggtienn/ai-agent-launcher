import 'package:ai_agent_launcher/core/result/result.dart';
import 'package:ai_agent_launcher/features/download/domain/entities/download_task.dart';

abstract interface class DownloadRepository {
  Stream<DownloadProgress> download(DownloadTask task);
  Future<Result<void>> pause(String taskId);
  Future<Result<void>> resume(String taskId);
  Future<Result<void>> cancel(String taskId);
}
