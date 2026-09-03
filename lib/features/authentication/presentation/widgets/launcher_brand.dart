import 'package:flutter/material.dart';

final class LauncherBrand extends StatelessWidget {
  const LauncherBrand({super.key});

  @override
  Widget build(BuildContext context) {
    return const Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          'VTC',
          style: TextStyle(
            color: Color(0xFF00B7F1),
            fontSize: 34,
            fontWeight: FontWeight.w900,
            fontStyle: FontStyle.italic,
            letterSpacing: -3,
          ),
        ),
        SizedBox(width: 8),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'GAME',
              style: TextStyle(
                color: Color(0xFF00B7F1),
                fontSize: 20,
                fontWeight: FontWeight.w900,
                height: 1,
              ),
            ),
            Text(
              'GAME IS LIFE',
              style: TextStyle(
                color: Color(0xFF00B7F1),
                fontSize: 7,
                fontWeight: FontWeight.w700,
                letterSpacing: 1.2,
              ),
            ),
          ],
        ),
      ],
    );
  }
}
