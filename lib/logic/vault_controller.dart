import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import '../services/file_service.dart';
import '../services/settings_service.dart';

/// LOGIC LAYER: The Central Brain of the App.
/// This class manages all tabs, active files, directories, and saving logic.
/// UI components just listen to this class to know what to draw.
class VaultController extends ChangeNotifier {
  // --- SINGLETON SETUP ---
  // This ensures there is only ever ONE VaultController active in the app.
  static final VaultController _instance = VaultController._internal();
  factory VaultController() => _instance;
  VaultController._internal();

  // --- APP STATE DATA ---
  String? selectedDirectory;
  List<FileSystemEntity> files = [];
  List<FileSystemEntity> openedTabs = [];
  FileSystemEntity? activeFile;

  String fileContent = "";
  final Set<String> unsavedPaths = {};

  StreamSubscription<FileSystemEvent>? _dirWatcher;

  @override
  void dispose() {
    _dirWatcher?.cancel();
    super.dispose();
  }

  // --------------------------------------------------------------------------
  // VAULT & DIRECTORY LOGIC
  // --------------------------------------------------------------------------

  void setVaultDirectory(String path) {
    selectedDirectory = path;
    refreshFileList();
    _startWatching(path);
    notifyListeners(); // Tells the UI to redraw (HomePage will now show the sidebars)
  }

  Future<void> refreshFileList() async {
    if (selectedDirectory == null) return;
    if (!await Directory(selectedDirectory!).exists()) return;

    files = await FileService.getNotesFromPath(selectedDirectory!);
    notifyListeners();
  }

  void _startWatching(String path) {
    _dirWatcher?.cancel();
    _dirWatcher = Directory(path).watch().listen((event) {
      refreshFileList();
    });
  }

  Future<void> renameVault(String newName) async {
    if (selectedDirectory == null) return;
    try {
      final dir = Directory(selectedDirectory!);
      final parentPath = dir.parent.path;
      final newPath = '$parentPath${Platform.pathSeparator}$newName';

      if (await Directory(newPath).exists()) return;

      final newDir = await dir.rename(newPath);
      selectedDirectory = newDir.path;
      await refreshFileList();

      // Update paths of all opened tabs so they don't break
      openedTabs = openedTabs.map((f) {
        final fileName = f.uri.pathSegments.lastWhere((s) => s.isNotEmpty);
        return File('${newDir.path}${Platform.pathSeparator}$fileName');
      }).toList();

      if (activeFile != null) {
        final fileName = activeFile!.uri.pathSegments.lastWhere(
          (s) => s.isNotEmpty,
        );
        activeFile = File('${newDir.path}${Platform.pathSeparator}$fileName');
      }

      // Update unsaved paths cache
      final newUnsaved = <String>{};
      for (final p in unsavedPaths) {
        final fileName = p.split(Platform.pathSeparator).last;
        newUnsaved.add('${newDir.path}${Platform.pathSeparator}$fileName');
      }
      unsavedPaths.clear();
      unsavedPaths.addAll(newUnsaved);

      _startWatching(newDir.path);
      notifyListeners();
    } catch (e) {
      debugPrint("Folder rename failed: $e");
    }
  }

  // --------------------------------------------------------------------------
  // TAB & FILE LOGIC
  // --------------------------------------------------------------------------

  Future<void> openFile(FileSystemEntity file) async {
    // If navigating away from an unsaved file, save it first
    if (activeFile != null && unsavedPaths.contains(activeFile!.path)) {
      await saveFileToDisk(activeFile!.path, fileContent);
    }

    // Read new file
    final content = await FileService.readFile(file);
    activeFile = file;
    fileContent = content;

    // Add to tabs if not already open
    if (!openedTabs.any((f) => f.path == file.path)) {
      openedTabs.add(file);
    }

    notifyListeners();
  }

  void closeTab(FileSystemEntity file) {
    openedTabs.removeWhere((f) => f.path == file.path);

    // If we closed the active tab, switch to the last open tab
    if (activeFile?.path == file.path) {
      if (openedTabs.isNotEmpty) {
        openFile(openedTabs.last);
      } else {
        activeFile = null;
        fileContent = "";
      }
    } else {
      notifyListeners();
    }
  }

  Future<void> createNewNote(String fileName) async {
    if (selectedDirectory == null) return;
    await FileService.createNote(selectedDirectory!, fileName);
    await refreshFileList();
    // Auto-open the newly created file
    final newFile = files.firstWhere((f) => f.path.contains(fileName));
    openFile(newFile);
  }

  Future<void> deleteActiveNote() async {
    if (activeFile == null) return;
    final path = activeFile!.path;
    try {
      await File(path).delete();
      openedTabs.removeWhere((f) => f.path == path);
      files.removeWhere((f) => f.path == path);
      unsavedPaths.remove(path);

      if (openedTabs.isNotEmpty) {
        openFile(openedTabs.last);
      } else {
        activeFile = null;
        fileContent = "";
      }
      notifyListeners();
    } catch (e) {
      debugPrint("Error deleting: $e");
    }
  }

  Future<bool> renameActiveNote(String newName) async {
    if (activeFile == null) return false;

    final oldPath = activeFile!.path;
    final file = File(oldPath);

    final String extension = oldPath.split('.').last;
    if (!newName.endsWith('.$extension')) {
      newName = '$newName.$extension';
    }

    final parentDir = file.parent.path;
    final newPath = '$parentDir${Platform.pathSeparator}$newName';

    try {
      if (oldPath == newPath) return true;
      if (await File(newPath).exists()) return false; // Name conflict

      final newFile = await file.rename(newPath);

      activeFile = newFile;

      // Update sidebar
      final fileIndex = files.indexWhere((f) => f.path == oldPath);
      if (fileIndex != -1) files[fileIndex] = newFile;
      files.sort(
        (a, b) => a.path.toLowerCase().compareTo(b.path.toLowerCase()),
      );

      // Update tabs
      final tabIndex = openedTabs.indexWhere((f) => f.path == oldPath);
      if (tabIndex != -1) openedTabs[tabIndex] = newFile;

      // Update unsaved states
      if (unsavedPaths.contains(oldPath)) {
        unsavedPaths.remove(oldPath);
        unsavedPaths.add(newPath);
      }

      notifyListeners();
      return true;
    } catch (e) {
      debugPrint("Rename failed: $e");
      return false;
    }
  }

  // --------------------------------------------------------------------------
  // TEXT EDITING & SAVING LOGIC
  // --------------------------------------------------------------------------

  void updateContent(String newContent) {
    if (activeFile == null) return;
    fileContent = newContent;

    if (SettingsService().autoSave) {
      saveFileToDisk(activeFile!.path, newContent);
    } else {
      if (!unsavedPaths.contains(activeFile!.path)) {
        unsavedPaths.add(activeFile!.path);
        notifyListeners(); // Update UI to show the unsaved dot indicator
      }
    }
  }

  Future<bool> saveActiveNote() async {
    if (activeFile != null) {
      return await saveFileToDisk(activeFile!.path, fileContent);
    }
    return false;
  }

  Future<bool> saveFileToDisk(String path, String content) async {
    try {
      await File(path).writeAsString(content, flush: true);
      unsavedPaths.remove(path);
      notifyListeners(); // Remove unsaved dot
      return true;
    } catch (e) {
      debugPrint("Save failed: $e");
      return false;
    }
  }
}
