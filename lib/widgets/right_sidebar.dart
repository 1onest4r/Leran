import 'package:flutter/material.dart';

class RightSidebar extends StatefulWidget {
  //accepts data from parent
  final String content;
  final String title;

  const RightSidebar({super.key, required this.content, required this.title});

  @override
  State<RightSidebar> createState() => _RightSidebarState();
}

class _RightSidebarState extends State<RightSidebar> {
  //header
  late TextEditingController _headerController;

  //the body will use custom widget
  late SyntaxHighLightingController _bodyController;

  @override
  void initState() {
    super.initState();
    //initialize with data sent from parent
    _headerController = TextEditingController(text: widget.title);
    _bodyController = SyntaxHighLightingController(text: widget.content);
  }

  //when the user clicks a new file in sidebar, the parent sends new widget.content.
  @override
  void didUpdateWidget(covariant RightSidebar oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.content != widget.content ||
        oldWidget.title != widget.title) {
      _headerController.text = widget.title;
      _bodyController.text = widget.content;
      //move cursor to start
      _bodyController.selection = const TextSelection.collapsed(offset: 0);
    }
  }

  @override
  Widget build(BuildContext context) {
    const Color bgDark = Color(0xFF1E1E1E);
    const Color accentYellow = Colors.yellowAccent;
    const Color borderColor = Color(0xFF424242);

    return Column(
      children: [
        //the editor
        Expanded(
          child: Stack(
            children: [
              //header + body
              Column(
                children: [
                  Container(
                    //paddinig to avoid hamburger menu
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
                        // border: InputBorder.none,
                        enabledBorder: const UnderlineInputBorder(
                          borderSide: BorderSide(color: borderColor, width: 1),
                        ),
                        focusedBorder: const UnderlineInputBorder(
                          borderSide: BorderSide(color: accentYellow, width: 2),
                        ),
                      ),
                    ),
                  ),

                  //the note taking section
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 40),
                      child: TextField(
                        controller: _bodyController, // the custom widget
                        maxLines: null,
                        expands: true,
                        keyboardType: TextInputType.multiline,
                        cursorColor: Colors.white,

                        //ux
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

              //the hamburger
              Positioned(
                top: 20,
                right: 20,
                child: Container(
                  decoration: BoxDecoration(
                    color: const Color(0xFF2D2D2D),
                    borderRadius: BorderRadius.circular(40),
                    border: Border.all(color: Colors.grey.shade700),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.3),
                        blurRadius: 4,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: IconButton(
                    onPressed: () {},
                    icon: const Icon(Icons.menu, color: Colors.white),
                    splashRadius: 20,
                  ),
                ),
              ),
            ],
          ),
        ),

        Container(
          height: 36,
          decoration: const BoxDecoration(
            color: bgDark,
            border: Border(top: BorderSide(color: borderColor)),
          ),
          child: Row(
            children: [
              _bottomTab("Project", isActive: false, accentColor: accentYellow),
              _bottomTab(
                "Research_notes_v2",
                isActive: false,
                accentColor: accentYellow,
              ),
              _bottomTab(
                "Something",
                isActive: false,
                accentColor: accentYellow,
              ),
              _bottomTab(
                "Placeholder",
                isActive: false,
                accentColor: accentYellow,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _bottomTab(
    String text, {
    required bool isActive,
    required Color accentColor,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 15),
      alignment: Alignment.center,
      decoration: BoxDecoration(
        //active tabs get slightly lighter background
        color: isActive ? const Color(0xFF252526) : Colors.transparent,
        border: Border(
          right: const BorderSide(color: Color(0xFF424242), width: 0.5),
          top: isActive
              ? BorderSide(color: accentColor, width: 2)
              : BorderSide.none,
        ),
      ),
      child: Row(
        children: [
          Icon(
            Icons.description_outlined,
            size: 14,
            color: isActive ? accentColor : Colors.grey,
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

class SyntaxHighLightingController extends TextEditingController {
  SyntaxHighLightingController({String? text}) : super(text: text);

  @override
  TextSpan buildTextSpan({
    required BuildContext context,
    TextStyle? style,
    required bool withComposing,
  }) {
    final List<TextSpan> children = [];

    //finds text between " or ' quotes
    //[\s\S] means any character including new lines
    final RegExp pattern = RegExp(r"(['\x22])(?:(?!\1)[\s\S])*\1");

    String currentText = text;
    int currentIndex = 0;

    //scan the text for matches
    for (final Match match in pattern.allMatches(currentText)) {
      //add normal text (grey)
      if (match.start > currentIndex) {
        children.add(
          TextSpan(
            text: currentText.substring(currentIndex, match.start),
            style: style,
          ),
        );
      }

      //add highlighted text (yellow)
      children.add(
        TextSpan(
          text: currentText.substring(match.start, match.end),
          style: style?.copyWith(
            color: Colors.yellowAccent,
            //low opacity white for background
            backgroundColor: Colors.white.withValues(alpha: 0.12),
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
