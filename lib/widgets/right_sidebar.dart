import 'dart:io';
import 'package:flutter/material.dart';
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
    if (oldWidget.activeTab.path != widget.activeTab.path) {
      _headerController.text = widget.title;
      _bodyController.text = widget.content;
    }
  }

  void _showRenameDialog() {
    final settings = SettingsService();
    final controller = TextEditingController(text: widget.title);
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: settings.sidebarColor,
        title: Text("Rename", style: TextStyle(color: settings.textColor)),
        content: TextField(
          controller: controller,
          style: TextStyle(color: settings.textColor),
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

  @override
  Widget build(BuildContext context) {
    final settings = SettingsService();

    return AnimatedBuilder(
      animation: settings,
      builder: (context, child) {
        final TextStyle editorStyle = TextStyle(
          fontSize: settings.fontSize,
          fontFamily: settings.fontFamily,
          height: 1.25,
          color: settings.isDarkMode ? Colors.grey[400] : Colors.black87,
        );

        return Column(
          children: [
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
                          readOnly: true,
                          onTap: _showRenameDialog,
                          style: TextStyle(
                            fontSize: 32,
                            fontWeight: FontWeight.bold,
                            fontFamily: 'Courier',
                            color: settings.textColor,
                          ),
                          decoration: InputDecoration(
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
                            decoration: const InputDecoration(
                              border: InputBorder.none,
                              hintText: "Start typing...",
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),

                  // --- UPDATED HAMBURGER MENU ---
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
                        // Font Size Logic
                        if (val == 'zoom_in')
                          settings.setFontSize(settings.fontSize + 2);
                        if (val == 'zoom_out')
                          settings.setFontSize(settings.fontSize - 2);
                      },
                      itemBuilder: (context) => [
                        PopupMenuItem(
                          value: 'save',
                          child: Row(
                            children: [
                              Icon(Icons.save, color: settings.accentColor),
                              SizedBox(width: 8),
                              Text(
                                "Save",
                                style: TextStyle(color: settings.textColor),
                              ),
                            ],
                          ),
                        ),
                        const PopupMenuDivider(),
                        // Font Controls
                        PopupMenuItem(
                          value: 'zoom_in',
                          child: Row(
                            children: [
                              Icon(Icons.zoom_in, color: settings.textColor),
                              SizedBox(width: 8),
                              Text(
                                "Increase Font",
                                style: TextStyle(color: settings.textColor),
                              ),
                            ],
                          ),
                        ),
                        PopupMenuItem(
                          value: 'zoom_out',
                          child: Row(
                            children: [
                              Icon(Icons.zoom_out, color: settings.textColor),
                              SizedBox(width: 8),
                              Text(
                                "Decrease Font",
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
                              SizedBox(width: 8),
                              Text(
                                "Rename",
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
                              SizedBox(width: 8),
                              Text(
                                "Delete",
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
              child: ListView.builder(
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
                        children: [
                          Icon(
                            Icons.description,
                            size: 14,
                            color: isActive
                                ? settings.accentColor
                                : Colors.grey,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            fileName,
                            style: TextStyle(
                              color: isActive
                                  ? settings.textColor
                                  : Colors.grey,
                              fontSize: 12,
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
                              : InkWell(
                                  onTap: () => widget.onTabClosed(file),
                                  child: Icon(
                                    Icons.close,
                                    size: 14,
                                    color: isActive
                                        ? settings.textColor
                                        : Colors.transparent,
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
      },
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
