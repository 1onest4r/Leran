import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LocalStorage {
  late final SharedPreferences prefs;
  static const _colorKey = 'color';
  static const _numberKey = 'number';
  static const _themeKey = 'theme';

  Future<void> init() async {
    prefs = await SharedPreferences.getInstance();
  }

  Color getColor() {
    final colorInt = prefs.getInt(_colorKey) ?? 0x00000000;
    final color = Color(colorInt);
    return color;
  }

  int getNumber() {
    return prefs.getInt(_numberKey) ?? 0;
  }

  Future<void> setColor(Color color) async {
    final colorInt = color.toARGB32();
    await prefs.setInt(_colorKey, colorInt);
  }

  Future<void> setNumber(int value) async {
    await prefs.setInt(_numberKey, value);
  }

  ThemeMode getTheme() {
    final theme = prefs.getString(_themeKey);
    if (theme == "light") {
      return ThemeMode.light;
    } else if (theme == "dark") {
      return ThemeMode.dark;
    } else {
      return ThemeMode.system;
    }
  }

  Future<void> setTheme(ThemeMode theme) async {
    if (theme == ThemeMode.light) {
      await prefs.setString(_themeKey, "light");
    } else if (theme == ThemeMode.dark) {
      await prefs.setString(_themeKey, "dark");
    } else {
      await prefs.remove(_themeKey);
    }
  }
}
