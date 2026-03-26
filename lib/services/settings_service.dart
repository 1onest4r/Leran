import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

enum AppAccentColor { emerald, amethyst, sapphire, ruby, topaz }

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

  // 1. New private variable for the chosen color enum
  AppAccentColor _appAccentColor = AppAccentColor.emerald;

  bool get isDarkMode => _isDarkMode;
  bool get autoSave => _autoSave;
  double get fontSize => _fontSize;
  double get uiScale => _uiScale;
  String get fontFamily => _fontFamily;

  // 2. Getter for the Obsidian theme engine to read the enum
  AppAccentColor get appAccentColor => _appAccentColor;

  Color get scaffoldColor =>
      _isDarkMode ? const Color(0xFF1E1E1E) : const Color(0xFFF5F5F5);
  Color get sidebarColor =>
      _isDarkMode ? const Color(0xFF252526) : const Color(0xFFE8E8E8);
  Color get textColor => _isDarkMode ? Colors.white : Colors.black87;
  Color get dimTextColor => _isDarkMode ? Colors.white54 : Colors.black54;
  Color get dividerColor => _isDarkMode ? Colors.grey[800]! : Colors.grey[300]!;

  // 3. Updated Legacy Accent Color to respect the chosen gem!
  Color get accentColor {
    switch (_appAccentColor) {
      case AppAccentColor.amethyst:
        return const Color(0xFF8B5CF6);
      case AppAccentColor.sapphire:
        return const Color(0xFF3B82F6);
      case AppAccentColor.ruby:
        return const Color(0xFFEF4444);
      case AppAccentColor.topaz:
        return const Color(0xFFF59E0B);
      case AppAccentColor.emerald:
      default:
        return const Color(0xFF52CB8B); // Your original green shade
    }
  }

  Future<void> loadSettings() async {
    _prefs = await SharedPreferences.getInstance();
    _isDarkMode = _prefs.getBool('isDarkMode') ?? true;
    _autoSave = _prefs.getBool('autoSave') ?? false;
    _fontSize = _prefs.getDouble('fontSize') ?? 16.0;
    _uiScale = _prefs.getDouble('uiScale') ?? 1.0;
    _fontFamily = _prefs.getString('fontFamily') ?? 'Courier';

    // 4. Load saved accent color using its enum index
    final colorIndex = _prefs.getInt('accentColor') ?? 0;
    if (colorIndex >= 0 && colorIndex < AppAccentColor.values.length) {
      _appAccentColor = AppAccentColor.values[colorIndex];
    }

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

  Future<void> toggleDarkMode() async {
    _isDarkMode = !_isDarkMode;
    await _prefs.setBool('isDarkMode', _isDarkMode); // Fixed to save state!
    notifyListeners();
  }

  // 5. Save the newly selected color
  Future<void> setAppAccentColor(AppAccentColor color) async {
    _appAccentColor = color;
    await _prefs.setInt(
      'accentColor',
      color.index,
    ); // Save index to local storage
    notifyListeners();
  }
}
