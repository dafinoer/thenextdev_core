import 'package:flutter/material.dart';

abstract class _TheNextDevTheme {
  final _themeLight = ThemeData.light();
  final _themeDark = ThemeData.dark();

  ThemeData createTheme();
}

class ThemeLight extends _TheNextDevTheme {
  static ThemeData themeLight() {
    final themeLight = ThemeLight();
    return themeLight.createTheme();
  }

  @override
  ThemeData createTheme() => _themeLight;
}

class ThemeDark extends _TheNextDevTheme {
  static ThemeData themeDark() {
    final themeDark = ThemeDark();
    return themeDark.createTheme();
  }

  @override
  ThemeData createTheme() => _themeDark;
}
