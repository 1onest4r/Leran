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
    _loadInitialData();
    // 1. LISTEN for changes in the folder (deletes, syncs, updates)
    widget.folderLogic.addListener(_onLogicUpdated);
  }

  @override
  void dispose() {
    // 2. REMOVE listener to prevent memory leaks
    widget.folderLogic.removeListener(_onLogicUpdated);
    _searchController.dispose();
    super.dispose();
  }

  // 3. Whenever FolderLogic changes, re-run the search/recent fetch
  void _onLogicUpdated() {
    if (mounted) {
      _performSearch(_searchController.text);
    }
  }

  Future<void> _loadInitialData() async {
    await _loadRecentNotes();
  }

  Future<void> _loadRecentNotes() async {
    final recent = await widget.folderLogic.dbService.getRecentNotes();
    if (mounted) {
      setState(() {
        _searchResults = recent;
        // Check if our selected note was deleted during a sync/delete action
        if (_selectedNote != null) {
          bool stillExists = widget.folderLogic.allNotes.any(
            (n) => n.filePath == _selectedNote!.filePath,
          );
          if (!stillExists) _selectedNote = null;
        }
      });
    }
  }

  Future<void> _performSearch(String query) async {
    if (query.trim().isEmpty) {
      if (mounted) setState(() => _isSearching = false);
      _loadRecentNotes();
      return;
    }

    final results = await widget.folderLogic.dbService.searchNotes(query);
    if (mounted) {
      setState(() {
        _isSearching = true;
        _searchResults = results;
      });
    }
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

    Widget listContent = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 16.0, right: 16.0, top: 16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextField(
                controller: _searchController,
                onChanged: _performSearch,
                style: const TextStyle(color: Colors.white),
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
                _isSearching ? "SEARCH RESULTS" : "RECENT NOTES",
                style: const TextStyle(
                  color: Colors.grey,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.2,
                  fontSize: 12,
                ),
              ),
              const SizedBox(height: 10),
            ],
          ),
        ),
        Expanded(
          child: _searchResults.isEmpty
              ? Center(
                  child: Text(
                    "No matches found.",
                    style: TextStyle(color: Colors.white.withOpacity(0.5)),
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
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
                          note.title.isEmpty ? "Untitled" : note.title,
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        subtitle: Text(
                          note.content.replaceAll('\n', ' '),
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

    final appBar = AppBar(
      backgroundColor: Colors.transparent,
      elevation: 0,
      title: Text(
        "ARCHIVE",
        style: TextStyle(
          color: primaryColor,
          fontWeight: FontWeight.bold,
          letterSpacing: 1.2,
        ),
      ),
    );

    if (!isDesktop) {
      return Scaffold(appBar: appBar, body: listContent);
    } else {
      return Scaffold(
        appBar: appBar,
        body: ResizableSplitView(
          leftChild: listContent,
          rightChild: _selectedNote != null
              ? NoteEditorPage(
                  // Use filePath as key so the editor refreshes if you click a different result
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
