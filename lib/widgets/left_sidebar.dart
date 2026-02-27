import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import '../services/settings_service.dart';

class LeftSidebar extends StatefulWidget {
  final List<FileSystemEntity> files;
  final FileSystemEntity? selectedFile;
  final Function(FileSystemEntity) onFileSelected;
  final VoidCallback onNewNote;
  final String selectedDirectory;
  final Function(String) onFolderRename;
  final VoidCallback onSearchClick;
  final VoidCallback onSettingsClick;

  const LeftSidebar({
    super.key,
    required this.files,
    required this.selectedFile,
    required this.onFileSelected,
    required this.onNewNote,
    required this.selectedDirectory,
    required this.onFolderRename,
    required this.onSearchClick,
    required this.onSettingsClick,
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
      setState(() {
        _sessionDuration += const Duration(seconds: 1);
      });
    });
  }

  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, "0");
    String twoDigitMinutes = twoDigits(duration.inMinutes.remainder(60));
    String twoDigitSeconds = twoDigits(duration.inSeconds.remainder(60));
    return "${twoDigits(duration.inHours)}:$twoDigitMinutes:$twoDigitSeconds";
  }

  void _showRenameDialog() {
    final String currentName = widget.selectedDirectory
        .split(Platform.pathSeparator)
        .last;
    final TextEditingController controller = TextEditingController(
      text: currentName,
    );
    final RegExp invalidChars = RegExp(r'[<>:"/\\|?*]');
    final settings = SettingsService();

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
              if (text != currentName) {
                widget.onFolderRename(text);
                Navigator.pop(context);
              } else {
                Navigator.pop(context);
              }
            }

            return AlertDialog(
              backgroundColor: settings.sidebarColor,
              title: Text(
                "Rename Vault",
                style: TextStyle(color: settings.textColor),
              ),
              content: TextField(
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
    // Access dynamic settings
    final settings = SettingsService();

    return Container(
      color: settings.sidebarColor,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // --- TOP ICONS ---
          Container(
            padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _iconBtn(
                  Icons.add_box_outlined,
                  settings.accentColor,
                  "New Note",
                  onTap: widget.onNewNote,
                ),
                _iconBtn(
                  Icons.search,
                  settings.dimTextColor,
                  "Search",
                  onTap: widget.onSearchClick,
                ),
                _iconBtn(
                  Icons.hub_outlined,
                  settings.dimTextColor,
                  "Graph View",
                  onTap: () {},
                ),
                _iconBtn(
                  Icons.settings_outlined,
                  settings.dimTextColor,
                  "Settings",
                  onTap: widget.onSettingsClick,
                ),
              ],
            ),
          ),

          Divider(color: settings.dividerColor, height: 1),

          // --- FILE LIST ---
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
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
                  child: widget.files.isEmpty
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
                          itemCount: widget.files.length,
                          itemBuilder: (context, index) {
                            final file = widget.files[index];
                            final String fileName = file.uri.pathSegments
                                .lastWhere((s) => s.isNotEmpty);
                            final bool isActive =
                                widget.selectedFile != null &&
                                file.path == widget.selectedFile!.path;

                            return Container(
                              color: isActive
                                  ? settings.accentColor.withOpacity(0.1)
                                  : Colors.transparent,
                              child: ListTile(
                                dense: true,
                                visualDensity: const VisualDensity(
                                  vertical: -3,
                                ),
                                contentPadding: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                ),
                                leading: Icon(
                                  isActive
                                      ? Icons.edit_document
                                      : Icons.description_outlined,
                                  size: 16,
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
                                onTap: () => widget.onFileSelected(file),
                              ),
                            );
                          },
                        ),
                ),
              ],
            ),
          ),

          Divider(color: settings.dividerColor, height: 1),

          // --- LIVE FOOTER ---
          Container(
            height: 35,
            padding: const EdgeInsets.symmetric(horizontal: 12),
            color: settings.scaffoldColor, // Match Main BG for contrast
            child: Row(
              children: [
                Icon(Icons.dns_outlined, size: 12, color: settings.accentColor),
                const SizedBox(width: 8),

                Expanded(
                  child: InkWell(
                    onTap: _showRenameDialog,
                    child: Tooltip(
                      message: "Click to rename folder",
                      child: Text(
                        "${widget.selectedDirectory.split(Platform.pathSeparator).last.toUpperCase()} • ${widget.files.length} ITEMS",
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

                const SizedBox(width: 8),

                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 6,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    color: settings.isDarkMode
                        ? Colors.black26
                        : Colors.black12,
                    borderRadius: BorderRadius.circular(4),
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
            ),
          ),
        ],
      ),
    );
  }

  Widget _iconBtn(
    IconData icon,
    Color color,
    String tooltip, {
    required VoidCallback onTap,
  }) {
    return IconButton(
      icon: Icon(icon, color: color, size: 20),
      tooltip: tooltip,
      splashRadius: 20,
      constraints: const BoxConstraints(),
      padding: EdgeInsets.zero,
      onPressed: onTap,
    );
  }
}
