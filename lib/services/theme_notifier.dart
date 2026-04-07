import 'package:flutter/material.dart';

final themeNotifier = ValueNotifier<ThemeMode>(ThemeMode.light);

void toggleTheme(bool isDark) {
  themeNotifier.value = isDark ? ThemeMode.dark : ThemeMode.light;
}
