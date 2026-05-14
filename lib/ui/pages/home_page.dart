import 'package:flutter/material.dart';
import '../../logic/folder_logic.dart';
import 'note_editor_page.dart';

class HomePage extends StatelessWidget {
  final FolderLogic folderLogic;

  const HomePage({super.key, required this.folderLogic});

  @override
  Widget build(BuildContext context) {
    final primaryColor = Theme.of(context).colorScheme.primary;

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
          // Shows a tiny loading spinner in the corner while background sync happens
          ListenableBuilder(
            listenable: folderLogic,
            builder: (context, _) {
              if (folderLogic.isSyncingBackground) {
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
        listenable: folderLogic,
        builder: (context, child) {
          if (folderLogic.isLoading) {
            return Center(
              child: CircularProgressIndicator(color: primaryColor),
            );
          }

          if (folderLogic.folderPath != null) {
            return _buildActiveFolder(context);
          } else {
            return _buildNoFolder(context);
          }
        },
      ),
    );
  }

  // ... _buildNoFolder remains exactly the same ...
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
          const SizedBox(height: 10),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 40),
            child: Text(
              "Select a folder on your device to serve as your digital archive. Your notes will be stored safely here.",
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey, fontSize: 16),
            ),
          ),
          const SizedBox(height: 30),
          OutlinedButton.icon(
            onPressed: folderLogic.selectFolder,
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

  Widget _buildActiveFolder(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Column(
        children: [
          // --- NEW: Filters Toolbar ---
          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 16.0,
              vertical: 8.0,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Sort Dropdown
                DropdownButton<SortOption>(
                  value: folderLogic.currentSort,
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
                    if (val != null) folderLogic.changeSortOption(val);
                  },
                ),
                // Limit Dropdown
                DropdownButton<int>(
                  value: folderLogic.displayLimit,
                  dropdownColor: Theme.of(context).colorScheme.surface,
                  underline: const SizedBox(),
                  style: const TextStyle(color: Colors.grey, fontSize: 14),
                  items: [25, 50, 100, 250, 500].map((int val) {
                    return DropdownMenuItem<int>(
                      value: val,
                      child: Text("Show $val"),
                    );
                  }).toList(),
                  onChanged: (val) {
                    if (val != null) folderLogic.changeDisplayLimit(val);
                  },
                ),
              ],
            ),
          ),
          // --- Notes List ---
          Expanded(
            child: folderLogic.allNotes.isEmpty
                ? const Center(
                    child: Text(
                      "Folder is empty. Create a note!",
                      style: TextStyle(color: Colors.grey),
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: folderLogic.allNotes.length,
                    itemBuilder: (context, index) {
                      final note = folderLogic.allNotes[index];
                      return Card(
                        color: Theme.of(context).colorScheme.surface,
                        elevation: 0,
                        margin: const EdgeInsets.only(bottom: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
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
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => NoteEditorPage(
                                  folderLogic: folderLogic,
                                  note: note,
                                ),
                              ),
                            );
                          },
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Theme.of(context).colorScheme.primary,
        child: const Icon(Icons.edit, color: Colors.black),
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => NoteEditorPage(folderLogic: folderLogic),
            ),
          );
        },
      ),
    );
  }
}
