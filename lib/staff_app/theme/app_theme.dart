import 'package:flutter/material.dart';

class AppTheme {
  static const Color primary = Color(0xFF7E49FF);

  static ThemeData get lightTheme => ThemeData(
    primaryColor: primary,
    scaffoldBackgroundColor: Colors.white,
    useMaterial3: true,
    colorScheme: ColorScheme.fromSeed(seedColor: primary, primary: primary),
    appBarTheme: const AppBarTheme(
      backgroundColor: primary,
      foregroundColor: Colors.white,
      elevation: 0,
    ),
  );

  // Still keeping the property name for compatibility with main.dart if needed,
  // but it will just return lightTheme or a basic dark theme if forced.
  static ThemeData get darkTheme => lightTheme;
}
