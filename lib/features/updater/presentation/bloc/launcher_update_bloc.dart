import 'dart:async';

import 'package:ai_agent_launcher/core/error/failure.dart';
import 'package:ai_agent_launcher/core/result/result.dart';
import 'package:ai_agent_launcher/features/updater/domain/entities/launcher_update.dart';
import 'package:ai_agent_launcher/features/updater/domain/repositories/launcher_update_repository.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';

sealed class LauncherUpdateEvent {
  const LauncherUpdateEvent();
}

final class LauncherUpdateCheckRequested extends LauncherUpdateEvent {
  const LauncherUpdateCheckRequested();
}

final class LauncherUpdateStartRequested extends LauncherUpdateEvent {
  const LauncherUpdateStartRequested();
}

sealed class LauncherUpdateState {
  const LauncherUpdateState();
}

final class LauncherUpdateInitial extends LauncherUpdateState {
  const LauncherUpdateInitial();
}

final class LauncherUpdateChecking extends LauncherUpdateState {
  const LauncherUpdateChecking();
}

final class LauncherUpdateNotRequired extends LauncherUpdateState {
  const LauncherUpdateNotRequired();
}

final class LauncherUpdateAvailable extends LauncherUpdateState {
  const LauncherUpdateAvailable(this.manifest);
  final LauncherUpdateManifest manifest;
}

final class LauncherUpdateRunning extends LauncherUpdateState {
  const LauncherUpdateRunning(this.manifest, this.progress);
  final LauncherUpdateManifest manifest;
  final LauncherUpdateProgress progress;
}

final class LauncherUpdateRestarting extends LauncherUpdateState {
  const LauncherUpdateRestarting();
}

final class LauncherUpdateFailure extends LauncherUpdateState {
  const LauncherUpdateFailure(this.failure);
  final Failure failure;
}

@injectable
final class LauncherUpdateBloc
    extends Bloc<LauncherUpdateEvent, LauncherUpdateState> {
  LauncherUpdateBloc(this._repository) : super(const LauncherUpdateInitial()) {
    on<LauncherUpdateCheckRequested>(_onCheck);
    on<LauncherUpdateStartRequested>(_onStart);
  }

  final LauncherUpdateRepository _repository;

  Future<void> _onCheck(
    LauncherUpdateCheckRequested event,
    Emitter<LauncherUpdateState> emit,
  ) async {
    emit(const LauncherUpdateChecking());
    final result = await _repository.checkForUpdate();
    switch (result) {
      case Success(value: final manifest):
        emit(
          manifest == null
              ? const LauncherUpdateNotRequired()
              : LauncherUpdateAvailable(manifest),
        );
        if (manifest != null && manifest.mandatory) {
          add(const LauncherUpdateStartRequested());
        }
      case FailureResult(:final error):
        emit(LauncherUpdateFailure(error as Failure));
    }
  }

  Future<void> _onStart(
    LauncherUpdateStartRequested event,
    Emitter<LauncherUpdateState> emit,
  ) async {
    final current = state;
    if (current is! LauncherUpdateAvailable) return;
    final manifest = current.manifest;
    await emit.forEach<Result<LauncherUpdateProgress>>(
      _repository.downloadAndStage(manifest),
      onData: (result) {
        switch (result) {
          case Success(value: final progress):
            return LauncherUpdateRunning(manifest, progress);
          case FailureResult(:final error):
            return LauncherUpdateFailure(error as Failure);
        }
      },
    );
    final completed = state;
    if (completed is! LauncherUpdateRunning ||
        completed.progress.stage != LauncherUpdateStage.readyToApply) {
      return;
    }
    final stagedDirectory = completed.progress.stagedDirectory;
    if (stagedDirectory == null) return;
    final applied = await _repository.apply(manifest, stagedDirectory);
    switch (applied) {
      case Success():
        emit(const LauncherUpdateRestarting());
      case FailureResult(:final error):
        emit(LauncherUpdateFailure(error as Failure));
    }
  }
}
