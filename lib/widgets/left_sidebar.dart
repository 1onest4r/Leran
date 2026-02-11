import 'package:flutter/material.dart';

class LeftSidebar extends StatelessWidget {
  const LeftSidebar({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.grey[100],
      padding: const EdgeInsets.all(10.0),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(vertical: 10),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey.shade300),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                IconButton(
                  onPressed: () {},
                  icon: Icon(Icons.add_circle_outline, color: Colors.blue),
                  tooltip: "Create Note",
                ),
                IconButton(
                  onPressed: () {},
                  icon: const Icon(Icons.search, color: Colors.black54),
                  tooltip: "Search",
                ),
                IconButton(
                  onPressed: () {},
                  icon: Icon(Icons.settings, color: Colors.black54),
                  tooltip: "Settings",
                ),
              ],
            ),
          ),
          const Spacer(),
        ],
      ),
    );
  }
}
