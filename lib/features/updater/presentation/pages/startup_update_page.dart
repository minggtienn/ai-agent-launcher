import 'package:ai_agent_launcher/app/router/app_router.dart';
import 'package:ai_agent_launcher/features/authentication/presentation/widgets/launcher_brand.dart';
import 'package:ai_agent_launcher/features/authentication/presentation/widgets/window_controls.dart';
import 'package:ai_agent_launcher/features/updater/domain/entities/launcher_update.dart';
import 'package:ai_agent_launcher/features/updater/presentation/bloc/launcher_update_bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:window_manager/window_manager.dart';

final class StartupUpdatePage extends StatelessWidget {
  const StartupUpdatePage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocListener<LauncherUpdateBloc, LauncherUpdateState>(
      listener: (context, state) async {
        if (state is LauncherUpdateNotRequired) await _openLogin(context);
      },
      child: Scaffold(
        body: Column(
          children: [
            const DragToMoveArea(
              child: Align(
                alignment: Alignment.centerRight,
                child: WindowControls(),
              ),
            ),
            Expanded(
              child: BlocBuilder<LauncherUpdateBloc, LauncherUpdateState>(
                builder: (context, state) => _UpdateContent(state: state),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _openLogin(BuildContext context) async {
    await windowManager.setMinimumSize(const Size(980, 620));
    await windowManager.setSize(const Size(1280, 720), animate: true);
    await windowManager.center();
    if (context.mounted) context.go(AppRoutes.login);
  }
}

final class _UpdateContent extends StatelessWidget {
  const _UpdateContent({required this.state});
  final LauncherUpdateState state;

  @override
  Widget build(BuildContext context) {
    final progress = state is LauncherUpdateRunning
        ? (state as LauncherUpdateRunning).progress
        : null;
    return Padding(
      padding: const EdgeInsets.fromLTRB(44, 6, 44, 38),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Center(child: LauncherBrand()),
          const SizedBox(height: 38),
          Text(
            _title(state),
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 16),
          LinearProgressIndicator(
            value: progress?.stage == LauncherUpdateStage.downloading
                ? progress?.fraction
                : null,
            minHeight: 7,
            borderRadius: BorderRadius.circular(8),
            backgroundColor: const Color(0xFF252C38),
          ),
          const SizedBox(height: 12),
          Text(
            _detail(state),
            textAlign: TextAlign.center,
            style: const TextStyle(color: Colors.white54, fontSize: 12),
          ),
          if (state is LauncherUpdateAvailable &&
              !(state as LauncherUpdateAvailable).manifest.mandatory) ...[
            const SizedBox(height: 20),
            FilledButton(
              onPressed: () => context.read<LauncherUpdateBloc>().add(
                const LauncherUpdateStartRequested(),
              ),
              child: const Text('CẬP NHẬT NGAY'),
            ),
          ],
          if (state is LauncherUpdateFailure) ...[
            const SizedBox(height: 20),
            FilledButton(
              onPressed: () => context.read<LauncherUpdateBloc>().add(
                const LauncherUpdateCheckRequested(),
              ),
              child: const Text('THỬ LẠI'),
            ),
          ],
        ],
      ),
    );
  }

  String _title(LauncherUpdateState state) => switch (state) {
    LauncherUpdateInitial() ||
    LauncherUpdateChecking() => 'ĐANG KIỂM TRA CẬP NHẬT...',
    LauncherUpdateAvailable() => 'ĐÃ CÓ PHIÊN BẢN MỚI',
    LauncherUpdateRunning(:final progress) => switch (progress.stage) {
      LauncherUpdateStage.downloading =>
        'ĐANG TẢI BẢN CẬP NHẬT ${(progress.fraction * 100).clamp(0, 100).toStringAsFixed(0)}%',
      LauncherUpdateStage.verifying => 'ĐANG XÁC MINH BẢN CẬP NHẬT...',
      LauncherUpdateStage.extracting => 'ĐANG CHUẨN BỊ CÀI ĐẶT...',
      LauncherUpdateStage.readyToApply => 'ĐANG ÁP DỤNG BẢN CẬP NHẬT...',
      LauncherUpdateStage.checking => 'ĐANG KIỂM TRA CẬP NHẬT...',
    },
    LauncherUpdateRestarting() => 'ĐANG KHỞI ĐỘNG LẠI...',
    LauncherUpdateFailure() => 'CẬP NHẬT THẤT BẠI',
    LauncherUpdateNotRequired() => 'LAUNCHER ĐÃ LÀ PHIÊN BẢN MỚI NHẤT',
  };

  String _detail(LauncherUpdateState state) => switch (state) {
    LauncherUpdateRunning(:final progress)
        when progress.stage == LauncherUpdateStage.downloading =>
      '${_bytes(progress.receivedBytes)} / ${_bytes(progress.totalBytes)}',
    LauncherUpdateAvailable(:final manifest) =>
      'Phiên bản ${manifest.version.value}',
    LauncherUpdateFailure(:final failure) => failure.message,
    _ => 'Vui lòng không tắt launcher',
  };

  String _bytes(int bytes) {
    if (bytes >= 1073741824) {
      return '${(bytes / 1073741824).toStringAsFixed(1)} GB';
    }
    if (bytes >= 1048576) return '${(bytes / 1048576).toStringAsFixed(1)} MB';
    return '${(bytes / 1024).toStringAsFixed(1)} KB';
  }
}
