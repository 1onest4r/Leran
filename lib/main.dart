import 'package:flutter/material.dart';
import 'screens/home_page.dart';

void main() {
  runApp(const Leran());
}

class Leran extends StatelessWidget {
  const Leran({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: "Leran note taking app",
      theme: ThemeData.dark().copyWith(),
      home: const HomePage(),
    );
  }
}
