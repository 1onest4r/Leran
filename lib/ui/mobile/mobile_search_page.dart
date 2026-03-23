import 'package:flutter/material.dart';
import '../../services/settings_service.dart';

class MobileSearchPage extends StatefulWidget {
  const MobileSearchPage({super.key});

  @override
  State<MobileSearchPage> createState() => _MobileSearchPageState();
}

class _MobileSearchPageState extends State<MobileSearchPage> {
  String _query = '';
  final TextEditingController _searchController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final settings = SettingsService();

    // Note: Mocking data right now, replace `mockNotes` with `vault.files` logic later
    final mockNotes = [
      "Shopping List",
      "Ideas 01",
      "Meeting notes 23/03",
      "Daily Journal",
    ];
    final suggestions = mockNotes
        .where((note) => note.toLowerCase().contains(_query.toLowerCase()))
        .toList();

    return Scaffold(
      backgroundColor: settings.scaffoldColor,
      appBar: AppBar(
        backgroundColor: settings.sidebarColor,
        iconTheme: IconThemeData(color: settings.textColor),
        titleSpacing: 0,
        elevation: 1,
        // SEARCH INPUT RIGHT INSIDE THE APPBAR
        title: TextField(
          controller: _searchController,
          autofocus: true,
          style: TextStyle(color: settings.textColor, fontSize: 18),
          cursorColor: settings.accentColor,
          decoration: InputDecoration(
            hintText: "Search notes...",
            hintStyle: TextStyle(color: settings.dimTextColor),
            border: InputBorder.none,
            suffixIcon: _query.isNotEmpty
                ? IconButton(
                    icon: Icon(Icons.close, color: settings.dimTextColor),
                    onPressed: () {
                      _searchController.clear();
                      setState(() => _query = "");
                    },
                  )
                : null,
          ),
          onChanged: (val) => setState(() => _query = val),
        ),
      ),
      body: suggestions.isEmpty && _query.isNotEmpty
          ? Center(
              child: Text(
                "No results for '$_query'",
                style: TextStyle(color: settings.dimTextColor),
              ),
            )
          : ListView.separated(
              itemCount: suggestions.length,
              separatorBuilder: (context, index) =>
                  Divider(color: settings.dividerColor, height: 1, indent: 16),
              itemBuilder: (context, index) {
                return ListTile(
                  leading: Icon(
                    Icons.description_outlined,
                    color: settings.dimTextColor,
                  ),
                  title: Text(
                    suggestions[index],
                    style: TextStyle(color: settings.textColor),
                  ),
                  onTap: () {
                    // Tap on a search result to go to editor later
                    FocusScope.of(context).unfocus(); // Drops the keyboard
                  },
                );
              },
            ),
    );
  }
}
