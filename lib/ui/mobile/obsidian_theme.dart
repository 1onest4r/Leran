import 'package:flutter/material.dart';
import '../../services/settings_service.dart'; // Adjust path if needed

class Obsidian {
  // Check the singleton settings service for the current mode
  static bool get _isDark => SettingsService().isDarkMode;
  static AppAccentColor get _accent => SettingsService().appAccentColor;

  // ─── BACKGROUND & SURFACES ───────────────────────────────────────────
  static Color get background =>
      _isDark ? const Color(0xFF0A0A0A) : const Color(0xFFFAFAFA);
  static Color get surfaceLow =>
      _isDark ? const Color(0xFF141414) : const Color(0xFFF4F4F5);
  static Color get surfaceHigh =>
      _isDark ? const Color(0xFF1C1C1E) : const Color(0xFFE4E4E7);
  static Color get surfaceHighest =>
      _isDark ? const Color(0xFF2C2C2E) : const Color(0xFFD4D4D8);

  // ─── TEXT ────────────────────────────────────────────────────────────
  static Color get text =>
      _isDark ? const Color(0xFFF5F5F5) : const Color(0xFF18181B);
  static Color get textDim =>
      _isDark ? const Color(0xFFA1A1A1) : const Color(0xFF71717A);

  // ─── ACCENTS (DYNAMIC GEMSTONES) ─────────────────────────────────────
  static Color get emerald {
    switch (_accent) {
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
        return const Color(0xFF10B981);
    }
  }

  static Color get emeraldLight {
    switch (_accent) {
      case AppAccentColor.amethyst:
        return _isDark ? const Color(0xFFA78BFA) : const Color(0xFF7C3AED);
      case AppAccentColor.sapphire:
        return _isDark ? const Color(0xFF60A5FA) : const Color(0xFF2563EB);
      case AppAccentColor.ruby:
        return _isDark ? const Color(0xFFF87171) : const Color(0xFFDC2626);
      case AppAccentColor.topaz:
        return _isDark ? const Color(0xFFFCD34D) : const Color(0xFFD97706);
      case AppAccentColor.emerald:
      default:
        return _isDark ? const Color(0xFF34D399) : const Color(0xFF059669);
    }
  }

  static Color get emeraldDim {
    switch (_accent) {
      case AppAccentColor.amethyst:
        return _isDark ? const Color(0xFF4C1D95) : const Color(0xFFEDE9FE);
      case AppAccentColor.sapphire:
        return _isDark ? const Color(0xFF1E3A8A) : const Color(0xFFDBEAFE);
      case AppAccentColor.ruby:
        return _isDark ? const Color(0xFF7F1D1D) : const Color(0xFFFEE2E2);
      case AppAccentColor.topaz:
        return _isDark ? const Color(0xFF78350F) : const Color(0xFFFEF3C7);
      case AppAccentColor.emerald:
      default:
        return _isDark ? const Color(0xFF064E3B) : const Color(0xFFD1FAE5);
    }
  }

  // ─── DANGER ──────────────────────────────────────────────────────────
  static Color get danger => const Color(0xFFEF4444);
  static Color get dangerContainer =>
      _isDark ? const Color(0xFF7F1D1D) : const Color(0xFFFEE2E2);

  // ─── GRADIENTS ───────────────────────────────────────────────────────
  static LinearGradient get gemstoneGradient {
    Color color1, color2;
    switch (_accent) {
      case AppAccentColor.amethyst:
        color1 = _isDark ? const Color(0xFF8B5CF6) : const Color(0xFFA78BFA);
        color2 = _isDark ? const Color(0xFF4C1D95) : const Color(0xFF8B5CF6);
        break;
      case AppAccentColor.sapphire:
        color1 = _isDark ? const Color(0xFF3B82F6) : const Color(0xFF60A5FA);
        color2 = _isDark ? const Color(0xFF1E3A8A) : const Color(0xFF3B82F6);
        break;
      case AppAccentColor.ruby:
        color1 = _isDark ? const Color(0xFFEF4444) : const Color(0xFFF87171);
        color2 = _isDark ? const Color(0xFF7F1D1D) : const Color(0xFFEF4444);
        break;
      case AppAccentColor.topaz:
        color1 = _isDark ? const Color(0xFFF59E0B) : const Color(0xFFFCD34D);
        color2 = _isDark ? const Color(0xFF78350F) : const Color(0xFFF59E0B);
        break;
      case AppAccentColor.emerald:
      default:
        color1 = _isDark ? const Color(0xFF10B981) : const Color(0xFF34D399);
        color2 = _isDark ? const Color(0xFF047857) : const Color(0xFF10B981);
        break;
    }
    return LinearGradient(
      colors: [color1, color2],
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    );
  }

  // ─── TYPOGRAPHY ──────────────────────────────────────────────────────
  static const TextStyle manrope = TextStyle(fontFamily: 'Manrope');
  static const TextStyle inter = TextStyle(fontFamily: 'Inter');
}
