import 'package:flutter/material.dart';
import 'package:flutter_demo/service/local_storage/local_storage.dart';
import '../../../service/service_locator.dart';

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

  final colorNotifier = ValueNotifier<Color>(Colors.yellowAccent);
  final numberNotifier = ValueNotifier<int>(0);
  final localStorage = getIt<LocalStorage>();

  int _colorIndex = 0;

  void init() {
    final color = localStorage.getColor();
    final number = localStorage.getNumber();
    colorNotifier.value = color;
    numberNotifier.value = number;
  }

  void changeColor() {
    _colorIndex++;
    _colorIndex = _colorIndex % boxColor.length;
    final color = boxColor[_colorIndex];
    colorNotifier.value = color;

    //save the color as soon as user changes the color
    localStorage.setColor(color);
  }

  void changeText() {
    numberNotifier.value++;

    //save the number as soon as user changes the color
    localStorage.setNumber(numberNotifier.value);
  }
}
