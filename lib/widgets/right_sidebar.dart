import 'dart:io';
import 'package:flutter/material.dart';

class RightSidebar extends StatefulWidget {
  final String title;
  final String content;
  // 1. New Variables for Tab Management
  final List<FileSystemEntity> openedTabs;
  final FileSystemEntity activeTab;
  final Function(FileSystemEntity) onTabSelected;
  final Function(FileSystemEntity) onTabClosed;

  const RightSidebar({
    super.key,
    required this.title,
    required this.content,
    required this.openedTabs,
    required this.activeTab,
    required this.onTabSelected,
    required this.onTabClosed,
  });

  @override
  State<RightSidebar> createState() => _RightSectionState();
}

class _RightSectionState extends State<RightSidebar> {
  late TextEditingController _headerController;
  late SyntaxHighlightingController _bodyController;

  @override
  void initState() {
    super.initState();
    _headerController = TextEditingController(text: widget.title);
    _bodyController = SyntaxHighlightingController(text: widget.content);
  }

  @override
  void didUpdateWidget(covariant RightSidebar oldWidget) {
    super.didUpdateWidget(oldWidget);
    // If the active file changed, update the text fields
    if (oldWidget.activeTab.path != widget.activeTab.path) {
      _headerController.text = widget.title;
      _bodyController.text = widget.content;
      _bodyController.selection = const TextSelection.collapsed(offset: 0);
    }
  }

  @override
  Widget build(BuildContext context) {
    const Color bgDark = Color(0xFF1E1E1E);
    const Color accentGreen = Color(0xFF52CB8B);
    const Color borderColor = Color(0xFF424242);

    return Column(
      children: [
        // --- EDITOR AREA ---
        Expanded(
          child: Stack(
            children: [
              Column(
                children: [
                  // HEADER
                  Container(
                    padding: const EdgeInsets.fromLTRB(40, 40, 80, 10),
                    child: TextField(
                      controller: _headerController,
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
                        enabledBorder: const UnderlineInputBorder(
                          borderSide: BorderSide(color: borderColor, width: 1),
                        ),
                        focusedBorder: const UnderlineInputBorder(
                          borderSide: BorderSide(color: accentGreen, width: 2),
                        ),
                      ),
                    ),
                  ),

                  // BODY
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 40),
                      child: TextField(
                        controller: _bodyController,
                        maxLines: null,
                        expands: true,
                        keyboardType: TextInputType.multiline,
                        cursorColor: Colors.white,
                        style: const TextStyle(
                          fontSize: 16,
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
              // Menu Button
              Positioned(
                top: 20,
                right: 20,
                child: IconButton(
                  icon: const Icon(Icons.menu, color: Colors.white),
                  onPressed: () {},
                ),
              ),
            ],
          ),
        ),

        // --- DYNAMIC BOTTOM TABS ---
        Container(
          height: 36,
          width: double.infinity, // Ensure it takes full width
          decoration: const BoxDecoration(
            color: bgDark,
            border: Border(top: BorderSide(color: borderColor)),
          ),
          // We use ListView for horizontal scrolling if many tabs are open
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: widget.openedTabs.length,
            itemBuilder: (context, index) {
              final file = widget.openedTabs[index];
              // Calculate filename from path
              final fileName = file.uri.pathSegments.lastWhere(
                (s) => s.isNotEmpty,
              );
              final isActive = file.path == widget.activeTab.path;

              return InkWell(
                onTap: () => widget.onTabSelected(file),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 15),
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: isActive
                        ? const Color(0xFF252526)
                        : Colors.transparent,
                    border: Border(
                      right: const BorderSide(color: borderColor, width: 0.5),
                      // The Active Green Top Border
                      top: isActive
                          ? const BorderSide(color: accentGreen, width: 2)
                          : BorderSide.none,
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.description_outlined,
                        size: 14,
                        color: isActive ? accentGreen : Colors.grey,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        fileName,
                        style: TextStyle(
                          color: isActive ? Colors.white : Colors.grey,
                          fontSize: 12,
                        ),
                      ),
                      const SizedBox(width: 8),
                      // The Close Button (X)
                      InkWell(
                        onTap: () {
                          // Prevent bubbling up to the tab click
                          widget.onTabClosed(file);
                        },
                        borderRadius: BorderRadius.circular(10),
                        child: Icon(
                          Icons.close,
                          size: 14,
                          // Highlight X when active, dim when inactive
                          color: isActive ? Colors.white : Colors.transparent,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}

// Keep your SyntaxHighlightingController class at the bottom...
class SyntaxHighlightingController extends TextEditingController {
  SyntaxHighlightingController({String? text}) : super(text: text);
  @override
  TextSpan buildTextSpan({
    required BuildContext context,
    TextStyle? style,
    required bool withComposing,
  }) {
    final List<TextSpan> children = [];
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
            color: const Color(0xFF52CB8B),
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
