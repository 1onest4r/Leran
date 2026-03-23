import 'dart:io';
import 'package:flutter/material.dart';
import '../../../services/settings_service.dart';

class SearchDialog extends StatefulWidget {
  final List<FileSystemEntity> files;
  const SearchDialog({super.key, required this.files});

  @override
  State<SearchDialog> createState() => _SearchDialogState();
}

class _SearchDialogState extends State<SearchDialog> {
  String _query = '';
  late TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final settings = SettingsService();
    final scale = settings.uiScale;

    // Get screen height for dynamic constraints
    final screenHeight = MediaQuery.of(context).size.height;

    final suggestions = widget.files.where((file) {
      final name = file.uri.pathSegments.last.toLowerCase();
      return name.contains(_query.toLowerCase());
    }).toList();

    return Dialog(
      backgroundColor: settings.sidebarColor,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: settings.dividerColor, width: 1),
      ),
      child: Container(
        width: 500 * scale,
        // THE FIX: Max height is now 80% of the window height, never overflowing
        constraints: BoxConstraints(maxHeight: screenHeight * 0.8),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: EdgeInsets.all(16.0 * scale),
              child: TextField(
                controller: _controller,
                autofocus: true,
                style: TextStyle(color: settings.textColor, fontSize: 16),
                cursorColor: settings.accentColor,
                decoration: InputDecoration(
                  hintText: "Search files by name...",
                  hintStyle: TextStyle(color: settings.dimTextColor),
                  prefixIcon: Icon(
                    Icons.search,
                    color: settings.dimTextColor,
                    size: 24 * scale,
                  ),
                  suffixIcon: _query.isNotEmpty
                      ? IconButton(
                          icon: Icon(
                            Icons.clear,
                            color: settings.dimTextColor,
                            size: 24 * scale,
                          ),
                          onPressed: () {
                            setState(() {
                              _query = '';
                              _controller.clear();
                            });
                          },
                        )
                      : null,
                  filled: true,
                  fillColor: settings.scaffoldColor,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8 * scale),
                    borderSide: BorderSide.none,
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8 * scale),
                    borderSide: BorderSide(
                      color: settings.accentColor,
                      width: 1,
                    ),
                  ),
                ),
                onChanged: (val) => setState(() => _query = val),
              ),
            ),
            Divider(color: settings.dividerColor, height: 1),
            Expanded(
              child: suggestions.isEmpty
                  ? Center(
                      child: Text(
                        "No files found",
                        style: TextStyle(color: settings.dimTextColor),
                      ),
                    )
                  : ListView.builder(
                      itemCount: suggestions.length,
                      itemBuilder: (context, index) {
                        final file = suggestions[index];
                        final name = file.uri.pathSegments.last;
                        return ListTile(
                          contentPadding: EdgeInsets.symmetric(
                            horizontal: 24 * scale,
                            vertical: 4 * scale,
                          ),
                          leading: Icon(
                            Icons.description_outlined,
                            color: settings.dimTextColor,
                            size: 24 * scale,
                          ),
                          title: Text(
                            name,
                            style: TextStyle(color: settings.textColor),
                          ),
                          hoverColor: settings.accentColor.withOpacity(0.1),
                          onTap: () => Navigator.pop(context, file),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
