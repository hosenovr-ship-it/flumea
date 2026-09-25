import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class FlumeaThemeController {
  static final ValueNotifier<ThemeMode> mode =
      ValueNotifier<ThemeMode>(ThemeMode.light);

  static Future<void> load() async {
    final prefs = await SharedPreferences.getInstance();
    final isDark = prefs.getBool('flumea_dark_mode') ?? false;
    mode.value = isDark ? ThemeMode.dark : ThemeMode.light;
  }

  static Future<void> setMode(ThemeMode newMode) async {
    mode.value = newMode;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('flumea_dark_mode', newMode == ThemeMode.dark);
  }
}
