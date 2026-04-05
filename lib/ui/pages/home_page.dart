import 'package:flutter/material.dart';

import '../../logic/folder_logic.dart';
import 'note_editor_page.dart';

class HomePage extends StatelessWidget {
  final FolderLogic folderLogic;

  // Now accepts folderLogic from the LayoutManager
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
      ),
      body: ListenableBuilder(
        listenable: folderLogic,
        builder: (context, child) {
          if (folderLogic.isLoading) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(color: primaryColor),
                  const SizedBox(height: 16),
                  Text(
                    folderLogic.loadingStatus,
                    style: const TextStyle(color: Colors.grey),
                  ),
                ],
              ),
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
      body: folderLogic.allNotes.isEmpty
          ? const Center(
              child: Text(
                "Folder is empty. Create a note!",
                style: TextStyle(color: Colors.grey),
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(16),
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
