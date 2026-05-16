import 'dart:io';
import 'package:flutter/material.dart';
import '../../logic/folder_logic.dart';
import '../../data/models/note.dart';
import '../styling/resizable_split_view.dart';
import 'note_editor_page.dart';

class HomePage extends StatefulWidget {
  final FolderLogic folderLogic;

  const HomePage({super.key, required this.folderLogic});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  Note? _selectedNote;
  bool _isCreatingNew = false;

  Widget _buildEmptyEditor() {
    return Center(
      // 1. SingleChildScrollView prevents the Bottom Overflow crash
      child: SingleChildScrollView(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.edit_document,
              size: 80,
              color: Colors.white.withOpacity(0.1),
            ),
            const SizedBox(height: 20),
            // 2. Padding prevents text from hitting the absolute edges
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Text(
                "Select a note or create a new one",
                textAlign:
                    TextAlign.center, // 3. Centers it neatly when squeezed
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

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(
          "FOLDER",
          style: TextStyle(
            color: primaryColor,
            fontWeight: FontWeight.bold,
            letterSpacing: 1.2,
          ),
        ),
        actions: [
          ListenableBuilder(
            listenable: widget.folderLogic,
            builder: (context, _) {
              if (widget.folderLogic.isSyncingBackground) {
                return Padding(
                  padding: const EdgeInsets.only(right: 20.0),
                  child: Center(
                    child: SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        color: primaryColor,
                        strokeWidth: 2,
                      ),
                    ),
                  ),
                );
              }
              return const SizedBox.shrink();
            },
          ),
        ],
      ),
      body: ListenableBuilder(
        listenable: widget.folderLogic,
        builder: (context, child) {
          if (widget.folderLogic.isLoading)
            return Center(
              child: CircularProgressIndicator(color: primaryColor),
            );
          if (widget.folderLogic.folderPath != null)
            return _buildActiveFolder(context, isDesktop);
          return _buildNoFolder(context);
        },
      ),
    );
  }

  Widget _buildNoFolder(BuildContext context) {
    final primaryColor = Theme.of(context).colorScheme.primary;
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.folder_off_outlined,
            size: 80,
            color: primaryColor.withOpacity(0.4),
          ),
          const SizedBox(height: 20),
          const Text(
            "No Active Folder",
            style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 30),
          OutlinedButton.icon(
            onPressed: widget.folderLogic.selectFolder,
            style: OutlinedButton.styleFrom(
              side: BorderSide(color: primaryColor, width: 2),
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            icon: Icon(Icons.folder_open, color: primaryColor),
            label: Text(
              "Select Local Folder",
              style: TextStyle(fontSize: 16, color: primaryColor),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActiveFolder(BuildContext context, bool isDesktop) {
    Widget listContent = Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
          child: SizedBox(
            width: double.infinity,
            // WRAP replaces ROW. It automatically prevents overflow by stacking if needed!
            child: Wrap(
              alignment: WrapAlignment.spaceBetween,
              crossAxisAlignment: WrapCrossAlignment.center,
              children: [
                DropdownButton<SortOption>(
                  value: widget.folderLogic.currentSort,
                  dropdownColor: Theme.of(context).colorScheme.surface,
                  underline: const SizedBox(),
                  icon: const Icon(Icons.sort, color: Colors.grey, size: 18),
                  style: const TextStyle(color: Colors.grey, fontSize: 14),
                  items: const [
                    DropdownMenuItem(
                      value: SortOption.dateDesc,
                      child: Text("Last Modified"),
                    ),
                    DropdownMenuItem(
                      value: SortOption.alphaAsc,
                      child: Text("A to Z"),
                    ),
                    DropdownMenuItem(
                      value: SortOption.alphaDesc,
                      child: Text("Z to A"),
                    ),
                  ],
                  onChanged: (val) {
                    if (val != null) widget.folderLogic.changeSortOption(val);
                  },
                ),
                DropdownButton<int>(
                  value: widget.folderLogic.displayLimit,
                  dropdownColor: Theme.of(context).colorScheme.surface,
                  underline: const SizedBox(),
                  style: const TextStyle(color: Colors.grey, fontSize: 14),
                  items: [25, 50, 100, 250, 500]
                      .map(
                        (int val) => DropdownMenuItem<int>(
                          value: val,
                          child: Text("Show $val"),
                        ),
                      )
                      .toList(),
                  onChanged: (val) {
                    if (val != null) widget.folderLogic.changeDisplayLimit(val);
                  },
                ),
              ],
            ),
          ),
        ),
        Expanded(
          child: widget.folderLogic.allNotes.isEmpty
              ? Center(
                  child: Text(
                    widget.folderLogic.isSyncingBackground
                        ? "Syncing files..."
                        : "Folder is empty. Create a note!",
                    style: const TextStyle(color: Colors.grey),
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: widget.folderLogic.allNotes.length,
                  itemBuilder: (context, index) {
                    final note = widget.folderLogic.allNotes[index];
                    final bool isSelected =
                        isDesktop &&
                        _selectedNote?.filePath == note.filePath &&
                        !_isCreatingNew;

                    return Card(
                      color: isSelected
                          ? Theme.of(
                              context,
                            ).colorScheme.primary.withOpacity(0.15)
                          : Theme.of(context).colorScheme.surface,
                      elevation: 0,
                      margin: const EdgeInsets.only(bottom: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                        side: isSelected
                            ? BorderSide(
                                color: Theme.of(context).colorScheme.primary,
                                width: 1,
                              )
                            : BorderSide.none,
                      ),
                      child: ListTile(
                        contentPadding: const EdgeInsets.all(16),
                        title: Text(
                          note.title.isEmpty ? "Untitled" : note.title,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        subtitle: Text(
                          note.content,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(color: Colors.grey),
                        ),
                        onTap: () {
                          if (isDesktop) {
                            setState(() {
                              _selectedNote = note;
                              _isCreatingNew = false;
                            });
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
        backgroundColor: Colors.transparent,
        body: listContent,
        floatingActionButton: FloatingActionButton(
          backgroundColor: Theme.of(context).colorScheme.primary,
          child: const Icon(Icons.edit, color: Colors.black),
          onPressed: () => Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) =>
                  NoteEditorPage(folderLogic: widget.folderLogic),
            ),
          ),
        ),
      );
    } else {
      return ResizableSplitView(
        leftChild: Scaffold(
          backgroundColor: Colors.transparent,
          body: listContent,
          floatingActionButton: FloatingActionButton(
            backgroundColor: Theme.of(context).colorScheme.primary,
            child: const Icon(Icons.edit, color: Colors.black),
            onPressed: () => setState(() {
              _selectedNote = null;
              _isCreatingNew = true;
            }),
          ),
        ),
        rightChild: (_selectedNote != null || _isCreatingNew)
            ? NoteEditorPage(
                key: ValueKey(_selectedNote?.filePath ?? "new_note_key"),
                folderLogic: widget.folderLogic,
                note: _selectedNote,
                isEmbedded: true,
                onClosed: () => setState(() {
                  _selectedNote = null;
                  _isCreatingNew = false;
                }),
              )
            : _buildEmptyEditor(),
      );
    }
  }
}
