import 'package:flutter/material.dart';
import 'package:flutter/gestures.dart';
import '../../logic/vault_controller.dart';
import '../../services/settings_service.dart';
import '../utils/app_dialogs.dart';

class RightSidebar extends StatefulWidget {
  const RightSidebar({super.key});

  @override
  State<RightSidebar> createState() => _RightSidebarState();
}

class _RightSidebarState extends State<RightSidebar> {
  late TextEditingController _headerController;
  late SyntaxHighlightingController _bodyController;
  late ScrollController _tabScrollController;

  @override
  void initState() {
    super.initState();
    final vault = VaultController();

    final content = vault.fileContent;
    final int nlIndex = content.indexOf('\n');
    String headText = "";
    String bodyText = "";

    if (content.isEmpty) {
      headText = "";
      bodyText = "";
    } else if (nlIndex == -1) {
      headText = content;
      bodyText = "";
    } else {
      headText = content.substring(0, nlIndex);
      bodyText = content.substring(nlIndex + 1);
    }

    _headerController = TextEditingController(text: headText);
    _bodyController = SyntaxHighlightingController(text: bodyText);
    _tabScrollController = ScrollController();
  }

  @override
  void dispose() {
    _headerController.dispose();
    _bodyController.dispose();
    _tabScrollController.dispose();
    super.dispose();
  }

  void _notifyMergedContent() {
    final vault = VaultController();
    final String merged = "${_headerController.text}\n${_bodyController.text}";
    vault.updateContent(merged);
  }

  void _showRenameDialog() {
    final settings = SettingsService();
    final vault = VaultController();
    if (vault.activeFile == null) return;
    final scale = settings.uiScale;

    String baseName = vault.activeFile!.uri.pathSegments.last;
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
          width: 400 * scale,
          child: SingleChildScrollView(
            child: TextField(
              controller: controller,
              autofocus: true,
              style: TextStyle(color: settings.textColor),
              cursorColor: settings.accentColor,
              onSubmitted: (val) async {
                if (val.isNotEmpty) {
                  final success = await vault.renameActiveNote(val);
                  if (!success && context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text("Name exists or invalid.")),
                    );
                  }
                }
                if (context.mounted) Navigator.pop(context);
              },
              decoration: InputDecoration(
                focusedBorder: UnderlineInputBorder(
                  borderSide: BorderSide(color: settings.accentColor),
                ),
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
            onPressed: () async {
              if (controller.text.isNotEmpty) {
                await vault.renameActiveNote(controller.text);
              }
              if (context.mounted) Navigator.pop(context);
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

  void _manualSave() async {
    final vault = VaultController();
    final success = await vault.saveActiveNote();
    final scale = SettingsService().uiScale;

    if (success && mounted) {
      final settings = SettingsService();
      showDialog(
        context: context,
        barrierColor: Colors.black12,
        barrierDismissible: false,
        builder: (BuildContext dialogContext) {
          Future.delayed(const Duration(milliseconds: 1500), () {
            if (dialogContext.mounted && Navigator.of(dialogContext).canPop()) {
              Navigator.of(dialogContext).pop();
            }
          });
          return AlertDialog(
            backgroundColor: settings.sidebarColor,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
              side: BorderSide(color: settings.dividerColor),
            ),
            contentPadding: EdgeInsets.symmetric(
              vertical: 20 * scale,
              horizontal: 24 * scale,
            ),
            content: SingleChildScrollView(
              child: Row(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.check_circle_outline,
                    color: settings.accentColor,
                    size: 28 * scale,
                  ),
                  SizedBox(width: 12 * scale),
                  Text(
                    "File Saved!",
                    style: TextStyle(
                      color: settings.textColor,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      );
    } else if (!success && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Save failed. Check permissions."),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _deleteCurrent() async {
    final confirm = await AppDialogs.showDeleteConfirmation(context);
    if (confirm) VaultController().deleteActiveNote();
  }

  void _showTextSizeDialog() {
    final settings = SettingsService();
    final scale = settings.uiScale;
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
              setState(() => controller.text = newSize.toInt().toString());
            }

            return AlertDialog(
              backgroundColor: settings.sidebarColor,
              title: Text(
                "Adjust Text Size",
                style: TextStyle(color: settings.textColor),
              ),
              content: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    IconButton(
                      icon: Icon(
                        Icons.chevron_left,
                        color: settings.dimTextColor,
                        size: 30 * scale,
                      ),
                      onPressed: () => updateSize(settings.fontSize - 1),
                    ),
                    SizedBox(
                      width: 60 * scale,
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
                            borderSide: BorderSide(
                              color: settings.dimTextColor,
                            ),
                          ),
                          focusedBorder: UnderlineInputBorder(
                            borderSide: BorderSide(color: settings.accentColor),
                          ),
                        ),
                        onSubmitted: (val) {
                          final parsed = double.tryParse(val);
                          if (parsed != null)
                            updateSize(parsed);
                          else
                            setState(
                              () => controller.text = settings.fontSize
                                  .toInt()
                                  .toString(),
                            );
                        },
                      ),
                    ),
                    IconButton(
                      icon: Icon(
                        Icons.chevron_right,
                        color: settings.dimTextColor,
                        size: 30 * scale,
                      ),
                      onPressed: () => updateSize(settings.fontSize + 1),
                    ),
                  ],
                ),
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
    final vault = VaultController();
    final scale = settings.uiScale;

    return AnimatedBuilder(
      animation: Listenable.merge([settings, vault]),
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
                      Container(
                        padding: EdgeInsets.fromLTRB(
                          40 * scale,
                          40 * scale,
                          80 * scale,
                          10 * scale,
                        ),
                        child: TextField(
                          controller: _headerController,
                          onChanged: (_) => _notifyMergedContent(),
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
                      Expanded(
                        child: Container(
                          padding: EdgeInsets.symmetric(horizontal: 40 * scale),
                          child: TextField(
                            controller: _bodyController,
                            onChanged: (_) => _notifyMergedContent(),
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
                  Positioned(
                    top: 20 * scale,
                    right: 20 * scale,
                    child: PopupMenuButton<String>(
                      icon: Icon(
                        Icons.menu,
                        color: settings.textColor,
                        size: 24 * scale,
                      ),
                      color: settings.sidebarColor,
                      onSelected: (val) {
                        if (val == 'save') _manualSave();
                        if (val == 'rename') _showRenameDialog();
                        if (val == 'delete') _deleteCurrent();
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

            // --- FIXED: BOTTOM TABS TRAY ---
            Container(
              height:
                  36 *
                  scale, // RESTORED to exactly match the left sidebar height (36)
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
                    scrollbars: true,
                    dragDevices: {
                      PointerDeviceKind.touch,
                      PointerDeviceKind.mouse,
                      PointerDeviceKind.trackpad,
                    },
                  ),
                  child: Scrollbar(
                    controller: _tabScrollController,
                    thumbVisibility: true, // Scrollbar visible
                    thickness:
                        2 *
                        scale, // SLIM scrollbar overlays neatly at the bottom edge
                    radius: const Radius.circular(2),
                    child: ListView.builder(
                      controller: _tabScrollController,
                      scrollDirection: Axis.horizontal,
                      itemCount: vault.openedTabs.length,
                      // REMOVED the bottom padding to restore perfectly centered text vertically
                      itemBuilder: (context, index) {
                        final file = vault.openedTabs[index];
                        final fileName = file.uri.pathSegments.lastWhere(
                          (s) => s.isNotEmpty,
                        );
                        final isActive =
                            vault.activeFile != null &&
                            file.path == vault.activeFile!.path;
                        final isUnsaved = vault.unsavedPaths.contains(
                          file.path,
                        );

                        return InkWell(
                          onTap: () => vault.openFile(file),
                          child: Container(
                            padding: EdgeInsets.symmetric(
                              horizontal: 15 * scale,
                            ),
                            alignment: Alignment.center,
                            decoration: BoxDecoration(
                              color: isActive
                                  ? settings.scaffoldColor
                                  : Colors.transparent,
                              border: Border(
                                right: BorderSide(
                                  color: settings.dividerColor,
                                  width: 0.5 * scale,
                                ),
                                top: isActive
                                    ? BorderSide(
                                        color: settings.accentColor,
                                        width: 2 * scale,
                                      )
                                    : BorderSide.none,
                              ),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  Icons.description,
                                  size: 14 * scale,
                                  color: isActive
                                      ? settings.accentColor
                                      : Colors.grey,
                                ),
                                SizedBox(width: 8 * scale),
                                ConstrainedBox(
                                  constraints: BoxConstraints(
                                    maxWidth: 150 * scale,
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
                                SizedBox(width: 8 * scale),
                                isUnsaved
                                    ? Container(
                                        width: 8 * scale,
                                        height: 8 * scale,
                                        decoration: BoxDecoration(
                                          color: settings.textColor,
                                          shape: BoxShape.circle,
                                        ),
                                      )
                                    : _TabCloseButton(
                                        onTap: () => vault.closeTab(file),
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
    final scale = settings.uiScale;
    return MouseRegion(
      onEnter: (_) => setState(() => _isHovering = true),
      onExit: (_) => setState(() => _isHovering = false),
      child: GestureDetector(
        onTap: widget.onTap,
        child: Container(
          padding: EdgeInsets.all(2 * scale),
          child: Icon(
            Icons.close,
            size: 14 * scale,
            color: _isHovering
                ? (settings.isDarkMode ? Colors.white : Colors.black)
                : Colors.grey,
          ),
        ),
      ),
    );
  }
}

class SyntaxHighlightingController extends TextEditingController {
  SyntaxHighlightingController({super.text});
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
