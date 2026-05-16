import 'dart:io';
import 'package:flutter/material.dart';
import '../../logic/folder_logic.dart';
import '../../data/models/note.dart';
import '../styling/resizable_split_view.dart';
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
              child: SingleChildScrollView(
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
                        color: theme.colorScheme.onSurface,
                      ),
                    ),
                    const SizedBox(height: 10),
                    const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 16),
                      child: Text(
                        "Type #tagname# anywhere inside a note to automatically create a cluster.",
                        textAlign: TextAlign.center,
                        style: TextStyle(color: Colors.grey, fontSize: 16),
                      ),
                    ),
                  ],
                ),
              ),
            );
          }

          // GALLERY VIEW: Always full width, no split view here.
          return GridView.builder(
            padding: const EdgeInsets.all(16),
            gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
              maxCrossAxisExtent:
                  200, // Slightly larger for better A-Z readability
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
              childAspectRatio: 0.9, // Balanced ratio for Gallery view
            ),
            itemCount: clusters.length,
            itemBuilder: (context, index) {
              final tag = clusters.keys.elementAt(index);
              final notes = clusters[tag]!;
              final isDark = theme.brightness == Brightness.dark;

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
                    color: theme.colorScheme.surface,
                    borderRadius: BorderRadius.circular(24),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        width: 64,
                        height: 64,
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: isDark
                              ? const Color(0xFF2A2A2A)
                              : const Color(0xFFE5E5E5),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Wrap(
                          spacing: 4,
                          runSpacing: 4,
                          children: List.generate(
                            notes.length > 4 ? 4 : notes.length,
                            (i) => Container(
                              width: 20,
                              height: 20,
                              decoration: BoxDecoration(
                                color: primaryColor.withOpacity(0.8),
                                borderRadius: BorderRadius.circular(6),
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 8.0),
                        child: Text(
                          "#$tag#",
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            color: theme.colorScheme.onSurface,
                            fontWeight: FontWeight.bold,
                            fontSize: 15,
                          ),
                        ),
                      ),
                      const SizedBox(height: 2),
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
}

// ---- SUB PAGE: Opens when a cluster is clicked ---- //
class _ClusterNotesPage extends StatefulWidget {
  final String tag;
  final FolderLogic folderLogic;

  const _ClusterNotesPage({
    super.key,
    required this.tag,
    required this.folderLogic,
  });

  @override
  State<_ClusterNotesPage> createState() => _ClusterNotesPageState();
}

class _ClusterNotesPageState extends State<_ClusterNotesPage> {
  Note? _selectedNote;

  Widget _buildEmptyEditor() {
    return Center(
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
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.0),
              child: Text(
                "Select a note to view",
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.grey, fontSize: 16),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final primaryColor = theme.colorScheme.primary;
    final bool isDesktop =
        Platform.isWindows || Platform.isLinux || Platform.isMacOS;

    final appBar = AppBar(
      backgroundColor: Colors.transparent,
      elevation: 0,
      iconTheme: IconThemeData(color: primaryColor),
      title: Text(
        "#${widget.tag}#",
        style: TextStyle(color: primaryColor, fontWeight: FontWeight.bold),
      ),
    );

    Widget listContent = ListenableBuilder(
      listenable: widget.folderLogic,
      builder: (context, _) {
        final notes = widget.folderLogic.clusteredNotes[widget.tag] ?? [];

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
            final bool isSelected =
                isDesktop && _selectedNote?.filePath == note.filePath;

            return Card(
              color: isSelected
                  ? primaryColor.withOpacity(0.15)
                  : theme.colorScheme.surface,
              elevation: 0,
              margin: const EdgeInsets.only(bottom: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
                side: isSelected
                    ? BorderSide(color: primaryColor, width: 1)
                    : BorderSide.none,
              ),
              child: ListTile(
                contentPadding: const EdgeInsets.all(16),
                title: Text(
                  note.title.isEmpty ? "Untitled" : note.title,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: theme.colorScheme.onSurface,
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
        );
      },
    );

    if (!isDesktop) {
      return Scaffold(appBar: appBar, body: listContent);
    } else {
      // Internal split view still active for Desktop note browsing
      return Scaffold(
        appBar: appBar,
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
