import 'package:flutter/material.dart';
import '../../logic/folder_logic.dart';
import '../../data/models/note.dart';
import 'note_editor_page.dart';

class ClusterPage extends StatelessWidget {
  final FolderLogic folderLogic;

  const ClusterPage({super.key, required this.folderLogic});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final primaryColor = theme.colorScheme.primary;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(
          "CLUSTERS",
          style: TextStyle(
            color: primaryColor,
            fontWeight: FontWeight.bold,
            letterSpacing: 1.2,
          ),
        ),
      ),
      body: ListenableBuilder(
        listenable: folderLogic,
        builder: (context, _) {
          final clusters = folderLogic.clusteredNotes;

          if (clusters.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.bubble_chart_outlined,
                    size: 80,
                    color: primaryColor.withOpacity(0.4),
                  ),
                  const SizedBox(height: 20),
                  Text(
                    "No Tags Found",
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color:
                          theme.colorScheme.onSurface, // Fix: adapts to theme
                    ),
                  ),
                  const SizedBox(height: 10),
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 40),
                    child: Text(
                      "Type #tagname# anywhere inside a note to automatically create a cluster.",
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Colors.grey, fontSize: 16),
                    ),
                  ),
                ],
              ),
            );
          }

          return GridView.builder(
            padding: const EdgeInsets.all(16),
            gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
              maxCrossAxisExtent: 180, // Responsive sizing for mobile/desktop
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
              childAspectRatio: 1, // Keeps the islands perfectly square
            ),
            itemCount: clusters.length,
            itemBuilder: (context, index) {
              final tag = clusters.keys.elementAt(index);
              final notes = clusters[tag]!;

              return GestureDetector(
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) =>
                        _ClusterNotesPage(tag: tag, folderLogic: folderLogic),
                  ),
                ),
                child: Container(
                  decoration: BoxDecoration(
                    color: theme
                        .colorScheme
                        .surface, // Uses proper dark/light theme
                    borderRadius: BorderRadius.circular(24),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // The little "App Folder" icon preview
                      _buildAppFolderIcon(notes, theme),
                      const SizedBox(height: 16),
                      Text(
                        "#$tag#",
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: theme
                              .colorScheme
                              .onSurface, // Fix: adapts to theme
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        "${notes.length} note${notes.length > 1 ? 's' : ''}",
                        style: const TextStyle(
                          color: Colors.grey,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }

  // Creates a beautiful little 2x2 grid representing the notes inside the cluster
  Widget _buildAppFolderIcon(List<Note> notes, ThemeData theme) {
    // Check if we are in dark mode to change the background of the mini-folder
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      width: 64,
      height: 64,
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: isDark
            ? const Color(0xFF2A2A2A)
            : const Color(0xFFE5E5E5), // Fix: soft grey in light mode
        borderRadius: BorderRadius.circular(16),
      ),
      child: Wrap(
        spacing: 4,
        runSpacing: 4,
        children: List.generate(
          notes.length > 4 ? 4 : notes.length, // Max 4 tiny squares
          (i) => Container(
            width: 20,
            height: 20,
            decoration: BoxDecoration(
              color: theme.colorScheme.primary.withOpacity(0.8),
              borderRadius: BorderRadius.circular(6),
            ),
          ),
        ),
      ),
    );
  }
}

// ---- SUB PAGE: Opens when a cluster is clicked ---- //
class _ClusterNotesPage extends StatelessWidget {
  final String tag;
  final FolderLogic folderLogic;

  const _ClusterNotesPage({required this.tag, required this.folderLogic});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final primaryColor = theme.colorScheme.primary;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: IconThemeData(color: primaryColor),
        title: Text(
          "#$tag#",
          style: TextStyle(color: primaryColor, fontWeight: FontWeight.bold),
        ),
      ),
      // We use ListenableBuilder so that if you edit a note and remove the tag,
      // it instantly disappears from this list when you hit the back button.
      body: ListenableBuilder(
        listenable: folderLogic,
        builder: (context, _) {
          final notes = folderLogic.clusteredNotes[tag] ?? [];

          if (notes.isEmpty) {
            return const Center(
              child: Text(
                "No notes left in this cluster.",
                style: TextStyle(color: Colors.grey),
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: notes.length,
            itemBuilder: (context, index) {
              final note = notes[index];
              return Card(
                color: theme.colorScheme.surface,
                elevation: 0,
                margin: const EdgeInsets.only(bottom: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: ListTile(
                  contentPadding: const EdgeInsets.all(16),
                  title: Text(
                    note.title.isEmpty ? "Untitled" : note.title,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color:
                          theme.colorScheme.onSurface, // Fix: adapts to theme
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
          );
        },
      ),
    );
  }
}
