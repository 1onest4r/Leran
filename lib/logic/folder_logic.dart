import 'dart:io';
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../data/database/database_service.dart';
import '../data/models/note.dart';

enum SortOption { dateDesc, alphaAsc, alphaDesc }

class FolderLogic extends ChangeNotifier {
  String? folderPath;

  bool isLoading = true;
  bool isSyncingBackground = false;

  SortOption currentSort = SortOption.dateDesc;
  int displayLimit = 50;

  final DatabaseService dbService = DatabaseService();
  List<Note> allNotes = [];

  StreamSubscription<FileSystemEvent>? _directoryWatcher;
  final Map<String, Timer> _debounceTimers = {};

  String? lastMovedFromPath;
  String? lastMovedToPath;

  //when class is created automatically check for saved folder
  FolderLogic() {
    loadSavedFolder();
  }

  @override
  void dispose() {
    _stopWatchingDirectory();
    super.dispose();
  }

  void changeSortOption(SortOption option) {
    currentSort = option;
    refreshNotesList();
  }

  void changeDisplayLimit(int limit) {
    displayLimit = limit;
    refreshNotesList();
  }

  //if the user had already picked folder in the past
  Future<void> loadSavedFolder() async {
    final prefs = await SharedPreferences.getInstance();
    folderPath = prefs.getString('folder_path');

    //ensure the db is fully open before we let the ui load
    await dbService.db;

    if (folderPath != null) {
      await refreshNotesList();
      _startWatchingDirectory(folderPath!);

      _syncFolderMassive(folderPath!);
    }

    isLoading = false;

    //tells ui to rebuild, col
    notifyListeners();
  }

  Future<void> refreshNotesList() async {
    //translate the enum into SQL commands
    String orderBy = 'updateAt DESC';
    if (currentSort == SortOption.alphaAsc) orderBy = 'title ASC';
    if (currentSort == SortOption.alphaDesc) orderBy = 'title DESC';

    allNotes = await dbService.getAllNotes(
      limit: displayLimit,
      orderBy: orderBy,
    );
    notifyListeners();
  }

  //picking the folder for use
  Future<void> selectFolder() async {
    String? selectedDirectory = await FilePicker.platform.getDirectoryPath(
      dialogTitle: "Select your desired folder",
    );

    if (selectedDirectory != null) {
      isLoading = true;
      notifyListeners();

      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('folder_path', selectedDirectory);
      folderPath = selectedDirectory;

      await dbService.clearAllNotes(); //clear old notes
      await refreshNotesList(); //load empty list

      isLoading = false;
      notifyListeners();

      _startWatchingDirectory(selectedDirectory);
      //tells the ui th folder is picked
      _syncFolderMassive(selectedDirectory);
    }
  }

  Future<void> _syncFolderMassive(String path) async {
    if (isSyncingBackground) return; // Prevent double-syncs

    isSyncingBackground = true;
    notifyListeners();

    try {
      final directory = Directory(path);
      final entities = await directory.list(recursive: true).toList();
      final mdFiles = entities
          .whereType<File>()
          .where((f) => f.path.endsWith('.md'))
          .toList();

      final int batchSize = 50; // Small batch size!
      for (int i = 0; i < mdFiles.length; i += batchSize) {
        final end = (i + batchSize < mdFiles.length)
            ? i + batchSize
            : mdFiles.length;
        final batch = mdFiles.sublist(i, end);
        List<Note> notesBatch = [];

        for (var file in batch) {
          final stat = await file.stat();
          final content = await file.readAsString();
          final title = file.uri.pathSegments.last.replaceAll('.md', '');

          notesBatch.add(
            Note()
              ..title = title
              ..content = content
              ..filePath = file.path
              ..updateAt = stat.modified,
          );
        }

        await dbService.saveNotesBatch(notesBatch);
        await refreshNotesList(); // Update UI gently

        // CRITICAL MAGIC: This yields to the Flutter engine so it can draw frames
        // and keep the app at 60fps without crashing!
        await Future.delayed(const Duration(milliseconds: 100));
      }
    } catch (e) {
      print("Background mass sync error: $e");
    }

    isSyncingBackground = false;
    notifyListeners();
  }

  //diconnect the active folder
  Future<void> disconnectFolder() async {
    _stopWatchingDirectory();

    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('folder_path');
    folderPath = null;
    await dbService.clearAllNotes();
    allNotes.clear();
    notifyListeners();
  }

  Future<void> createAndSaveNote(String title, String content) async {
    if (folderPath == null) {
      return;
    }

    //create safe file name
    String safeTitle = title
        .replaceAll(' ', '_')
        .replaceAll(RegExp(r'[\\/:*?"<>|]'), '');
    if (safeTitle.isEmpty) {
      safeTitle = "Untitled";
    }

    String fullPath = "$folderPath/$safeTitle.md";
    File file = File(fullPath);

    //write raw md file into hard drive
    await file.writeAsString(content);
  }

  Future<void> updateNote(Note note, String newTitle, String newContent) async {
    try {
      final oldFile = File(note.filePath);

      //prepare the new file path properly
      String safeTitle = newTitle
          .replaceAll(' ', '_')
          .replaceAll(RegExp(r'[\\/:*?"<>|]'), '');
      if (safeTitle.isEmpty) {
        safeTitle = "Untitled";
      }
      String newPath = "$folderPath/$safeTitle.md";

      if (note.filePath != newPath) {
        if (await oldFile.exists()) {
          await oldFile.delete();
        }
      }

      final newFile = File(newPath);
      await newFile.writeAsString(newContent);
    } catch (e) {
      print("Error updating note: $e");
    }
  }

  void _startWatchingDirectory(String path) {
    _stopWatchingDirectory(); //to ensure no duplication

    final directory = Directory(path);
    if (!directory.existsSync()) {
      return;
    }

    _directoryWatcher = directory.watch(recursive: true).listen((event) {
      _handleFileSystemEvent(event);
    });
  }

  void _stopWatchingDirectory() {
    _directoryWatcher?.cancel();
    _directoryWatcher = null;

    for (var timer in _debounceTimers.values) {
      timer.cancel();
    }

    _debounceTimers.clear();
  }

  void _handleFileSystemEvent(FileSystemEvent event) {
    // 1. Move/Rename Event
    if (event is FileSystemMoveEvent) {
      if (event.destination != null && event.destination!.endsWith(".md")) {
        // Explicitly handle renaming!
        _debounceAction(
          event.destination!,
          () => _processFileMove(event.path, event.destination!),
        );
      } else {
        _debounceAction(event.path, () => _processFileDelete(event.path));
      }
    }
    // 2. Delete Event
    else if (event is FileSystemDeleteEvent) {
      if (event.path.endsWith('.md')) {
        _debounceAction(event.path, () => _processFileDelete(event.path));
      }
    }
    // 3. Create or Modify Event
    else if (event is FileSystemCreateEvent || event is FileSystemModifyEvent) {
      if (event.path.endsWith('.md')) {
        _debounceAction(event.path, () => _processFileChange(event.path));
      }
    }
  }

  Future<void> _processFileMove(String rawOldPath, String rawNewPath) async {
    try {
      final oldPath = File(rawOldPath).absolute.path;
      final newPath = File(rawNewPath).absolute.path;

      // Set trackers so the UI can follow the file
      lastMovedFromPath = oldPath;
      lastMovedToPath = newPath;

      final existingNote = await dbService.getNoteByPath(oldPath);
      final file = File(newPath);

      if (!await file.exists()) return;

      final stat = await file.stat();
      final content = await file.readAsString();
      final title = file.uri.pathSegments.last.replaceAll('.md', '');

      final note = existingNote ?? Note();
      note.title = title;
      note.content = content;
      note.filePath = newPath;
      note.updateAt = stat.modified;

      await dbService.saveNoteIndex(note);

      // Safety cleanup in case existingNote was null
      if (existingNote == null) {
        await dbService.deleteNoteByPath(oldPath);
      }

      await refreshNotesList();

      // Clear trackers after UI reacts to prevent memory bugs
      Future.delayed(const Duration(milliseconds: 500), () {
        if (lastMovedFromPath == oldPath) lastMovedFromPath = null;
        if (lastMovedToPath == newPath) lastMovedToPath = null;
      });
    } catch (e) {
      print("File move error: $e");
    }
  }

  //debounce logic to prevent processing identical file events multiple times
  void _debounceAction(String path, Future<void> Function() action) {
    _debounceTimers[path]?.cancel();
    _debounceTimers[path] = Timer(const Duration(milliseconds: 500), () async {
      _debounceTimers.remove(path);
      await action();
    });
  }

  Future<void> _processFileChange(String rawpath) async {
    try {
      final file = File(rawpath);
      if (!await file.exists()) {
        return;
      }

      final path = file.absolute.path;

      final stat = await file.stat();
      final content = await file.readAsString();
      final title = file.uri.pathSegments.last.replaceAll('.md', '');

      //check if note already exists in isar to prevent duplications
      final existingNote = await dbService.getNoteByPath(path);

      //either update the existing note or create a new one
      final note = existingNote ?? Note();
      note.title = title;
      note.content = content;
      note.filePath = path;
      note.updateAt = stat.modified;

      await dbService.saveNoteIndex(note);

      //update the ui
      await refreshNotesList();
    } catch (e) {
      print("File change error: $e");
    }
  }

  Future<void> _processFileDelete(String rawpath) async {
    try {
      final path = File(rawpath).absolute.path;

      await dbService.deleteNoteByPath(path);
      await refreshNotesList();
    } catch (e) {
      print("File delete error: $e");
    }
  }

  // NEW: Groups all loaded notes by their tags.
  // Returns a Map where the Key is the tag name, and the Value is a List of Notes.
  Map<String, List<Note>> get clusteredNotes {
    final Map<String, List<Note>> clusters = {};

    for (var note in allNotes) {
      for (var tag in note.tags) {
        if (!clusters.containsKey(tag)) {
          clusters[tag] = [];
        }
        clusters[tag]!.add(note);
      }
    }

    return clusters;
  }
}
