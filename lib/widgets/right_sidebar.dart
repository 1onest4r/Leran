import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/gestures.dart';
import '../services/settings_service.dart';

class RightSidebar extends StatefulWidget {
  final String title;
  final String content;
  final List<FileSystemEntity> openedTabs;
  final FileSystemEntity activeTab;
  final Set<String> unsavedPaths;

  final Function(FileSystemEntity) onTabSelected;
  final Function(FileSystemEntity) onTabClosed;
  final Function(String) onContentChanged;
  final VoidCallback onManualSave;
  final Function() onDelete;
  final Function(String) onRename;

  const RightSidebar({
    super.key,
    required this.title,
    required this.content,
    required this.openedTabs,
    required this.activeTab,
    required this.unsavedPaths,
    required this.onTabSelected,
    required this.onTabClosed,
    required this.onContentChanged,
    required this.onManualSave,
    required this.onDelete,
    required this.onRename,
  });

  @override
  State<RightSidebar> createState() => _RightSidebarState();
}

class _RightSidebarState extends State<RightSidebar> {
  // RESTORED: The header controller
  late TextEditingController _headerController;
  late SyntaxHighlightingController _bodyController;
  late ScrollController _tabScrollController;

  @override
  void initState() {
    super.initState();
    // Starts empty so it shows the placeholder instead of the file name
    _headerController = TextEditingController();
    _bodyController = SyntaxHighlightingController(text: widget.content);
    _tabScrollController = ScrollController();
  }

  @override
  void dispose() {
    _headerController.dispose();
    _bodyController.dispose();
    _tabScrollController.dispose();
    super.dispose();
  }

  @override
  void didUpdateWidget(covariant RightSidebar oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.activeTab.path != widget.activeTab.path) {
      _headerController.clear(); // Clear the custom title when switching tabs
      _bodyController.text = widget.content;
    }
  }

  void _showRenameDialog() {
    final settings = SettingsService();

    // Strip the extension from the text field so user just edits the base name
    String baseName = widget.title;
    if (baseName.endsWith('.md'))
      baseName = baseName.substring(0, baseName.length - 3);
    if (baseName.endsWith('.txt'))
      baseName = baseName.substring(0, baseName.length - 4);

    final controller = TextEditingController(text: baseName);
    controller.selection = TextSelection(
      baseOffset: 0,
      extentOffset: baseName.length,
    );

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: settings.sidebarColor,
        title: Text("Rename File", style: TextStyle(color: settings.textColor)),
        content: SizedBox(
          width: 400,
          child: TextField(
            controller: controller,
            autofocus: true,
            style: TextStyle(color: settings.textColor),
            cursorColor: settings.accentColor,
            onSubmitted: (val) {
              if (val.isNotEmpty) widget.onRename(val);
              Navigator.pop(context);
            },
            decoration: InputDecoration(
              focusedBorder: UnderlineInputBorder(
                borderSide: BorderSide(color: settings.accentColor),
              ),
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              "Cancel",
              style: TextStyle(color: settings.dimTextColor),
            ),
          ),
          TextButton(
            onPressed: () {
              if (controller.text.isNotEmpty) widget.onRename(controller.text);
              Navigator.pop(context);
            },
            child: Text(
              "Rename",
              style: TextStyle(color: settings.accentColor),
            ),
          ),
        ],
      ),
    );
  }

  void _showTextSizeDialog() {
    final settings = SettingsService();
    final TextEditingController controller = TextEditingController(
      text: settings.fontSize.toInt().toString(),
    );

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            void updateSize(double newSize) {
              if (newSize < 10) newSize = 10;
              if (newSize > 48) newSize = 48;
              settings.setFontSize(newSize);
              setState(() {
                controller.text = newSize.toInt().toString();
              });
            }

            return AlertDialog(
              backgroundColor: settings.sidebarColor,
              title: Text(
                "Adjust Text Size",
                style: TextStyle(color: settings.textColor),
              ),
              content: Row(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  IconButton(
                    icon: Icon(
                      Icons.chevron_left,
                      color: settings.dimTextColor,
                      size: 30,
                    ),
                    onPressed: () => updateSize(settings.fontSize - 1),
                  ),
                  SizedBox(
                    width: 60,
                    child: TextField(
                      controller: controller,
                      keyboardType: TextInputType.number,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: settings.textColor,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                      decoration: InputDecoration(
                        enabledBorder: UnderlineInputBorder(
                          borderSide: BorderSide(color: settings.dimTextColor),
                        ),
                        focusedBorder: UnderlineInputBorder(
                          borderSide: BorderSide(color: settings.accentColor),
                        ),
                      ),
                      onSubmitted: (val) {
                        final parsed = double.tryParse(val);
                        if (parsed != null) {
                          updateSize(parsed);
                        } else {
                          setState(() {
                            controller.text = settings.fontSize
                                .toInt()
                                .toString();
                          });
                        }
                      },
                    ),
                  ),
                  IconButton(
                    icon: Icon(
                      Icons.chevron_right,
                      color: settings.dimTextColor,
                      size: 30,
                    ),
                    onPressed: () => updateSize(settings.fontSize + 1),
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text(
                    "Done",
                    style: TextStyle(color: settings.accentColor),
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final settings = SettingsService();

    return AnimatedBuilder(
      animation: settings,
      builder: (context, child) {
        final TextStyle editorStyle = TextStyle(
          fontSize: settings.fontSize,
          fontFamily: settings.fontFamily,
          height: 1.5,
          color: settings.isDarkMode ? Colors.grey[400] : Colors.black87,
        );

        return Column(
          children: [
            Expanded(
              child: Stack(
                children: [
                  Column(
                    children: [
                      // RESTORED: HEADER
                      Container(
                        padding: const EdgeInsets.fromLTRB(40, 40, 80, 10),
                        child: TextField(
                          controller: _headerController,
                          // No longer readOnly, user can type here freely!
                          style: TextStyle(
                            fontSize: 32,
                            fontWeight: FontWeight.bold,
                            fontFamily: 'Courier',
                            color: settings.textColor,
                          ),
                          decoration: InputDecoration(
                            hintText: "Add a title...",
                            hintStyle: TextStyle(
                              color: settings.dimTextColor.withOpacity(0.5),
                              fontStyle: FontStyle.italic,
                            ),
                            border: InputBorder.none,
                            enabledBorder: UnderlineInputBorder(
                              borderSide: BorderSide(
                                color: settings.dividerColor,
                                width: 1,
                              ),
                            ),
                            focusedBorder: UnderlineInputBorder(
                              borderSide: BorderSide(
                                color: settings.accentColor,
                                width: 2,
                              ),
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
                            onChanged: widget.onContentChanged,
                            style: editorStyle,
                            maxLines: null,
                            expands: true,
                            keyboardType: TextInputType.multiline,
                            cursorColor: settings.textColor,
                            decoration: InputDecoration(
                              border: InputBorder.none,
                              hintText: "Start writing...",
                              hintStyle: TextStyle(
                                color: settings.dimTextColor.withOpacity(0.4),
                                fontStyle: FontStyle.italic,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),

                  // HAMBURGER MENU
                  Positioned(
                    top: 20,
                    right: 20,
                    child: PopupMenuButton<String>(
                      icon: Icon(Icons.menu, color: settings.textColor),
                      color: settings.sidebarColor,
                      onSelected: (val) {
                        if (val == 'save') widget.onManualSave();
                        if (val == 'rename') _showRenameDialog();
                        if (val == 'delete') widget.onDelete();
                        if (val == 'font_size') _showTextSizeDialog();
                      },
                      itemBuilder: (context) => [
                        PopupMenuItem(
                          value: 'save',
                          child: Row(
                            children: [
                              Icon(Icons.save, color: settings.accentColor),
                              const SizedBox(width: 8),
                              Text(
                                "Save",
                                style: TextStyle(color: settings.textColor),
                              ),
                            ],
                          ),
                        ),
                        const PopupMenuDivider(),
                        PopupMenuItem(
                          value: 'font_size',
                          child: Row(
                            children: [
                              Icon(
                                Icons.format_size,
                                color: settings.textColor,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                "Text Size",
                                style: TextStyle(color: settings.textColor),
                              ),
                            ],
                          ),
                        ),
                        const PopupMenuDivider(),
                        PopupMenuItem(
                          value: 'rename',
                          child: Row(
                            children: [
                              Icon(Icons.edit, color: settings.textColor),
                              const SizedBox(width: 8),
                              Text(
                                "Rename File",
                                style: TextStyle(color: settings.textColor),
                              ),
                            ],
                          ),
                        ),
                        PopupMenuItem(
                          value: 'delete',
                          child: Row(
                            children: [
                              Icon(Icons.delete, color: Colors.red),
                              const SizedBox(width: 8),
                              Text(
                                "Delete File",
                                style: TextStyle(color: Colors.red),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // BOTTOM TABS
            Container(
              height: 36,
              width: double.infinity,
              decoration: BoxDecoration(
                color: settings.sidebarColor,
                border: Border(top: BorderSide(color: settings.dividerColor)),
              ),
              child: Listener(
                onPointerSignal: (pointerSignal) {
                  if (pointerSignal is PointerScrollEvent) {
                    final offset = pointerSignal.scrollDelta.dy;
                    _tabScrollController.jumpTo(
                      (_tabScrollController.offset + offset).clamp(
                        0.0,
                        _tabScrollController.position.maxScrollExtent,
                      ),
                    );
                  }
                },
                child: ScrollConfiguration(
                  behavior: ScrollConfiguration.of(context).copyWith(
                    scrollbars: false,
                    dragDevices: {
                      PointerDeviceKind.touch,
                      PointerDeviceKind.mouse,
                      PointerDeviceKind.trackpad,
                    },
                  ),
                  child: ListView.builder(
                    controller: _tabScrollController,
                    scrollDirection: Axis.horizontal,
                    itemCount: widget.openedTabs.length,
                    itemBuilder: (context, index) {
                      final file = widget.openedTabs[index];
                      final fileName = file.uri.pathSegments.lastWhere(
                        (s) => s.isNotEmpty,
                      );
                      final isActive = file.path == widget.activeTab.path;
                      final isUnsaved = widget.unsavedPaths.contains(file.path);

                      return InkWell(
                        onTap: () => widget.onTabSelected(file),
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 15),
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                            color: isActive
                                ? settings.scaffoldColor
                                : Colors.transparent,
                            border: Border(
                              right: BorderSide(
                                color: settings.dividerColor,
                                width: 0.5,
                              ),
                              top: isActive
                                  ? BorderSide(
                                      color: settings.accentColor,
                                      width: 2,
                                    )
                                  : BorderSide.none,
                            ),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.description,
                                size: 14,
                                color: isActive
                                    ? settings.accentColor
                                    : Colors.grey,
                              ),
                              const SizedBox(width: 8),
                              ConstrainedBox(
                                constraints: const BoxConstraints(
                                  maxWidth: 150,
                                ),
                                child: Text(
                                  fileName,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                    color: isActive
                                        ? settings.textColor
                                        : Colors.grey,
                                    fontSize: 12,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 8),
                              isUnsaved
                                  ? Container(
                                      width: 8,
                                      height: 8,
                                      decoration: BoxDecoration(
                                        color: settings.textColor,
                                        shape: BoxShape.circle,
                                      ),
                                    )
                                  : _TabCloseButton(
                                      onTap: () => widget.onTabClosed(file),
                                    ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}

class _TabCloseButton extends StatefulWidget {
  final VoidCallback onTap;

  const _TabCloseButton({required this.onTap});

  @override
  State<_TabCloseButton> createState() => _TabCloseButtonState();
}

class _TabCloseButtonState extends State<_TabCloseButton> {
  bool _isHovering = false;

  @override
  Widget build(BuildContext context) {
    final settings = SettingsService();

    Color hoverColor = settings.isDarkMode ? Colors.white : Colors.black;
    Color defaultColor = Colors.grey;

    return MouseRegion(
      onEnter: (_) => setState(() => _isHovering = true),
      onExit: (_) => setState(() => _isHovering = false),
      child: GestureDetector(
        onTap: widget.onTap,
        child: Container(
          padding: const EdgeInsets.all(2),
          child: Icon(
            Icons.close,
            size: 14,
            color: _isHovering ? hoverColor : defaultColor,
          ),
        ),
      ),
    );
  }
}

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
      if (match.start > currentIndex)
        children.add(
          TextSpan(
            text: currentText.substring(currentIndex, match.start),
            style: style,
          ),
        );
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
    if (currentIndex < currentText.length)
      children.add(
        TextSpan(text: currentText.substring(currentIndex), style: style),
      );
    return TextSpan(style: style, children: children);
  }
}
