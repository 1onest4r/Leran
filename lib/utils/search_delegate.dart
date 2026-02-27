import 'dart:io';
import 'package:flutter/material.dart';

class FileSearchDelegate extends SearchDelegate<FileSystemEntity?> {
  final List<FileSystemEntity> files;

  FileSearchDelegate(this.files);

  @override
  ThemeData appBarTheme(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    return theme.copyWith(
      appBarTheme: const AppBarTheme(
        backgroundColor: Color(0xFF252526),
        iconTheme: IconThemeData(color: Colors.grey),
        toolbarTextStyle: TextStyle(color: Colors.white),
        titleTextStyle: TextStyle(color: Colors.white, fontSize: 18),
      ),
      inputDecorationTheme: const InputDecorationTheme(
        hintStyle: TextStyle(color: Colors.grey),
        border: InputBorder.none,
      ),
      scaffoldBackgroundColor: const Color(0xFF1E1E1E),
    );
  }

  @override
  List<Widget>? buildActions(BuildContext context) {
    return [
      IconButton(icon: const Icon(Icons.clear), onPressed: () => query = ''),
    ];
  }

  @override
  Widget? buildLeading(BuildContext context) {
    return IconButton(
      icon: const Icon(Icons.arrow_back),
      onPressed: () => close(context, null),
    );
  }

  @override
  Widget buildResults(BuildContext context) => _buildList();

  @override
  Widget buildSuggestions(BuildContext context) => _buildList();

  Widget _buildList() {
    final suggestions = files.where((file) {
      final name = file.uri.pathSegments.last.toLowerCase();
      return name.contains(query.toLowerCase());
    }).toList();

    return ListView.builder(
      itemCount: suggestions.length,
      itemBuilder: (context, index) {
        final file = suggestions[index];
        final name = file.uri.pathSegments.last;

        return ListTile(
          leading: const Icon(Icons.description_outlined, color: Colors.grey),
          title: Text(name, style: const TextStyle(color: Colors.white70)),
          onTap: () => close(context, file),
        );
      },
    );
  }
}
