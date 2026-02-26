import 'package:flutter/material.dart';
// Import the second file so we can navigate to it
import 'ui/1_dart/dart_demo_screen.dart';
import 'ui/2_widgets_layout/widgets_layout_demo.dart';
import 'ui/3_state_management/state_management.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Flutter Demo',
      theme: ThemeData(primarySwatch: Colors.blue, useMaterial3: true),
      home: const HomeScreen(),
    );
  }
}

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Home Screen"),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      // A ListView for your items
      body: ListView(
        children: [
          // The single list item requested
          ListTile(
            title: const Text("1. Dart Demo"),
            leading: const Icon(Icons.code), // Optional: adds a little icon
            onTap: () {
              // Navigate to the new screen defined in the other file
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const DartDemoScreen()),
              );
            },
          ),
          ListTile(
            title: const Text("2. Widgets and layout"),
            leading: const Icon(Icons.code), // Optional: adds a little icon
            onTap: () {
              // Navigate to the new screen defined in the other file
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const WidgetsLayoutDemo(),
                ),
              );
            },
          ),
          ListTile(
            title: const Text("3. State Management"),
            leading: const Icon(Icons.code), // Optional: adds a little icon
            onTap: () {
              // Navigate to the new screen defined in the other file
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const StateManagement(),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
