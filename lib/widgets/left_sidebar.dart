import 'package:flutter/material.dart';

class LeftSidebar extends StatelessWidget {
  const LeftSidebar({super.key});

  @override
  Widget build(BuildContext context) {
    // 1. Fake data to make it look like you have files
    final List<String> noteFiles = [
      "Flutter Ideas",
      "Grocery List",
      "Meeting Notes",
      "Journal 2024",
      "App Design Specs",
      "To-Do",
    ];

    return Container(
      color: Colors.grey[100],
      padding: const EdgeInsets.all(10.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // --- TOP BUTTONS (Create, Search, Settings) ---
          Container(
            padding: const EdgeInsets.symmetric(vertical: 8),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.grey.shade300),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.shade200,
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _iconBtn(Icons.add, Colors.blue),
                _iconBtn(Icons.search, Colors.black54),
                _iconBtn(Icons.settings, Colors.black54),
              ],
            ),
          ),

          const SizedBox(height: 20),

          // --- SECTION TITLE (Like "EXPLORER" in VS Code) ---
          Padding(
            padding: const EdgeInsets.only(left: 8.0, bottom: 8.0),
            child: Text(
              "YOUR NOTES",
              style: TextStyle(
                color: Colors.grey[600],
                fontWeight: FontWeight.bold,
                fontSize: 12,
                letterSpacing: 1.0,
              ),
            ),
          ),

          // --- FILE LIST (The VS Code style list) ---
          // We use Expanded so the list fills the rest of the height
          Expanded(
            child: ListView.builder(
              itemCount: noteFiles.length,
              itemBuilder: (context, index) {
                return Container(
                  margin: const EdgeInsets.only(bottom: 4),
                  decoration: BoxDecoration(
                    // Let's highlight the first item to look like it's "Selected"
                    color: index == 0 ? Colors.white : Colors.transparent,
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: ListTile(
                    // Tighter spacing to look like a file list
                    dense: true,
                    contentPadding: const EdgeInsets.symmetric(horizontal: 8),
                    visualDensity: const VisualDensity(
                      horizontal: 0,
                      vertical: -4,
                    ),

                    // The Icon
                    leading: Icon(
                      Icons.description_outlined,
                      size: 18,
                      color: index == 0 ? Colors.blue : Colors.grey[600],
                    ),

                    // The Filename
                    title: Text(
                      noteFiles[index],
                      style: TextStyle(
                        fontWeight: index == 0
                            ? FontWeight.w600
                            : FontWeight.normal,
                        color: index == 0 ? Colors.blue[900] : Colors.black87,
                      ),
                    ),

                    onTap: () {
                      // Later you will add logic to switch notes here
                    },
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  // Helper for the top buttons to keep code clean
  Widget _iconBtn(IconData icon, Color color) {
    return InkWell(
      onTap: () {},
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Icon(icon, color: color, size: 22),
      ),
    );
  }
}
