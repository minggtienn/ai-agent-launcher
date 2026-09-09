import 'dart:async';

import 'package:ai_agent_launcher/app/router/app_router.dart';
import 'package:ai_agent_launcher/features/authentication/presentation/widgets/window_controls.dart';
import 'package:ai_agent_launcher/features/updater/domain/entities/launcher_update.dart';
import 'package:ai_agent_launcher/features/updater/presentation/bloc/launcher_update_bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:window_manager/window_manager.dart';

final class StartupUpdatePage extends StatefulWidget {
  const StartupUpdatePage({super.key});

  @override
  State<StartupUpdatePage> createState() => _StartupUpdatePageState();
}

final class _StartupUpdatePageState extends State<StartupUpdatePage> {
  static const logoTravelDuration = Duration(milliseconds: 1200);
  static const backgroundHoldDuration = Duration(seconds: 2);
  bool _backgroundVisible = false;
  bool _introComplete = false;
  bool _openingLogin = false;

  @override
  void initState() {
    super.initState();
    unawaited(_runIntro());
  }

  Future<void> _runIntro() async {
    await Future<void>.delayed(logoTravelDuration);
    if (!mounted) return;
    await windowManager.setBackgroundColor(const Color(0xFF090D14));
    setState(() => _backgroundVisible = true);
    await Future<void>.delayed(backgroundHoldDuration);
    if (!mounted) return;
    setState(() => _introComplete = true);
    if (context.read<LauncherUpdateBloc>().state is LauncherUpdateNotRequired) {
      await _openLoginOnce();
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<LauncherUpdateBloc, LauncherUpdateState>(
      listener: (_, state) {
        if (state is LauncherUpdateNotRequired && _introComplete) {
          unawaited(_openLoginOnce());
        }
      },
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          color: _backgroundVisible
              ? const Color(0xFF090D14)
              : Colors.transparent,
          child: _introComplete
              ? Column(
                  children: [
                    const LauncherTitleBar(),
                    Expanded(
                      child:
                          BlocBuilder<LauncherUpdateBloc, LauncherUpdateState>(
                            builder: (_, state) {
                              if (state is LauncherUpdateInitial ||
                                  state is LauncherUpdateChecking ||
                                  state is LauncherUpdateNotRequired) {
                                return const Center(child: _StartupBrand());
                              }
                              return _UpdateContent(state: state);
                            },
                          ),
                    ),
                  ],
                )
              : _SplashContent(backgroundVisible: _backgroundVisible),
        ),
      ),
    );
  }

  Future<void> _openLoginOnce() async {
    if (_openingLogin) return;
    _openingLogin = true;
    await windowManager.setMinimumSize(const Size(980, 620));
    await windowManager.setSize(const Size(1280, 720), animate: true);
    await windowManager.center();
    if (mounted) context.go(AppRoutes.login);
  }
}

final class _SplashContent extends StatelessWidget {
  const _SplashContent({required this.backgroundVisible});
  final bool backgroundVisible;

  @override
  Widget build(BuildContext context) => AnimatedSwitcher(
    duration: const Duration(milliseconds: 300),
    child: backgroundVisible
        ? const Center(key: ValueKey('background'), child: _StartupBrand())
        : const _RevealedStartupBrand(key: ValueKey('reveal')),
  );
}

final class _RevealedStartupBrand extends StatefulWidget {
  const _RevealedStartupBrand({super.key});

  @override
  State<_RevealedStartupBrand> createState() => _RevealedStartupBrandState();
}

final class _RevealedStartupBrandState extends State<_RevealedStartupBrand>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _progress;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: _StartupUpdatePageState.logoTravelDuration,
    );
    _progress = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOutCubic,
    );
    unawaited(_controller.forward());
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Center(
    child: AnimatedBuilder(
      animation: _progress,
      child: const _StartupBrand(),
      builder: (_, child) => ClipRect(
        clipper: _HorizontalRevealClipper(_progress.value),
        child: child,
      ),
    ),
  );
}

final class _HorizontalRevealClipper extends CustomClipper<Rect> {
  const _HorizontalRevealClipper(this.progress);
  final double progress;

  @override
  Rect getClip(Size size) =>
      Rect.fromLTWH(0, 0, size.width * progress, size.height);

  @override
  bool shouldReclip(_HorizontalRevealClipper oldClipper) =>
      oldClipper.progress != progress;
}

final class _StartupBrand extends StatelessWidget {
  const _StartupBrand();

  @override
  Widget build(BuildContext context) => const Column(
    mainAxisSize: MainAxisSize.min,
    children: [
      Text(
        'VTC GAME',
        textAlign: TextAlign.center,
        style: TextStyle(
          color: Color(0xFF00B7F1),
          fontSize: 31,
          fontWeight: FontWeight.w900,
          fontStyle: FontStyle.italic,
          letterSpacing: -1.2,
          height: 1,
        ),
      ),
      SizedBox(height: 5),
      Text(
        'GAME IS LIFE',
        textAlign: TextAlign.center,
        style: TextStyle(
          color: Color(0xFF00B7F1),
          fontSize: 8,
          fontWeight: FontWeight.w700,
          letterSpacing: 2.4,
          height: 1,
        ),
      ),
    ],
  );
}

final class _UpdateContent extends StatelessWidget {
  const _UpdateContent({required this.state});
  final LauncherUpdateState state;

  @override
  Widget build(BuildContext context) {
    final progress = state is LauncherUpdateRunning
        ? (state as LauncherUpdateRunning).progress
        : null;
    final title = _title(state);
    return Padding(
      padding: const EdgeInsets.fromLTRB(32, 4, 32, 28),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Center(child: _StartupBrand()),
          const SizedBox(height: 24),
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 280),
            transitionBuilder: (child, animation) => FadeTransition(
              opacity: animation,
              child: SlideTransition(
                position: Tween<Offset>(
                  begin: const Offset(0, 0.25),
                  end: Offset.zero,
                ).animate(animation),
                child: child,
              ),
            ),
            child: Text(
              title,
              key: ValueKey(title),
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.w700,
              ),
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
          if (state is LauncherUpdateFailure) ...[
            const SizedBox(height: 20),
            Wrap(
              alignment: WrapAlignment.center,
              spacing: 12,
              runSpacing: 8,
              children: [
                OutlinedButton(
                  onPressed: () => context.read<LauncherUpdateBloc>().add(
                    const LauncherUpdateRepairRequested(),
                  ),
                  child: const Text('SỬA DỮ LIỆU CẬP NHẬT'),
                ),
                FilledButton(
                  onPressed: () => context.read<LauncherUpdateBloc>().add(
                    const LauncherUpdateCheckRequested(),
                  ),
                  child: const Text('THỬ LẠI'),
                ),
              ],
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
    LauncherUpdateNotRequired() => '',
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
