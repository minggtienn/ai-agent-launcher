import 'package:bitsdojo_window/bitsdojo_window.dart';
import 'package:flutter/material.dart';

final class LauncherTitleBar extends StatelessWidget {
  const LauncherTitleBar({super.key});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 36,
      child: Stack(
        children: [
          Positioned.fill(
            child: MoveWindow(child: const SizedBox.expand()),
          ),
          const Positioned(top: 0, right: 0, child: WindowControls()),
        ],
      ),
    );
  }
}

final class WindowControls extends StatelessWidget {
  const WindowControls({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        _WindowButton(
          icon: Icons.remove,
          tooltip: 'Minimize',
          backgroundColor: const Color(0xFF1C2634),
          hoverColor: const Color(0xFF31506F),
          iconColor: const Color(0xFFB9D9F5),
          onPressed: () => appWindow.minimize(),
        ),
        _WindowButton(
          icon: Icons.close,
          tooltip: 'Close',
          backgroundColor: const Color(0xFF3A2026),
          hoverColor: const Color(0xFFE5484D),
          iconColor: const Color(0xFFFFD7D9),
          onPressed: () => appWindow.close(),
        ),
      ],
    );
  }
}

final class _WindowButton extends StatelessWidget {
  const _WindowButton({
    required this.icon,
    required this.tooltip,
    required this.onPressed,
    required this.backgroundColor,
    required this.hoverColor,
    required this.iconColor,
  });

  final IconData icon;
  final String tooltip;
  final VoidCallback onPressed;
  final Color backgroundColor;
  final Color hoverColor;
  final Color iconColor;

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: tooltip,
      child: Material(
        color: backgroundColor,
        child: InkWell(
          hoverColor: hoverColor,
          onTap: onPressed,
          child: SizedBox(
            width: 46,
            height: 34,
            child: Icon(icon, size: 18, color: iconColor),
          ),
        ),
      ),
    );
  }
}
