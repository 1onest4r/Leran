import 'package:flutter/material.dart';

// THE DIGITAL OBSIDIAN - Design System Tokens
class Obsidian {
  static const Color background = Color(0xFF131313);
  static const Color surfaceLow = Color(0xFF1C1B1B); // Level 1 (Cards)
  static const Color surfaceHigh = Color(0xFF2A2A2A); // Level 2
  static const Color surfaceHighest = Color(0xFF353534); // Highlight

  static const Color emerald = Color(0xFF50C878);
  static const Color emeraldLight = Color(0xFF6ee591);
  static const Color emeraldDim = Color(0xFF005227);

  static const Color text = Color(0xFFe5e2e1);
  static const Color textDim = Color(0xFFbdcabc); // Muted Labels

  static const Color danger = Color(0xFFffb4ab);
  static const Color dangerContainer = Color(0xFF93000a);

  // Gradient Rule (Button gems)
  static const LinearGradient gemstoneGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [emeraldLight, emerald],
  );

  static const TextStyle manrope = TextStyle(fontFamily: 'Manrope');
  static const TextStyle inter = TextStyle(fontFamily: 'Inter');
}
