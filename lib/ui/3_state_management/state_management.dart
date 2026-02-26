import 'package:flutter/material.dart';

class StateManagement extends StatefulWidget {
  const StateManagement({super.key});

  @override
  State<StateManagement> createState() => _StateManagementState();
}

class _StateManagementState extends State<StateManagement> {
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
  //int colorIndex = 0;

  //int number = 0;
  final colorIndexNotifier = ValueNotifier(0);

  final numberNotifier = ValueNotifier<int>(0);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("State Management")),
      body: Center(
        child: Column(
          children: [
            const SizedBox(height: 20.0),
            ValueListenableBuilder(
              valueListenable: colorIndexNotifier,
              builder: (context, colorIndex, child) {
                return Container(
                  color: boxColor[colorIndex],
                  width: 200,
                  height: 200,
                  child: Stack(
                    children: [
                      Center(
                        child: ValueListenableBuilder(
                          valueListenable: numberNotifier,
                          builder: (context, number, child) {
                            return Text(
                              '$number',
                              style: TextStyle(
                                fontSize: 60.0,
                                fontFamily: 'Courier',
                              ),
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
            const SizedBox(height: 20.0),
            OutlinedButton(
              onPressed: () {
                _changeColor();
              },
              child: Text("Change color"),
            ),
            const SizedBox(height: 20.0),
            OutlinedButton(
              onPressed: () {
                _changeText();
              },
              child: Text("Change Text"),
            ),
          ],
        ),
      ),
    );
  }

  void _changeColor() {
    //rebuilds the whole ui
    colorIndexNotifier.value++;
    colorIndexNotifier.value = colorIndexNotifier.value % 10;
  }

  void _changeText() {
    numberNotifier.value++;
  }
}
