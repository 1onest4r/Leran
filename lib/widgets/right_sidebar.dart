import 'package:flutter/material.dart';

class RightSidebar extends StatefulWidget {
  const RightSidebar({super.key});

  @override
  State<RightSidebar> createState() => _RightSectionState();
}

class _RightSectionState extends State<RightSidebar> {
  final TextEditingController _titleController = TextEditingController(
    text: "Project_Botanical.md",
  );
  late SyntaxHighlightingController _bodyController;

  @override
  void initState() {
    super.initState();
    String initialText =
        """The visualization of complex networks often benefits from 'organic algorithms'. 

By simulating natural growth patterns, we can uncover clusters that strictly hierarchical layouts might obscure.

"OBSERVATION
The node density increases towards the upper right quadrant
and this sentence spans multiple lines safely."

The end.""";

    _bodyController = SyntaxHighlightingController(text: initialText);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // --- MAIN EDITING AREA ---
        Expanded(
          child: Stack(
            children: [
              Column(
                children: [
                  // 1. THE HEADER
                  Container(
                    padding: const EdgeInsets.fromLTRB(40, 40, 80, 10),
                    child: TextField(
                      controller: _titleController,
                      cursorColor: Colors.white,
                      style: const TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                        fontFamily: 'Courier',
                        color: Colors.white,
                      ),
                      decoration: InputDecoration(
                        hintText: "Untitled.md",
                        hintStyle: TextStyle(color: Colors.grey[700]),
                        border: InputBorder.none,
                        enabledBorder: UnderlineInputBorder(
                          borderSide: BorderSide(
                            color: Colors.grey.shade800,
                            width: 1,
                          ),
                        ),
                        focusedBorder: const UnderlineInputBorder(
                          borderSide: BorderSide(
                            color: Colors.yellowAccent,
                            width: 2,
                          ),
                        ),
                      ),
                    ),
                  ),

                  // 2. THE BODY
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 40),
                      child: TextField(
                        controller: _bodyController,
                        maxLines: null,
                        expands: true,
                        keyboardType: TextInputType.multiline,
                        cursorColor: Colors.white,

                        // --- VISUAL FIX IS HERE ---
                        style: const TextStyle(
                          fontSize: 16,
                          // Changed from 1.6 to 1.25.
                          // This closes the gaps so the background looks like a solid block.
                          height: 1.25,
                          color: Colors.grey,
                          fontFamily: 'Courier',
                        ),
                        decoration: const InputDecoration(
                          border: InputBorder.none,
                          hintText: "Start typing...",
                        ),
                      ),
                    ),
                  ),
                ],
              ),

              // Hamburger Menu
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

        // --- BOTTOM TABS ---
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

// --- LOGIC ENGINE ---
class SyntaxHighlightingController extends TextEditingController {
  SyntaxHighlightingController({String? text}) : super(text: text);

  @override
  TextSpan buildTextSpan({
    required BuildContext context,
    TextStyle? style,
    required bool withComposing,
  }) {
    final List<TextSpan> children = [];

    // Regex that catches quotes across multiple lines
    final RegExp pattern = RegExp(r"(['\x22])(?:(?!\1)[\s\S])*\1");

    String currentText = text;
    int currentIndex = 0;

    for (final Match match in pattern.allMatches(currentText)) {
      if (match.start > currentIndex) {
        children.add(
          TextSpan(
            text: currentText.substring(currentIndex, match.start),
            style: style,
          ),
        );
      }

      children.add(
        TextSpan(
          text: currentText.substring(match.start, match.end),
          style: style?.copyWith(
            color: Colors.yellowAccent,
            // Using a slightly more opaque background helps blend the lines
            backgroundColor: Colors.white.withOpacity(0.12),
            fontWeight: FontWeight.bold,
          ),
        ),
      );

      currentIndex = match.end;
    }

    if (currentIndex < currentText.length) {
      children.add(
        TextSpan(text: currentText.substring(currentIndex), style: style),
      );
    }

    return TextSpan(style: style, children: children);
  }
}
