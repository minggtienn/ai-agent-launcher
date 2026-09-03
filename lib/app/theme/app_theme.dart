import 'package:flutter/material.dart';

abstract final class AppTheme {
  static const _seed = Color(0xFF00AEEF);

  static ThemeData get light => ThemeData(
    colorScheme: ColorScheme.fromSeed(seedColor: _seed),
    useMaterial3: true,
    fontFamily: 'Segoe UI',
  );

  static ThemeData get dark => ThemeData(
    colorScheme: ColorScheme.fromSeed(
      seedColor: _seed,
      brightness: Brightness.dark,
    ),
    useMaterial3: true,
    scaffoldBackgroundColor: const Color(0xFF11151E),
    fontFamily: 'Segoe UI',
    inputDecorationTheme: const InputDecorationTheme(
      filled: true,
      fillColor: Color(0xFF202633),
      border: OutlineInputBorder(borderSide: BorderSide.none),
      enabledBorder: OutlineInputBorder(borderSide: BorderSide.none),
      focusedBorder: OutlineInputBorder(
        borderSide: BorderSide(color: _seed),
      ),
    ),
  );
}
