import 'package:flutter/material.dart';
import 'state_management_manager.dart';

class StateManagement extends StatefulWidget {
  const StateManagement({super.key});

  @override
  State<StateManagement> createState() => _StateManagementState();
}

class _StateManagementState extends State<StateManagement> {
  final manager = StateManagementManager();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("State Management")),
      body: Center(
        child: Column(
          children: [
            const SizedBox(height: 20.0),
            ValueListenableBuilder(
              valueListenable: manager.colorIndexNotifier,
              builder: (context, color, child) {
                return Container(
                  color: color,
                  width: 200,
                  height: 200,
                  child: Stack(
                    children: [
                      Center(
                        child: ValueListenableBuilder(
                          valueListenable: manager.numberNotifier,
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
                manager.changeColor();
              },
              child: Text("Change color"),
            ),
            const SizedBox(height: 20.0),
            OutlinedButton(
              onPressed: () {
                manager.changeText();
              },
              child: Text("Change Text"),
            ),
          ],
        ),
      ),
    );
  }
}
