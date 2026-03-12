import 'package:flutter/material.dart';
import 'package:flutter_demo/service/local_storage/local_storage.dart';
import 'package:flutter_demo/service/service_locator.dart';

class AppState extends ChangeNotifier {
  final localStorage = getIt<LocalStorage>();

  ThemeMode _theme = ThemeMode.system;
  ThemeMode get theme => _theme;

  Future<void> init() async {
    _theme = localStorage.getTheme();
    notifyListeners();
  }

  Future<void> setThemeMode(ThemeMode theme) async {
    _theme = theme;
    await localStorage.setTheme(theme);
    notifyListeners();
  }
}
