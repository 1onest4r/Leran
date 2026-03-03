import 'package:flutter/material.dart';

class StateManagementManager {
  final List<MaterialAccentColor> boxColor = [
    Colors.amberAccent,
    Colors.blueAccent,
    Colors.cyanAccent,
    Colors.deepOrangeAccent,
    Colors.deepPurpleAccent,
    Colors.greenAccent,
    Colors.indigoAccent,
    Colors.lightBlueAccent,
    Colors.lightGreenAccent,
    Colors.limeAccent,
  ];

  final colorIndexNotifier = ValueNotifier<Color>(Colors.yellowAccent);
  final numberNotifier = ValueNotifier<int>(0);

  int _colorIndex = 0;

  void changeColor() {
    _colorIndex++;
    _colorIndex = _colorIndex % boxColor.length;
    final color = boxColor[_colorIndex];
    colorIndexNotifier.value = color;
  }

  void changeText() {
    numberNotifier.value++;
  }
}
