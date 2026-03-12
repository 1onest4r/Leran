import 'package:flutter/material.dart';
import 'package:flutter_demo/app_state.dart';
import 'package:flutter_demo/service/service_locator.dart';

class SettingsManager {
  final appState = getIt<AppState>();

  ThemeMode get currentTheme => appState.theme;

  void setTheme(ThemeMode theme) {
    appState.setThemeMode(theme);
  }
}
