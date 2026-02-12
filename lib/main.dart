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
      theme: ThemeData.dark().copyWith(
        scaffoldBackgroundColor: const Color(0xFF1E1E1E),
        primaryColor: const Color(0xFFDCDCAA),
        dividerColor: Colors.grey[800],
      ),
      home: const HomePage(),
    );
  }
}
