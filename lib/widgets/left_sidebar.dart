import 'package:flutter/material.dart';

class LeftSidebar extends StatelessWidget {
  const LeftSidebar({super.key});

  @override
  Widget build(BuildContext context) {
    //theme colors
    const Color bgDark = Color(0xFF252526);
    const Color accentYellow = Colors.yellowAccent;
    const Color textDim = Colors.white54;
    const Color textActive = Colors.white;

    final List<String> mockFiles = [
      "algorithms_intro.md",
      "bio_neural_nets.md",
      "Project_Botanical.md", // We will pretend this is the active one
      "d3_visualization.md",
      "react_performance.md",
      "q4_goals_draft.md",
      "fractal_geometry.md",
      "style_guide_v2.css",
      "archived_notes_2023.md",
      "meeting_logs.txt",
    ];

    return Container(
      color: bgDark,
      //using column to stack the children vertically
      child: Column(
        children: [
          //the top button section
          Container(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _iconBtn(Icons.add_box_outlined, accentYellow, "New note"),
                _iconBtn(Icons.search, textDim, "Search"),
                _iconBtn(Icons.hub_outlined, textDim, "Graph view"),
                _iconBtn(Icons.settings_outlined, textDim, "Settings"),
              ],
            ),
          ),

          //to visually differentiate
          Divider(color: Colors.grey[800], height: 1),

          //the note files section
          //takes up all the space between top and bottom
          Expanded(
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                  child: Text(
                    "Explorer",
                    style: TextStyle(
                      color: Colors.grey[600],
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.5,
                    ),
                  ),
                ),
                Expanded(
                  child: ListView.builder(
                    itemCount: mockFiles.length,
                    itemBuilder: (context, index) {
                      bool isActive = index == 2;
                      return Container(
                        //active file gets lighter background
                        color: isActive
                            ? Colors.white.withValues(alpha: 0.05)
                            : Colors.transparent,
                        child: ListTile(
                          dense: true,
                          visualDensity: const VisualDensity(vertical: -3),
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16,
                          ),
                          title: Text(
                            mockFiles[index],
                            // maxLines: 1, //why prevent wrapping?
                            overflow: TextOverflow
                                .ellipsis, //add ... if name too long (cool)
                            style: TextStyle(
                              fontFamily: 'Courier',
                              fontSize: 13,
                              color: isActive ? textActive : textDim,
                              fontWeight: isActive
                                  ? FontWeight.bold
                                  : FontWeight.normal,
                            ),
                          ),
                          //interact logic
                          onTap: () {},
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),

          Divider(color: Colors.grey[800], height: 1),

          //the session time footer
          Container(
            height: 35,
            padding: const EdgeInsets.symmetric(horizontal: 12),
            color: const Color(0xFF1E1E1E),
            child: Row(
              children: [
                const Icon(Icons.circle, size: 8, color: accentYellow),
                const SizedBox(width: 8),
                Text(
                  "VAULT ONLINE",
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1,
                  ),
                ),
                const Spacer(),

                const Icon(Icons.timer_outlined, size: 14, color: accentYellow),
                const SizedBox(width: 4),
                const Text(
                  "00:42:15",
                  style: TextStyle(
                    fontFamily: 'Courier',
                    color: textDim,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _iconBtn(
    IconData buttonIcon,
    Color buttonColor,
    String buttonTooltip,
  ) {
    return IconButton(
      onPressed: () {},
      icon: Icon(buttonIcon, color: buttonColor, size: 20),
      tooltip: buttonTooltip,
      splashRadius: 20, //???
      constraints: const BoxConstraints(), // removes default padding?
    );
  }
}
