import 'dart:io';
import 'package:flutter/material.dart';
import '../services/settings_service.dart';

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
    // Listen to our settings for accurate Light/Dark mode colors
    final settings = SettingsService();

    // Filter files based on search text
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
        width: 500, // Fixed width so it looks like a command palette
        constraints: const BoxConstraints(maxHeight: 450),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // --- SEARCH INPUT ---
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: TextField(
                controller: _controller,
                autofocus: true,
                style: TextStyle(color: settings.textColor, fontSize: 16),
                cursorColor: settings.accentColor,
                decoration: InputDecoration(
                  hintText: "Search files by name...",
                  hintStyle: TextStyle(color: settings.dimTextColor),
                  prefixIcon: Icon(Icons.search, color: settings.dimTextColor),
                  suffixIcon: _query.isNotEmpty
                      ? IconButton(
                          icon: Icon(Icons.clear, color: settings.dimTextColor),
                          onPressed: () {
                            setState(() {
                              _query = '';
                              _controller.clear();
                            });
                          },
                        )
                      : null,
                  filled: true,
                  fillColor: settings.scaffoldColor, // Contrasts nicely
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide.none,
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide(
                      color: settings.accentColor,
                      width: 1,
                    ),
                  ),
                ),
                onChanged: (val) {
                  setState(() {
                    _query = val;
                  });
                },
              ),
            ),

            Divider(color: settings.dividerColor, height: 1),

            // --- SEARCH RESULTS ---
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
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 24,
                            vertical: 4,
                          ),
                          leading: Icon(
                            Icons.description_outlined,
                            color: settings.dimTextColor,
                          ),
                          title: Text(
                            name,
                            style: TextStyle(color: settings.textColor),
                          ),
                          hoverColor: settings.accentColor.withOpacity(0.1),
                          onTap: () {
                            // Return the selected file back to the home page
                            Navigator.pop(context, file);
                          },
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
