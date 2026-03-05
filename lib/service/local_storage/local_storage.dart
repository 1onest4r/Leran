import 'dart:ui';
// import 'package:flutter/src/material/colors.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LocalStorage {
  late final SharedPreferences prefs;
  static const _colorKey = 'OBAMAWASHERE';
  static const _numberKey = 'MICHEALWASHERE';

  Future<void> init() async {
    prefs = await SharedPreferences.getInstance();
  }

  Color getColor() {
    final colorInt = prefs.getInt(_colorKey) ?? 0x00000000;
    final color = Color(colorInt);
    return color;
  }

  int getNumber() {
    final number = prefs.getInt(_numberKey) ?? 0;
    return number;
  }

  Future<void> setColor(Color color) async {
    final colorInt = color.toARGB32();
    await prefs.setInt(_colorKey, colorInt);
  }

  Future<void> setNumber(int number) async {
    await prefs.setInt(_numberKey, number);
  }
}
