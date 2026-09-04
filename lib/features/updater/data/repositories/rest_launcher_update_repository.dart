import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:ai_agent_launcher/app/config/app_environment.dart';
import 'package:ai_agent_launcher/core/error/failure.dart';
import 'package:ai_agent_launcher/core/result/result.dart';
import 'package:ai_agent_launcher/features/updater/domain/entities/launcher_update.dart';
import 'package:ai_agent_launcher/features/updater/domain/repositories/launcher_update_repository.dart';
import 'package:ai_agent_launcher/features/updater/infrastructure/launcher_update_applier.dart';
import 'package:archive/archive_io.dart';
import 'package:crypto/crypto.dart';
import 'package:cryptography/cryptography.dart';
import 'package:dio/dio.dart';
import 'package:injectable/injectable.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:path/path.dart' as path;

@LazySingleton(as: LauncherUpdateRepository)
final class RestLauncherUpdateRepository implements LauncherUpdateRepository {
  const RestLauncherUpdateRepository(this._client, this._config, this._applier);

  final Dio _client;
  final AppConfig _config;
  final LauncherUpdateApplier _applier;

  @override
  Future<Result<LauncherUpdateManifest?>> checkForUpdate() async {
    if (_config.launcherUpdateManifestUrl.isEmpty) return const Success(null);
    try {
      final response = await _client.get<Map<String, dynamic>>(
        _config.launcherUpdateManifestUrl,
      );
      final data = response.data;
      if (data == null) {
        return const FailureResult(
          Failure(FailureType.unknown, 'Update manifest is empty'),
        );
      }
      final manifest = _parseManifest(data);
      final installed = AppVersion((await PackageInfo.fromPlatform()).version);
      return Success(
        manifest.version.compareTo(installed) > 0 ? manifest : null,
      );
    } on DioException catch (error) {
      return FailureResult(
        Failure(
          FailureType.network,
          'Không thể kiểm tra cập nhật',
          code: '${error.response?.statusCode ?? ''}',
        ),
      );
    } on Object catch (error) {
      return FailureResult(
        Failure(
          FailureType.unknown,
          'Manifest cập nhật không hợp lệ',
          code: '$error',
        ),
      );
    }
  }

  LauncherUpdateManifest _parseManifest(Map<String, dynamic> data) {
    return LauncherUpdateManifest(
      version: AppVersion(data['version'] as String),
      downloadUrl: Uri.parse(data['downloadUrl'] as String),
      size: data['size'] as int,
      sha256: data['sha256'] as String,
      signature: data['signature'] as String? ?? '',
      entryExecutable:
          data['entryExecutable'] as String? ?? 'ai_agent_launcher.exe',
      mandatory: data['mandatory'] as bool? ?? true,
      releaseNotes: (data['releaseNotes'] as List<dynamic>? ?? const [])
          .cast<String>(),
    );
  }

  @override
  Stream<Result<LauncherUpdateProgress>> downloadAndStage(
    LauncherUpdateManifest manifest,
  ) {
    final controller = StreamController<Result<LauncherUpdateProgress>>();
    unawaited(_downloadAndStage(manifest, controller));
    return controller.stream;
  }

  Future<void> _downloadAndStage(
    LauncherUpdateManifest manifest,
    StreamController<Result<LauncherUpdateProgress>> controller,
  ) async {
    try {
      final installDirectory = File(Platform.resolvedExecutable).parent;
      final workDirectory = Directory(
        path.join(installDirectory.parent.path, '.launcher-update'),
      );
      await workDirectory.create(recursive: true);
      final archiveFile = File(
        path.join(workDirectory.path, '${manifest.version.value}.zip.part'),
      );
      final existingBytes = await archiveFile.exists()
          ? await archiveFile.length()
          : 0;
      final response = await _client.download(
        manifest.downloadUrl.toString(),
        archiveFile.path,
        deleteOnError: false,
        options: Options(
          headers: existingBytes > 0
              ? {'Range': 'bytes=$existingBytes-'}
              : null,
        ),
        fileAccessMode: existingBytes > 0
            ? FileAccessMode.append
            : FileAccessMode.write,
        onReceiveProgress: (received, total) {
          final downloaded = existingBytes + received;
          controller.add(
            Success(
              LauncherUpdateProgress(
                stage: LauncherUpdateStage.downloading,
                receivedBytes: downloaded,
                totalBytes: manifest.size,
              ),
            ),
          );
        },
      );
      if (existingBytes > 0 &&
          response.statusCode != HttpStatus.partialContent) {
        await archiveFile.delete();
        await _client.download(
          manifest.downloadUrl.toString(),
          archiveFile.path,
          deleteOnError: false,
          onReceiveProgress: (received, total) {
            controller.add(
              Success(
                LauncherUpdateProgress(
                  stage: LauncherUpdateStage.downloading,
                  receivedBytes: received,
                  totalBytes: manifest.size,
                ),
              ),
            );
          },
        );
      }
      final length = await archiveFile.length();
      if (length != manifest.size) {
        throw const FormatException('Downloaded size does not match manifest');
      }
      controller.add(
        Success(
          LauncherUpdateProgress(
            stage: LauncherUpdateStage.verifying,
            receivedBytes: length,
            totalBytes: manifest.size,
          ),
        ),
      );
      final digest = await sha256.bind(archiveFile.openRead()).first;
      if (digest.toString().toLowerCase() != manifest.sha256.toLowerCase()) {
        throw const FormatException('SHA-256 verification failed');
      }
      await _verifySignature(manifest);
      final zipFile = File(
        path.join(workDirectory.path, '${manifest.version.value}.zip'),
      );
      if (await zipFile.exists()) {
        await zipFile.delete();
      }
      await archiveFile.rename(zipFile.path);
      final staged = Directory(
        path.join(
          installDirectory.parent.path,
          '.launcher-staging-${manifest.version.value}',
        ),
      );
      if (await staged.exists()) {
        await staged.delete(recursive: true);
      }
      await staged.create(recursive: true);
      controller.add(
        Success(
          LauncherUpdateProgress(
            stage: LauncherUpdateStage.extracting,
            receivedBytes: length,
            totalBytes: manifest.size,
          ),
        ),
      );
      await extractFileToDisk(zipFile.path, staged.path);
      final entry = File(path.join(staged.path, manifest.entryExecutable));
      if (!await entry.exists()) {
        throw const FormatException(
          'Launcher executable is missing from package',
        );
      }
      controller.add(
        Success(
          LauncherUpdateProgress(
            stage: LauncherUpdateStage.readyToApply,
            receivedBytes: length,
            totalBytes: manifest.size,
            stagedDirectory: staged.path,
          ),
        ),
      );
    } on Object catch (error) {
      controller.add(
        FailureResult(
          Failure(
            FailureType.integrity,
            'Không thể chuẩn bị bản cập nhật',
            code: '$error',
          ),
        ),
      );
    } finally {
      await controller.close();
    }
  }

  Future<void> _verifySignature(LauncherUpdateManifest manifest) async {
    if (_config.allowUnsignedUpdates && manifest.signature.isEmpty) return;
    if (_config.launcherUpdatePublicKey.isEmpty || manifest.signature.isEmpty) {
      throw const FormatException('Update signature configuration is missing');
    }
    final publicKey = SimplePublicKey(
      base64Decode(_config.launcherUpdatePublicKey),
      type: KeyPairType.ed25519,
    );
    final signature = Signature(
      base64Decode(manifest.signature),
      publicKey: publicKey,
    );
    final valid = await Ed25519().verify(
      utf8.encode(manifest.sha256.toLowerCase()),
      signature: signature,
    );
    if (!valid) {
      throw const FormatException('Update signature verification failed');
    }
  }

  @override
  Future<Result<void>> apply(
    LauncherUpdateManifest manifest,
    String stagedDirectory,
  ) => _applier.apply(manifest: manifest, stagedDirectory: stagedDirectory);
}
