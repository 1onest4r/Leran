import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ThemeLogic extends ChangeNotifier {
  ThemeMode _themeMode = ThemeMode.dark;
  Color _primaryColor = const Color(0xFF50C878); // Default Emerald Green

  ThemeMode get themeMode => _themeMode;
  Color get primaryColor => _primaryColor;
  bool get isDarkMode => _themeMode == ThemeMode.dark;

  // Loads saved preferences on startup
  Future<void> loadSettings() async {
    final prefs = await SharedPreferences.getInstance();

    final isDark = prefs.getBool('is_dark_mode') ?? true;
    _themeMode = isDark ? ThemeMode.dark : ThemeMode.light;

    final colorValue = prefs.getInt('primary_color');
    if (colorValue != null) {
      _primaryColor = Color(colorValue);
    }

    notifyListeners();
  }

  // Toggles and saves Dark/Light mode
  Future<void> toggleTheme(bool isDark) async {
    _themeMode = isDark ? ThemeMode.dark : ThemeMode.light;
    notifyListeners();

    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('is_dark_mode', isDark);
  }

  // Changes and saves the App's Primary Color
  Future<void> setPrimaryColor(Color color) async {
    _primaryColor = color;
    notifyListeners();

    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('primary_color', color.value);
  }
}
