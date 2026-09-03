import 'package:flutter/material.dart';
import 'package:window_manager/window_manager.dart';

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
          onPressed: windowManager.minimize,
        ),
        _WindowButton(
          icon: Icons.close,
          tooltip: 'Close',
          hoverColor: const Color(0xFFC42B1C),
          onPressed: windowManager.close,
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
    this.hoverColor,
  });

  final IconData icon;
  final String tooltip;
  final Future<void> Function() onPressed;
  final Color? hoverColor;

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: tooltip,
      child: InkWell(
        hoverColor: hoverColor ?? Colors.white10,
        onTap: onPressed,
        child: SizedBox(
          width: 48,
          height: 36,
          child: Icon(icon, size: 17, color: Colors.white70),
        ),
      ),
    );
  }
}
