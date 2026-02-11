import 'package:flutter/material.dart';

class RightSidebar extends StatelessWidget {
  const RightSidebar({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          height: 70,
          padding: const EdgeInsets.symmetric(horizontal: 20),
          decoration: BoxDecoration(
            border: Border(bottom: BorderSide(color: Colors.grey.shade300)),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                "My notes",
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              IconButton(onPressed: () {}, icon: const Icon(Icons.menu)),
            ],
          ),
        ),
        Expanded(
          child: Container(
            color: Colors.white,
            padding: const EdgeInsets.all(20),
            alignment: Alignment.topLeft,
            child: const Text(
              "Start typung your note here...",
              style: TextStyle(color: Colors.grey, fontSize: 16),
            ),
          ),
        ),
        Container(
          height: 30,
          color: Colors.blue,
          child: Row(
            children: [
              Text("1. CG II", style: TextStyle(fontWeight: FontWeight.bold)),
              Text("2. WEB II", style: TextStyle(fontWeight: FontWeight.bold)),
              Text(
                "3. DSA 2025",
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
