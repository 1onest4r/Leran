import 'package:flutter/material.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        body: Row(
          children: [
            Container(
              width: MediaQuery.of(context).size.width * 0.25,
              color: const Color.fromARGB(86, 64, 77, 104),
            ),
            Expanded(
              child: Container(color: const Color.fromARGB(49, 46, 56, 200)),
            ),
          ],
        ),
      ),
    );
  }
}
