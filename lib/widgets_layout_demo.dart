import 'package:flutter/material.dart';

class WidgetsLayoutDemo extends StatelessWidget {
  const WidgetsLayoutDemo({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Widgets and layout")),
      body: Column(children: [Text("Hello"), Text("World"), Text("and MIU")]),
    );
  }
}
