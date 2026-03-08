import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SettingsService extends ChangeNotifier {
  static final SettingsService _instance = SettingsService._internal();
  factory SettingsService() => _instance;
  SettingsService._internal();

  late SharedPreferences _prefs;

  bool _isDarkMode = true;
  bool _autoSave = false;
  double _fontSize = 16.0;
  double _uiScale = 1.0;
  String _fontFamily = 'Courier';

  bool get isDarkMode => _isDarkMode;
  bool get autoSave => _autoSave;
  double get fontSize => _fontSize;
  double get uiScale => _uiScale;
  String get fontFamily => _fontFamily;

  Color get scaffoldColor =>
      _isDarkMode ? const Color(0xFF1E1E1E) : const Color(0xFFF5F5F5);
  Color get sidebarColor =>
      _isDarkMode ? const Color(0xFF252526) : const Color(0xFFE8E8E8);
  Color get textColor => _isDarkMode ? Colors.white : Colors.black87;
  Color get dimTextColor => _isDarkMode ? Colors.white54 : Colors.black54;
  Color get dividerColor => _isDarkMode ? Colors.grey[800]! : Colors.grey[300]!;
  Color get accentColor => const Color(0xFF52CB8B);

  Future<void> loadSettings() async {
    _prefs = await SharedPreferences.getInstance();
    _isDarkMode = _prefs.getBool('isDarkMode') ?? true;
    _autoSave = _prefs.getBool('autoSave') ?? false;
    _fontSize = _prefs.getDouble('fontSize') ?? 16.0;
    _uiScale = _prefs.getDouble('uiScale') ?? 1.0;
    _fontFamily = _prefs.getString('fontFamily') ?? 'Courier';
    notifyListeners();
  }

  Future<void> toggleTheme(bool isDark) async {
    _isDarkMode = isDark;
    await _prefs.setBool('isDarkMode', isDark);
    notifyListeners();
  }

  Future<void> toggleAutoSave(bool value) async {
    _autoSave = value;
    await _prefs.setBool('autoSave', value);
    notifyListeners();
  }

  Future<void> setFontSize(double size) async {
    _fontSize = size.clamp(10.0, 48.0);
    await _prefs.setDouble('fontSize', _fontSize);
    notifyListeners();
  }

  Future<void> setUiScale(double scale) async {
    _uiScale = scale.clamp(0.8, 1.5);
    await _prefs.setDouble('uiScale', _uiScale);
    notifyListeners();
  }
}
