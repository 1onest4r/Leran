import 'dart:io';
import 'package:flutter/material.dart';
import '../../services/settings_service.dart';

/// UI LAYER: Command Palette
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
        width: 500,
        constraints: const BoxConstraints(maxHeight: 450),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
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
                  fillColor: settings.scaffoldColor,
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
