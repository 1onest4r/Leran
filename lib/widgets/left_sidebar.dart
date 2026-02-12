import 'package:flutter/material.dart';

class LeftSidebar extends StatelessWidget {
  const LeftSidebar({super.key});

  @override
  Widget build(BuildContext context) {
    // 1. Fake data to make it look like you have files
    final List<String> files = [
      "algorithms_intro.md",
      "bio_neural_nets.md",
      "Project_Botanical.md", // This one will be active
      "d3_visualization.md",
      "react_performance.md",
      "q4_goals_draft.md",
      "style_guide_v2.css",
      "fractal_geometry.md",
    ];

    return Container(
      color: const Color(0xFF252526),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // --- TOP BUTTONS (Create, Search, Settings) ---
          Container(
            padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _iconBtn(Icons.add_box_outlined, Colors.yellowAccent),
                _iconBtn(Icons.search, Colors.grey),
                _iconBtn(Icons.hub_outlined, Colors.grey),
                _iconBtn(Icons.settings, Colors.grey),
              ],
            ),
          ),

          Divider(color: Colors.grey[800], height: 1),

          // --- SECTION TITLE (Like "EXPLORER" in VS Code) ---
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: Text(
              "YOUR NOTES",
              style: TextStyle(
                color: Colors.grey[500],
                fontWeight: FontWeight.bold,
                fontSize: 10,
                letterSpacing: 1.5,
              ),
            ),
          ),

          // --- FILE LIST (The VS Code style list) ---
          // We use Expanded so the list fills the rest of the height
          Expanded(
            child: ListView.builder(
              itemCount: files.length,
              itemBuilder: (context, index) {
                // Let's make the 3rd item (index 2) the "Active" one
                bool isActive = index == 2;

                return Container(
                  color: isActive
                      ? const Color(0xFF37373D)
                      : Colors.transparent,
                  child: ListTile(
                    dense: true,
                    visualDensity: const VisualDensity(vertical: -3),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 15),
                    title: Text(
                      files[index],
                      style: TextStyle(
                        // Monospace font for that coding look
                        fontFamily: 'Courier',
                        fontSize: 13,
                        color: isActive
                            ? const Color(0xFFDCDCAA)
                            : Colors.grey[400],
                      ),
                    ),
                    onTap: () {},
                  ),
                );
              },
            ),
          ),

          Divider(color: Colors.grey[800], height: 1),

          Container(
            height: 33.5, // Slightly taller for better readability
            padding: const EdgeInsets.symmetric(horizontal: 12),
            color: const Color(0xFF1E1E1E), // Darker contrast background
            child: Row(
              children: [
                const Icon(
                  Icons.timer_outlined,
                  size: 14,
                  color: Colors.yellowAccent,
                ),
                const SizedBox(width: 8),
                Text(
                  "SESSION TIME",
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1,
                  ),
                ),
                const Spacer(),
                // The Digital Timer display
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 6,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.black38,
                    borderRadius: BorderRadius.circular(4),
                    border: Border.all(color: Colors.grey.shade800),
                  ),
                  child: const Text(
                    "00:42:15", // Static text for now
                    style: TextStyle(
                      fontFamily: 'Courier', // Digital clock look
                      color: Colors.white70,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Helper for the top buttons to keep code clean
  Widget _iconBtn(IconData icon, Color color) {
    return IconButton(
      onPressed: () {},
      icon: Icon(icon, color: color, size: 20),
      padding: EdgeInsets.zero,
    );
  }
}
