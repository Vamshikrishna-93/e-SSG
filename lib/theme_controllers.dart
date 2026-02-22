import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class StudentThemeController {
  static final ValueNotifier<ThemeMode> themeMode = ValueNotifier(
    ThemeMode.light,
  );

  static Future<void> init() async {
    final prefs = await SharedPreferences.getInstance();
    final String? savedMode = prefs.getString('student_theme_mode');
    if (savedMode == 'dark') {
      themeMode.value = ThemeMode.dark;
    } else if (savedMode == 'light') {
      themeMode.value = ThemeMode.light;
    } else {
      // Default choice if nothing saved
      themeMode.value = ThemeMode.light;
    }
  }

  static void toggleTheme() async {
    themeMode.value = themeMode.value == ThemeMode.dark
        ? ThemeMode.light
        : ThemeMode.dark;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
      'student_theme_mode',
      themeMode.value == ThemeMode.dark ? 'dark' : 'light',
    );
  }

  void loadTheme() {}
}

class ThemeControllerWrapper extends StatelessWidget {
  final ValueNotifier<ThemeMode> themeController;
  final Widget child;
  final ThemeData? lightTheme;
  final ThemeData? darkTheme;

  const ThemeControllerWrapper({
    super.key,
    required this.themeController,
    required this.child,
    this.lightTheme,
    this.darkTheme,
  });

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<ThemeMode>(
      valueListenable: themeController,
      builder: (context, mode, child) {
        final isDark =
            mode == ThemeMode.dark ||
            (mode == ThemeMode.system &&
                MediaQuery.of(context).platformBrightness == Brightness.dark);
        return Theme(
          data: isDark
              ? (darkTheme ?? ThemeData.dark(useMaterial3: true))
              : (lightTheme ?? ThemeData.light(useMaterial3: true)),
          child: child!,
        );
      },
      child: child,
    );
  }
}
