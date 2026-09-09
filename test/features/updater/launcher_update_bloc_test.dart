import 'package:ai_agent_launcher/core/result/result.dart';
import 'package:ai_agent_launcher/features/updater/domain/entities/launcher_update.dart';
import 'package:ai_agent_launcher/features/updater/domain/repositories/launcher_update_repository.dart';
import 'package:ai_agent_launcher/features/updater/presentation/bloc/launcher_update_bloc.dart';
import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';

final class _FakeUpdateRepository implements LauncherUpdateRepository {
  _FakeUpdateRepository(this.manifest);
  final LauncherUpdateManifest? manifest;
  int repairCalls = 0;
  int downloadCalls = 0;

  @override
  Future<Result<LauncherUpdateManifest?>> checkForUpdate() async =>
      Success(manifest);

  @override
  Stream<Result<LauncherUpdateProgress>> downloadAndStage(
    LauncherUpdateManifest manifest,
  ) {
    downloadCalls++;
    return const Stream.empty();
  }

  @override
  Future<Result<void>> apply(
    LauncherUpdateManifest manifest,
    String stagedDirectory,
  ) async => const Success(null);

  @override
  Future<Result<void>> repairFailedUpdate() async {
    repairCalls++;
    return const Success(null);
  }
}

void main() {
  late _FakeUpdateRepository repairRepository;

  test('AppVersion compares semantic numeric parts', () {
    expect(
      const AppVersion('1.10.0').compareTo(const AppVersion('1.9.9')),
      greaterThan(0),
    );
    expect(const AppVersion('1.0.0+2').compareTo(const AppVersion('1.0.0')), 0);
  });

  blocTest<LauncherUpdateBloc, LauncherUpdateState>(
    'continues when no launcher update exists',
    build: () => LauncherUpdateBloc(_FakeUpdateRepository(null)),
    act: (bloc) => bloc.add(const LauncherUpdateCheckRequested()),
    expect: () => [
      isA<LauncherUpdateChecking>(),
      isA<LauncherUpdateNotRequired>(),
    ],
  );

  blocTest<LauncherUpdateBloc, LauncherUpdateState>(
    'automatically starts an available launcher update',
    build: () {
      final repository = _FakeUpdateRepository(
        LauncherUpdateManifest(
          version: const AppVersion('2.0.0'),
          downloadUrl: Uri.parse('https://example.invalid/launcher.zip'),
          size: 10,
          sha256: 'hash',
          signature: 'signature',
          entryExecutable: 'ai_agent_launcher.exe',
          mandatory: false,
          releaseNotes: const [],
        ),
      );
      repairRepository = repository;
      return LauncherUpdateBloc(repository);
    },
    act: (bloc) => bloc.add(const LauncherUpdateCheckRequested()),
    expect: () => [
      isA<LauncherUpdateChecking>(),
      isA<LauncherUpdateAvailable>(),
    ],
    verify: (_) => expect(repairRepository.downloadCalls, 1),
  );

  blocTest<LauncherUpdateBloc, LauncherUpdateState>(
    'repairs failed update data and checks again',
    build: () {
      repairRepository = _FakeUpdateRepository(null);
      return LauncherUpdateBloc(repairRepository);
    },
    act: (bloc) => bloc.add(const LauncherUpdateRepairRequested()),
    expect: () => [
      isA<LauncherUpdateChecking>(),
      isA<LauncherUpdateNotRequired>(),
    ],
    verify: (_) => expect(repairRepository.repairCalls, 1),
  );
}
