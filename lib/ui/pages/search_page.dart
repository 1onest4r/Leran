import 'dart:io';
import 'package:flutter/material.dart';
import '../../logic/folder_logic.dart';
import '../../data/models/note.dart';
import '../styling/resizable_split_view.dart';
import 'note_editor_page.dart';

class SearchPage extends StatefulWidget {
  final FolderLogic folderLogic;

  const SearchPage({super.key, required this.folderLogic});

  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  final TextEditingController _searchController = TextEditingController();
  List<Note> _searchResults = [];
  bool _isSearching = false;
  Note? _selectedNote;

  @override
  void initState() {
    super.initState();
    _loadRecentNotes();
  }

  Future<void> _loadRecentNotes() async {
    final recent = await widget.folderLogic.dbService.getRecentNotes();
    setState(() => _searchResults = recent);
  }

  Future<void> _performSearch(String query) async {
    if (query.trim().isEmpty) {
      setState(() => _isSearching = false);
      _loadRecentNotes();
      return;
    }
    setState(() => _isSearching = true);
    final results = await widget.folderLogic.dbService.searchNotes(query);
    setState(() => _searchResults = results);
  }

  Widget _buildEmptyEditor() {
    return Center(
      child: SingleChildScrollView(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.search, size: 80, color: Colors.white.withOpacity(0.1)),
            const SizedBox(height: 20),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Text(
                "Select a note from search results",
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.white.withOpacity(0.3),
                  fontSize: 16,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final primaryColor = Theme.of(context).colorScheme.primary;
    final bool isDesktop =
        Platform.isWindows || Platform.isLinux || Platform.isMacOS;

    // FIX: Removed the global padding wrapper so the scrollbar hits the wall!
    Widget listContent = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Top section with padding
        Padding(
          padding: const EdgeInsets.only(left: 16.0, right: 16.0, top: 16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextField(
                controller: _searchController,
                onChanged: _performSearch,
                decoration: InputDecoration(
                  filled: true,
                  prefixIcon: const Icon(Icons.search, color: Colors.grey),
                  suffixIcon: _searchController.text.isNotEmpty
                      ? IconButton(
                          icon: const Icon(Icons.clear, color: Colors.grey),
                          onPressed: () {
                            _searchController.clear();
                            _performSearch('');
                          },
                        )
                      : null,
                  hintText: "Search titles or content...",
                  hintStyle: const TextStyle(color: Colors.grey),
                ),
              ),
              const SizedBox(height: 20),
              Text(
                _isSearching ? "Search Results" : "Recent Notes",
                style: const TextStyle(
                  color: Colors.grey,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.2,
                ),
              ),
              const SizedBox(height: 10),
            ],
          ),
        ),

        // List section with internal padding
        Expanded(
          child: _searchResults.isEmpty
              ? Center(
                  child: Text(
                    "No matches found.",
                    style: TextStyle(color: Colors.white.withOpacity(0.5)),
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16.0,
                  ), // Padding is inside the list now
                  itemCount: _searchResults.length,
                  itemBuilder: (context, index) {
                    final note = _searchResults[index];
                    final bool isSelected =
                        isDesktop && _selectedNote?.filePath == note.filePath;

                    return Card(
                      color: isSelected
                          ? primaryColor.withOpacity(0.15)
                          : Theme.of(context).colorScheme.surface,
                      elevation: 0,
                      margin: const EdgeInsets.only(bottom: 8),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                        side: isSelected
                            ? BorderSide(color: primaryColor, width: 1)
                            : BorderSide.none,
                      ),
                      child: ListTile(
                        title: Text(
                          note.title,
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        subtitle: Text(
                          note.content,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(color: Colors.grey),
                        ),
                        onTap: () {
                          if (isDesktop) {
                            setState(() => _selectedNote = note);
                          } else {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => NoteEditorPage(
                                  folderLogic: widget.folderLogic,
                                  note: note,
                                ),
                              ),
                            );
                          }
                        },
                      ),
                    );
                  },
                ),
        ),
      ],
    );

    if (!isDesktop) {
      return Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          title: Text(
            "ARCHIVE",
            style: TextStyle(color: primaryColor, fontWeight: FontWeight.bold),
          ),
        ),
        body: listContent,
      );
    } else {
      return Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          title: Text(
            "ARCHIVE",
            style: TextStyle(color: primaryColor, fontWeight: FontWeight.bold),
          ),
        ),
        body: ResizableSplitView(
          leftChild: listContent,
          rightChild: _selectedNote != null
              ? NoteEditorPage(
                  key: ValueKey(_selectedNote!.filePath),
                  folderLogic: widget.folderLogic,
                  note: _selectedNote,
                  isEmbedded: true,
                  onClosed: () => setState(() => _selectedNote = null),
                )
              : _buildEmptyEditor(),
        ),
      );
    }
  }
}
