import 'package:flutter/material.dart';

class DartDemoScreen extends StatelessWidget {
  const DartDemoScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("1. Dart Demo"),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      // Center aligns the scroll view in the middle of the screen
      body: Center(
        // SingleChildScrollView ensures the content scrolls if the screen is too small
        child: SingleChildScrollView(
          child: Column(
            // MainAxisSize.min ensures the column only takes up needed space
            // so the Center widget can do its job vertically
            mainAxisSize: MainAxisSize.min,
            children: [
              ElevatedButton(
                onPressed: () {
                  print("Hi");
                },
                child: const Text("press to log hi"),
              ),
              const SizedBox(height: 10), // Spacing between buttons
              ElevatedButton(onPressed: () {}, child: const Text("Button 2")),
              const SizedBox(height: 10),
              ElevatedButton(onPressed: () {}, child: const Text("Button 3")),
              const SizedBox(height: 10),
              ElevatedButton(onPressed: () {}, child: const Text("Button 4")),
              const SizedBox(height: 10),
              ElevatedButton(onPressed: () {}, child: const Text("Button 5")),
            ],
          ),
        ),
      ),
    );
  }
}
