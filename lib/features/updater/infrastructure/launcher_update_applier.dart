import 'dart:async';
import 'dart:io';

import 'package:ai_agent_launcher/core/error/failure.dart';
import 'package:ai_agent_launcher/core/result/result.dart';
import 'package:ai_agent_launcher/features/updater/domain/entities/launcher_update.dart';
import 'package:injectable/injectable.dart';
import 'package:path/path.dart' as path;

@lazySingleton
final class LauncherUpdateApplier {
  const LauncherUpdateApplier();

  Future<Result<void>> apply({
    required LauncherUpdateManifest manifest,
    required String stagedDirectory,
  }) async {
    if (!Platform.isWindows) {
      return const FailureResult(
        Failure(
          FailureType.system,
          'Launcher update can only be applied on Windows',
        ),
      );
    }
    try {
      final source = File(Platform.resolvedExecutable).parent;
      final runtime = await Directory.systemTemp.createTemp(
        'ai-agent-launcher-updater-',
      );
      await _copyDirectory(source, runtime);
      final helperExecutable = path.join(
        runtime.path,
        path.basename(Platform.resolvedExecutable),
      );
      final healthMarker = path.join(
        Directory.systemTemp.path,
        'launcher-health-${manifest.version.value}-${DateTime.now().millisecondsSinceEpoch}',
      );
      await Process.start(
        helperExecutable,
        [
          '--apply-launcher-update',
          '--source=${source.path}',
          '--staged=$stagedDirectory',
          '--entry=${manifest.entryExecutable}',
          '--health=$healthMarker',
        ],
        workingDirectory: runtime.path,
        mode: ProcessStartMode.detached,
      );
      unawaited(
        Future<void>.delayed(const Duration(milliseconds: 500), () => exit(0)),
      );
      return const Success(null);
    } on Object catch (error) {
      return FailureResult(
        Failure(
          FailureType.system,
          'Không thể khởi chạy tiến trình cập nhật',
          code: '$error',
        ),
      );
    }
  }

  static Future<bool> handleCommandLine(List<String> arguments) async {
    if (!arguments.contains('--apply-launcher-update')) return false;
    final values = <String, String>{};
    for (final argument in arguments.where(
      (value) => value.startsWith('--') && value.contains('='),
    )) {
      final separator = argument.indexOf('=');
      values[argument.substring(2, separator)] = argument.substring(
        separator + 1,
      );
    }
    final source = Directory(values['source'] ?? '');
    final staged = Directory(values['staged'] ?? '');
    final entry = values['entry'] ?? 'ai_agent_launcher.exe';
    final health = File(values['health'] ?? '');
    if (!await staged.exists() || source.path.isEmpty) {
      return true;
    }

    await Future<void>.delayed(const Duration(seconds: 2));
    final backup = Directory(
      '${source.path}.backup-${DateTime.now().millisecondsSinceEpoch}',
    );
    try {
      await _renameWithRetry(source, backup);
      await _renameWithRetry(staged, source);
      final process = await Process.start(
        path.join(source.path, entry),
        ['--update-health=${health.path}'],
        workingDirectory: source.path,
      );
      for (var attempt = 0; attempt < 60; attempt++) {
        if (await health.exists()) {
          return true;
        }
        await Future<void>.delayed(const Duration(milliseconds: 500));
      }
      process.kill();
      final failed = Directory(
        '${source.path}.failed-${DateTime.now().millisecondsSinceEpoch}',
      );
      await _renameWithRetry(source, failed);
      await _renameWithRetry(backup, source);
      await Process.start(
        path.join(source.path, entry),
        const [],
        workingDirectory: source.path,
        mode: ProcessStartMode.detached,
      );
    } on Object {
      if (!await source.exists() && await backup.exists()) {
        await _renameWithRetry(backup, source);
      }
    }
    return true;
  }

  static Future<void> writeHealthMarker(List<String> arguments) async {
    final argument = arguments
        .where((value) => value.startsWith('--update-health='))
        .firstOrNull;
    if (argument == null) return;
    final marker = File(argument.substring('--update-health='.length));
    await marker.writeAsString('ok', flush: true);
  }

  static Future<void> _renameWithRetry(
    Directory source,
    Directory target,
  ) async {
    Object? lastError;
    for (var attempt = 0; attempt < 40; attempt++) {
      try {
        await source.rename(target.path);
        return;
      } on Object catch (error) {
        lastError = error;
        await Future<void>.delayed(const Duration(milliseconds: 250));
      }
    }
    throw FileSystemException(
      'Unable to switch launcher directory',
      source.path,
      lastError is OSError ? lastError : null,
    );
  }

  static Future<void> _copyDirectory(Directory source, Directory target) async {
    await target.create(recursive: true);
    await for (final entity in source.list()) {
      final destination = path.join(target.path, path.basename(entity.path));
      if (entity is Directory) {
        await _copyDirectory(entity, Directory(destination));
      } else if (entity is File) {
        await entity.copy(destination);
      }
    }
  }
}
