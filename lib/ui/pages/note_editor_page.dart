import 'package:flutter/material.dart';
import '../../logic/folder_logic.dart';
import '../../data/models/note.dart';

class NoteEditorPage extends StatefulWidget {
  final FolderLogic folderLogic;
  final Note? note;

  final bool isEmbedded;
  final VoidCallback? onClosed;
  final String? initialContent;

  const NoteEditorPage({
    super.key,
    required this.folderLogic,
    this.note,
    this.isEmbedded = false,
    this.onClosed,
    this.initialContent,
  });

  @override
  State<NoteEditorPage> createState() => _NoteEditorPageState();
}

class _NoteEditorPageState extends State<NoteEditorPage> {
  late TextEditingController _titleController;
  late TextEditingController _contentController;
  late String _currentFilePath;

  // NEW: Memory variables to prevent the background sync from erasing your typing!
  late String _lastKnownDbTitle;
  late String _lastKnownDbContent;

  bool _isSaved = false;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.note?.title ?? "");
    _contentController = TextEditingController(
      text: widget.note?.content ?? widget.initialContent ?? "",
    );
    _currentFilePath = widget.note?.filePath ?? "";

    // Initialize our memory
    _lastKnownDbTitle = widget.note?.title ?? "";
    _lastKnownDbContent = widget.note?.content ?? "";
    _lastKnownDbContent = _contentController.text;

    widget.folderLogic.addListener(_onFolderLogicUpdated);
  }

  @override
  void dispose() {
    _saveNoteSilently();
    widget.folderLogic.removeListener(_onFolderLogicUpdated);
    _titleController.dispose();
    _contentController.dispose();
    super.dispose();
  }

  Future<void> _confirmDelete() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1E1E1E),
        title: const Text("Delete Note", style: TextStyle(color: Colors.white)),
        content: const Text(
          "Are you sure you want to delete this file from your folder? This cannot be undone.",
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text("Cancel", style: TextStyle(color: Colors.grey)),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text(
              "Delete",
              style: TextStyle(color: Colors.redAccent),
            ),
          ),
        ],
      ),
    );

    if (confirm == true && widget.note != null) {
      // 1. Prevent dispose() from saving the note again
      _isSaved = true;

      // 2. Delete the file
      await widget.folderLogic.deleteNoteFile(widget.note!);

      // 3. Close the editor
      if (!widget.isEmbedded && mounted) Navigator.pop(context);
      if (widget.isEmbedded && widget.onClosed != null) widget.onClosed!();
    }
  }

  void _onFolderLogicUpdated() {
    if (_currentFilePath.isEmpty) return;

    if (widget.folderLogic.lastMovedFromPath == _currentFilePath) {
      _currentFilePath = widget.folderLogic.lastMovedToPath!;
      if (widget.note != null) {
        widget.note!.filePath = _currentFilePath;
      }
    }

    try {
      final liveNote = widget.folderLogic.allNotes.firstWhere(
        (n) => n.filePath == _currentFilePath,
      );

      // ONLY overwrite if the DB version is different from what we last saw AND different from what we are typing.
      // This means another app (like Syncthing or VS Code) changed the file!
      if (liveNote.title != _lastKnownDbTitle &&
          liveNote.title != _titleController.text) {
        _titleController.text = liveNote.title;
        _lastKnownDbTitle = liveNote.title; // Update memory
      }

      if (liveNote.content != _lastKnownDbContent &&
          liveNote.content != _contentController.text) {
        final cursorPosition = _contentController.selection;
        _contentController.text = liveNote.content;
        _lastKnownDbContent = liveNote.content; // Update memory

        // Restore cursor safely
        if (cursorPosition.baseOffset >= 0 &&
            cursorPosition.baseOffset <= liveNote.content.length) {
          _contentController.selection = cursorPosition;
        } else {
          _contentController.selection = TextSelection.collapsed(
            offset: liveNote.content.length,
          );
        }
      }
    } catch (e) {
      // The note is either brand new (not in DB yet) or was deleted externally. We safely ignore.
    }
  }

  void _saveNoteSilently() {
    if (_isSaved) return;
    _isSaved = true;

    final title = _titleController.text;
    final content = _contentController.text;

    if (title.isEmpty && content.isEmpty) return;

    if (widget.note == null) {
      widget.folderLogic.createAndSaveNote(title, content);
    } else {
      if (title != widget.note!.title || content != widget.note!.content) {
        widget.folderLogic.updateNote(widget.note!, title, content);
      }
    }
  }

  void _saveNote() {
    _saveNoteSilently();
    if (!widget.isEmbedded && mounted) Navigator.pop(context);
    if (widget.isEmbedded && widget.onClosed != null) widget.onClosed!();
  }

  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final primaryColor = theme.colorScheme.primary;

    return Scaffold(
      backgroundColor: widget.isEmbedded
          ? Colors.transparent
          : theme.scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(
            widget.isEmbedded ? Icons.close : Icons.arrow_back,
            color: primaryColor,
          ),
          onPressed: _saveNote,
        ),
        actions: [
          // ONLY show delete button if the note already exists on disk
          if (widget.note != null)
            IconButton(
              icon: const Icon(Icons.delete_outline, color: Colors.redAccent),
              tooltip: "Delete Note",
              onPressed: _confirmDelete,
            ),
          IconButton(
            icon: Icon(Icons.check, color: primaryColor),
            onPressed: _saveNote,
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            TextField(
              controller: _titleController,
              style: theme.textTheme.headlineMedium?.copyWith(
                color: Colors.white,
              ),
              decoration: const InputDecoration(
                hintText: "Note Title",
                hintStyle: TextStyle(color: Colors.grey),
                border: InputBorder.none,
                filled: false,
              ),
            ),
            const Divider(color: Colors.white10),
            Expanded(
              child: TextField(
                controller: _contentController,
                maxLines: null,
                style: theme.textTheme.bodyLarge?.copyWith(
                  color: Colors.white70,
                ),
                decoration: const InputDecoration(
                  hintText: "Start typing...",
                  hintStyle: TextStyle(color: Colors.grey),
                  border: InputBorder.none,
                  filled: false,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
