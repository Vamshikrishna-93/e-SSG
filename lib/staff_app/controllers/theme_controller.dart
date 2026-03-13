import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';

class ThemeController extends GetxController {
  final GetStorage _box = GetStorage();
  final RxBool isDark = false.obs;

  @override
  void onInit() {
    // Read saved theme (default = light)
    isDark.value = _box.read('isDarkMode') ?? false;

    // Apply theme on app start
    Get.changeThemeMode(
      isDark.value ? ThemeMode.dark : ThemeMode.light,
    );

    super.onInit();
  }

  void toggleTheme() {
    isDark.value = !isDark.value;

    // Save theme
    _box.write('isDarkMode', isDark.value);

    // Change theme instantly
    Get.changeThemeMode(
      isDark.value ? ThemeMode.dark : ThemeMode.light,
    );
  }
}
