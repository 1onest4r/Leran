import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import '../../../logic/vault_controller.dart';
import '../../../services/settings_service.dart';
import '../utils/app_dialogs.dart';
import '../utils/search_dialog.dart';

class LeftSidebar extends StatefulWidget {
  final bool isCollapsed;
  final VoidCallback onToggleSidebar;

  const LeftSidebar({
    super.key,
    required this.isCollapsed,
    required this.onToggleSidebar,
  });

  @override
  State<LeftSidebar> createState() => _LeftSidebarState();
}

class _LeftSidebarState extends State<LeftSidebar> {
  Timer? _timer;
  Duration _sessionDuration = Duration.zero;

  @override
  void initState() {
    super.initState();
    _startTimer();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (mounted) {
        setState(() => _sessionDuration += const Duration(seconds: 1));
      }
    });
  }

  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, "0");
    String twoDigitMinutes = twoDigits(duration.inMinutes.remainder(60));
    String twoDigitSeconds = twoDigits(duration.inSeconds.remainder(60));
    return "${twoDigits(duration.inHours)}:$twoDigitMinutes:$twoDigitSeconds";
  }

  void _openSearch(BuildContext context) async {
    final vault = VaultController();
    if (vault.files.isEmpty) return;

    final FileSystemEntity? result = await showDialog<FileSystemEntity?>(
      context: context,
      barrierColor: Colors.black.withOpacity(0.4),
      builder: (context) => SearchDialog(files: vault.files),
    );

    if (result != null) vault.openFile(result);
  }

  void _createNewNote(BuildContext context) async {
    final fileName = await AppDialogs.showNewNoteDialog(context);
    if (fileName != null) {
      VaultController().createNewNote(fileName);
    }
  }

  void _showRenameDialog(BuildContext context) {
    final vault = VaultController();
    final settings = SettingsService();
    final scale = settings.uiScale;
    final String currentName = vault.selectedDirectory!
        .split(Platform.pathSeparator)
        .last;
    final controller = TextEditingController(text: currentName);
    final RegExp invalidChars = RegExp(r'[<>:"/\\|?*]');

    showDialog(
      context: context,
      builder: (context) {
        String? errorText;
        return StatefulBuilder(
          builder: (context, setState) {
            void submit() {
              final text = controller.text.trim();
              if (text.isEmpty) return;
              if (invalidChars.hasMatch(text)) {
                setState(() => errorText = 'Invalid characters');
                return;
              }
              if (text != currentName) vault.renameVault(text);
              Navigator.pop(context);
            }

            return AlertDialog(
              backgroundColor: settings.sidebarColor,
              title: Text(
                "Rename Vault",
                style: TextStyle(color: settings.textColor),
              ),
              content: SizedBox(
                width: 400 * scale,
                child: TextField(
                  controller: controller,
                  autofocus: true,
                  onSubmitted: (_) => submit(),
                  onChanged: (_) {
                    if (errorText != null) setState(() => errorText = null);
                  },
                  style: TextStyle(color: settings.textColor),
                  cursorColor: settings.accentColor,
                  decoration: InputDecoration(
                    hintText: "Enter new folder name",
                    hintStyle: TextStyle(color: settings.dimTextColor),
                    errorText: errorText,
                    enabledBorder: UnderlineInputBorder(
                      borderSide: BorderSide(color: settings.dimTextColor),
                    ),
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
                  onPressed: submit,
                  child: Text(
                    "Rename",
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

    // --- STATE 1: COLLAPSED VIEW (Mini Bar) ---
    if (widget.isCollapsed) {
      return Container(
        color: settings.sidebarColor,
        child: Column(
          children: [
            SizedBox(height: 10 * scale),
            IconButton(
              icon: Icon(
                Icons.keyboard_double_arrow_right,
                color: settings.dimTextColor,
                size: 24 * scale,
              ),
              onPressed: widget.onToggleSidebar,
              tooltip: "Expand Sidebar",
              splashRadius: 20 * scale,
            ),
          ],
        ),
      );
    }

    // --- STATE 2: FULL VIEW ---
    return Container(
      color: settings.sidebarColor,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // --- TOP CONTROLS TRAY ---
          Container(
            padding: EdgeInsets.symmetric(
              vertical: 10 * scale,
              horizontal: 8 * scale,
            ),
            child: LayoutBuilder(
              builder: (context, constraints) {
                // If we have enough width, space them all perfectly evenly
                if (constraints.maxWidth >= 150 * scale) {
                  return Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _iconBtn(
                        Icons.add_box_outlined,
                        settings.accentColor,
                        "New Note",
                        scale,
                        onTap: () => _createNewNote(context),
                      ),
                      _iconBtn(
                        Icons.search,
                        settings.dimTextColor,
                        "Search",
                        scale,
                        onTap: () => _openSearch(context),
                      ),
                      _iconBtn(
                        Icons.settings_outlined,
                        settings.dimTextColor,
                        "Settings",
                        scale,
                        onTap: () => AppDialogs.showSettings(context),
                      ),
                      _iconBtn(
                        Icons.keyboard_double_arrow_left,
                        settings.dimTextColor,
                        "Collapse Sidebar",
                        scale,
                        onTap: widget.onToggleSidebar,
                      ),
                    ],
                  );
                }
                // If it's shrinking, protect the Toggle button by pinning it right, and safely hide the rest
                else {
                  return Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: ClipRect(
                          child: SingleChildScrollView(
                            scrollDirection: Axis.horizontal,
                            physics: const NeverScrollableScrollPhysics(),
                            child: SizedBox(
                              // Force the 3 buttons to stay evenly spaced inside the clipping area
                              width: 110 * scale,
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  _iconBtn(
                                    Icons.add_box_outlined,
                                    settings.accentColor,
                                    "New Note",
                                    scale,
                                    onTap: () => _createNewNote(context),
                                  ),
                                  _iconBtn(
                                    Icons.search,
                                    settings.dimTextColor,
                                    "Search",
                                    scale,
                                    onTap: () => _openSearch(context),
                                  ),
                                  _iconBtn(
                                    Icons.settings_outlined,
                                    settings.dimTextColor,
                                    "Settings",
                                    scale,
                                    onTap: () =>
                                        AppDialogs.showSettings(context),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                      // Pinned to the far right!
                      _iconBtn(
                        Icons.keyboard_double_arrow_left,
                        settings.dimTextColor,
                        "Collapse Sidebar",
                        scale,
                        onTap: widget.onToggleSidebar,
                      ),
                    ],
                  );
                }
              },
            ),
          ),

          Divider(color: settings.dividerColor, height: 1),

          // --- EXPLORER LIST ---
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: EdgeInsets.fromLTRB(
                    16 * scale,
                    16 * scale,
                    16 * scale,
                    8 * scale,
                  ),
                  child: Text(
                    "EXPLORER",
                    style: TextStyle(
                      color: settings.dimTextColor,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.5,
                    ),
                  ),
                ),
                Expanded(
                  child: vault.files.isEmpty
                      ? Center(
                          child: Text(
                            "Empty Folder",
                            style: TextStyle(
                              color: settings.dimTextColor,
                              fontSize: 12,
                            ),
                          ),
                        )
                      : ListView.builder(
                          itemCount: vault.files.length,
                          itemBuilder: (context, index) {
                            final file = vault.files[index];
                            final String fileName = file.uri.pathSegments
                                .lastWhere((s) => s.isNotEmpty);
                            final bool isActive =
                                vault.activeFile != null &&
                                file.path == vault.activeFile!.path;

                            return Container(
                              color: isActive
                                  ? settings.accentColor.withOpacity(0.1)
                                  : Colors.transparent,
                              child: ListTile(
                                dense: true,
                                visualDensity: const VisualDensity(
                                  vertical: -3,
                                ),
                                contentPadding: EdgeInsets.symmetric(
                                  horizontal: 16 * scale,
                                ),
                                leading: Icon(
                                  isActive
                                      ? Icons.edit_document
                                      : Icons.description_outlined,
                                  size: 16 * scale,
                                  color: isActive
                                      ? settings.accentColor
                                      : settings.dimTextColor,
                                ),
                                title: Text(
                                  fileName,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                    fontFamily: 'Courier',
                                    fontSize: 13,
                                    color: isActive
                                        ? settings.textColor
                                        : settings.dimTextColor,
                                    fontWeight: isActive
                                        ? FontWeight.bold
                                        : FontWeight.normal,
                                  ),
                                ),
                                onTap: () => vault.openFile(file),
                              ),
                            );
                          },
                        ),
                ),
              ],
            ),
          ),

          Divider(color: settings.dividerColor, height: 1),

          // --- STATUS BOTTOM BOARD ---
          Container(
            height: 35 * scale,
            padding: EdgeInsets.symmetric(horizontal: 12 * scale),
            color: settings.scaffoldColor,
            child: LayoutBuilder(
              builder: (context, constraints) {
                return Row(
                  children: [
                    Icon(
                      Icons.dns_outlined,
                      size: 12 * scale,
                      color: settings.accentColor,
                    ),
                    SizedBox(width: 8 * scale),

                    Expanded(
                      child: InkWell(
                        onTap: () => _showRenameDialog(context),
                        child: Tooltip(
                          message: "Click to rename folder",
                          child: Text(
                            "${vault.selectedDirectory?.split(Platform.pathSeparator).last.toUpperCase() ?? ''} • ${vault.files.length} ITEMS",
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              color: settings.dimTextColor,
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 1,
                            ),
                          ),
                        ),
                      ),
                    ),

                    if (constraints.maxWidth > 130 * scale) ...[
                      SizedBox(width: 8 * scale),
                      Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: 6 * scale,
                          vertical: 2 * scale,
                        ),
                        decoration: BoxDecoration(
                          color: settings.isDarkMode
                              ? Colors.black26
                              : Colors.black12,
                          borderRadius: BorderRadius.circular(4 * scale),
                        ),
                        child: Text(
                          _formatDuration(_sessionDuration),
                          style: TextStyle(
                            fontFamily: 'Courier',
                            color: settings.dimTextColor,
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _iconBtn(
    IconData icon,
    Color color,
    String tooltip,
    double scale, {
    required VoidCallback onTap,
  }) {
    return IconButton(
      icon: Icon(icon, color: color, size: 20 * scale),
      tooltip: tooltip,
      splashRadius: 20 * scale,
      constraints: const BoxConstraints(),
      padding: EdgeInsets.all(4 * scale),
      onPressed: onTap,
    );
  }
}
