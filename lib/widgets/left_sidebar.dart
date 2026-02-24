import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';

class LeftSidebar extends StatefulWidget {
  final List<FileSystemEntity> files;
  final FileSystemEntity? selectedFile;
  final Function(FileSystemEntity) onFileSelected;
  final VoidCallback onNewNote;
  final String selectedDirectory;
  final Function(String) onFolderRename;

  const LeftSidebar({
    super.key,
    required this.files,
    required this.selectedFile,
    required this.onFileSelected,
    required this.onNewNote,
    required this.selectedDirectory,
    required this.onFolderRename,
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

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: const Color(0xFF252526),
          title: const Text(
            "Rename Vault",
            style: TextStyle(color: Colors.white),
          ),
          content: TextField(
            controller: controller,
            autofocus: true,
            style: const TextStyle(color: Colors.white),
            cursorColor: const Color(0xFF52CB8B),
            decoration: const InputDecoration(
              hintText: "Enter new folder name",
              hintStyle: TextStyle(color: Colors.grey),
              enabledBorder: UnderlineInputBorder(
                borderSide: BorderSide(color: Colors.grey),
              ),
              focusedBorder: UnderlineInputBorder(
                borderSide: BorderSide(color: Color(0xFF52CB8B)),
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Cancel", style: TextStyle(color: Colors.grey)),
            ),
            TextButton(
              onPressed: () {
                if (controller.text.isNotEmpty &&
                    controller.text != currentName) {
                  widget.onFolderRename(controller.text);
                  Navigator.pop(context);
                }
              },
              child: const Text(
                "Rename",
                style: TextStyle(color: Color(0xFF52CB8B)),
              ),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    const Color bgDark = Color(0xFF252526);
    const Color accentGreen = Color(0xFF52CB8B);
    const Color textDim = Colors.white54;
    const Color textActive = Colors.white;

    return Container(
      color: bgDark,
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
                  accentGreen,
                  "New Note",
                  onTap: widget.onNewNote,
                ),
                _iconBtn(Icons.search, textDim, "Search", onTap: () {}),
                _iconBtn(
                  Icons.hub_outlined,
                  textDim,
                  "Graph View",
                  onTap: () {},
                ),
                _iconBtn(
                  Icons.settings_outlined,
                  textDim,
                  "Settings",
                  onTap: () {},
                ),
              ],
            ),
          ),

          Divider(color: Colors.grey[800], height: 1),

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
                      color: Colors.grey[500],
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
                            style: TextStyle(color: textDim, fontSize: 12),
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
                                  ? accentGreen.withOpacity(0.1)
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
                                  color: isActive ? accentGreen : textDim,
                                ),
                                title: Text(
                                  fileName,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                    fontFamily: 'Courier',
                                    fontSize: 13,
                                    color: isActive ? textActive : textDim,
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

          Divider(color: Colors.grey[800], height: 1),

          // --- LIVE FOOTER ---
          Container(
            height: 35,
            padding: const EdgeInsets.symmetric(horizontal: 12),
            color: const Color(0xFF1E1E1E),
            child: Row(
              children: [
                const Icon(
                  Icons.dns_outlined,
                  size: 12,
                  color: Color(0xFF52CB8B),
                ),
                const SizedBox(width: 8),

                // 1. FOLDER NAME (EXPANDED)
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
                          color: Colors.grey[500],
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1,
                        ),
                      ),
                    ),
                  ),
                ),

                // I REMOVED THE SPACER() HERE - Expanded above handles the push
                const SizedBox(width: 8),

                // 2. SESSION TIMER
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 6,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.black26,
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    _formatDuration(_sessionDuration),
                    style: TextStyle(
                      fontFamily: 'Courier',
                      color: textDim,
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
