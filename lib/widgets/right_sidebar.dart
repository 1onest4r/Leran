import 'package:flutter/material.dart';

class RightSidebar extends StatelessWidget {
  const RightSidebar({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // --- 1. THE MAIN CONTENT AREA (Expanded) ---
        Expanded(
          child: Stack(
            children: [
              // Scrollable Content
              SingleChildScrollView(
                padding: const EdgeInsets.all(40),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Title
                    const Text(
                      "Project_Botanical.md",
                      style: TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                        fontFamily: 'Courier',
                        color: Colors.white,
                      ),
                    ),

                    const SizedBox(height: 10),
                    Divider(color: Colors.grey[800]),
                    const SizedBox(height: 30),

                    // Subheader
                    const Text(
                      "Organic structures in data visualization",
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        fontFamily: 'Courier',
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 15),

                    // Paragraph text
                    RichText(
                      text: const TextSpan(
                        style: TextStyle(
                          fontSize: 16,
                          height: 1.6,
                          color: Colors.grey,
                          fontFamily: 'sans-serif',
                        ),
                        children: [
                          TextSpan(
                            text:
                                "The visualization of complex networks often benefits from ",
                          ),
                          TextSpan(
                            text: "`organic algorithms`", // Inline code style
                            style: TextStyle(
                              color: Colors.yellowAccent,
                              backgroundColor: Color(0xFF2D2D2D),
                              fontFamily: 'Courier',
                            ),
                          ),
                          TextSpan(
                            text:
                                ". By simulating natural growth patterns, we can uncover clusters that strictly hierarchical layouts might obscure.",
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 30),

                    // The "Observation" Box (Blockquote)
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: const Color(0xFF252526),
                        border: Border(
                          left: BorderSide(
                            color: Colors.yellowAccent.withOpacity(0.8),
                            width: 4,
                          ),
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "OBSERVATION",
                            style: TextStyle(
                              color: Colors.yellowAccent.withOpacity(0.8),
                              fontWeight: FontWeight.bold,
                              fontSize: 12,
                              letterSpacing: 1,
                            ),
                          ),
                          const SizedBox(height: 8),
                          const Text(
                            "The node density increases towards the upper right quadrant, suggesting a strong correlation between the Umbel structures and the temporal data points collected in Q3.",
                            style: TextStyle(color: Colors.grey, fontSize: 14),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 50),
                    // Just a visual end marker to show where the note ends
                    Center(
                      child: Icon(Icons.more_horiz, color: Colors.grey[800]),
                    ),
                  ],
                ),
              ),

              // Hamburger Menu (Top Right)
              Positioned(
                top: 20,
                right: 20,
                child: Container(
                  decoration: BoxDecoration(
                    color: const Color(0xFF2D2D2D),
                    borderRadius: BorderRadius.circular(4),
                    border: Border.all(color: Colors.grey.shade700),
                  ),
                  child: IconButton(
                    icon: const Icon(Icons.menu, color: Colors.white),
                    onPressed: () {},
                  ),
                ),
              ),
            ],
          ),
        ),

        // --- 2. BOTTOM TABS ---
        Container(
          height: 35,
          decoration: BoxDecoration(
            color: const Color(0xFF1E1E1E),
            border: Border(top: BorderSide(color: Colors.grey.shade800)),
          ),
          child: Row(
            children: [
              _bottomTab("Project_Botanical", isActive: true),
              _bottomTab("research_notes_v2", isActive: false),
              _bottomTab("Canva: Q4 Goals", isActive: false),
              Container(
                width: 35,
                alignment: Alignment.center,
                child: const Icon(Icons.add, size: 16, color: Colors.grey),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _bottomTab(String text, {required bool isActive}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 15),
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: isActive ? const Color(0xFF252526) : Colors.transparent,
        border: Border(
          right: BorderSide(color: Colors.grey.shade800, width: 0.5),
          top: isActive
              ? const BorderSide(color: Colors.yellowAccent, width: 2)
              : BorderSide.none,
        ),
      ),
      child: Row(
        children: [
          Icon(
            Icons.description_outlined,
            size: 14,
            color: isActive ? Colors.yellowAccent : Colors.grey,
          ),
          const SizedBox(width: 8),
          Text(
            text,
            style: TextStyle(
              color: isActive ? Colors.white : Colors.grey,
              fontSize: 12,
            ),
          ),
          if (isActive) ...[
            const SizedBox(width: 8),
            const Icon(Icons.close, size: 12, color: Colors.white),
          ],
        ],
      ),
    );
  }
}
