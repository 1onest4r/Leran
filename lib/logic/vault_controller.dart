import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import '../services/file_service.dart';
import '../services/settings_service.dart';
import '../services/tag_service.dart';

class VaultController extends ChangeNotifier {
  static final VaultController _instance = VaultController._internal();
  factory VaultController() => _instance;
  VaultController._internal();

  String? selectedDirectory;
  List<FileSystemEntity> files = [];
  List<FileSystemEntity> openedTabs = [];
  FileSystemEntity? activeFile;

  String fileContent = '';
  final Set<String> unsavedPaths = {};

  StreamSubscription<FileSystemEvent>? _dirWatcher;

  @override
  void dispose() {
    _dirWatcher?.cancel();
    super.dispose();
  }

  // --- Tag Helpers -----------------------------------------------------------

  /// Returns the tags currently embedded in [content].
  List<String> getTagsForContent(String content) =>
      TagService.parseTags(content);

  /// Reads every file in the vault and returns a tag -> [filePath] map.
  /// Used by MobileTagsView to build live groups.
  Future<Map<String, List<String>>> getAllTagGroups() async {
    final Map<String, String> contentMap = {};
    for (final f in files) {
      try {
        contentMap[f.path] = await FileService.readFile(f);
      } catch (_) {}
    }
    return TagService.buildTagGroups(contentMap);
  }

  /// Returns the display title for a file path (strips extension).
  String titleFromPath(String path) {
    final filename = path.split(Platform.pathSeparator).last;
    return filename
        .replaceAll(RegExp(r'\.md$', caseSensitive: false), '')
        .replaceAll(RegExp(r'\.txt$', caseSensitive: false), '');
  }

  // --- Vault Directory -------------------------------------------------------

  void setVaultDirectory(String path) {
    if (selectedDirectory == path) return;

    selectedDirectory = path;
    openedTabs.clear();
    activeFile = null;
    fileContent = '';
    unsavedPaths.clear();

    refreshFileList();
    _startWatching(path);
    notifyListeners();
  }

  Future<void> refreshFileList() async {
    if (selectedDirectory == null) return;
    if (!await Directory(selectedDirectory!).exists()) return;
    files = await FileService.getNotesFromPath(selectedDirectory!);
    notifyListeners();
  }

  void _startWatching(String path) {
    _dirWatcher?.cancel();
    _dirWatcher = Directory(path).watch().listen((_) => refreshFileList());
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

      final newUnsaved = <String>{};
      for (final p in unsavedPaths) {
        final fileName = p.split(Platform.pathSeparator).last;
        newUnsaved.add('${newDir.path}${Platform.pathSeparator}$fileName');
      }
      unsavedPaths
        ..clear()
        ..addAll(newUnsaved);

      _startWatching(newDir.path);
      notifyListeners();
    } catch (e) {
      debugPrint('Folder rename failed: $e');
    }
  }

  // --- File Operations -------------------------------------------------------

  Future<void> openFile(FileSystemEntity file) async {
    if (activeFile != null && unsavedPaths.contains(activeFile!.path)) {
      await saveFileToDisk(activeFile!.path, fileContent);
    }

    final content = await FileService.readFile(file);
    activeFile = file;
    fileContent = content;

    if (!openedTabs.any((f) => f.path == file.path)) {
      openedTabs.add(file);
    }
    notifyListeners();
  }

  void closeTab(FileSystemEntity file) {
    openedTabs.removeWhere((f) => f.path == file.path);
    if (activeFile?.path == file.path) {
      if (openedTabs.isNotEmpty) {
        openFile(openedTabs.last);
      } else {
        activeFile = null;
        fileContent = '';
      }
    } else {
      notifyListeners();
    }
  }

  /// Creates a new note on disk and sets it as [activeFile] WITHOUT reading
  /// back from disk so the editor's updateContent + saveActiveNote writes
  /// the real typed content with no race condition.
  Future<void> createNewNote(String fileName) async {
    if (selectedDirectory == null) return;

    await FileService.createNote(selectedDirectory!, fileName);
    await refreshFileList();

    final newFile = files.firstWhere(
      (f) => f.uri.pathSegments.last == fileName,
      orElse: () =>
          File('$selectedDirectory${Platform.pathSeparator}$fileName'),
    );

    activeFile = newFile;
    fileContent = '';

    if (!openedTabs.any((f) => f.path == newFile.path)) {
      openedTabs.add(newFile);
    }

    notifyListeners();
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
        fileContent = '';
      }
      notifyListeners();
    } catch (e) {
      debugPrint('Error deleting: $e');
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
      if (await File(newPath).exists()) return false;

      final newFile = await file.rename(newPath);
      activeFile = newFile;

      final fileIndex = files.indexWhere((f) => f.path == oldPath);
      if (fileIndex != -1) files[fileIndex] = newFile;
      files.sort(
        (a, b) => a.path.toLowerCase().compareTo(b.path.toLowerCase()),
      );

      final tabIndex = openedTabs.indexWhere((f) => f.path == oldPath);
      if (tabIndex != -1) openedTabs[tabIndex] = newFile;

      if (unsavedPaths.contains(oldPath)) {
        unsavedPaths.remove(oldPath);
        unsavedPaths.add(newPath);
      }
      notifyListeners();
      return true;
    } catch (e) {
      debugPrint('Rename failed: $e');
      return false;
    }
  }

  void updateContent(String newContent) {
    if (activeFile == null) return;
    fileContent = newContent;

    if (SettingsService().autoSave) {
      saveFileToDisk(activeFile!.path, newContent);
    } else {
      if (!unsavedPaths.contains(activeFile!.path)) {
        unsavedPaths.add(activeFile!.path);
        notifyListeners();
      }
    }
  }

  Future<bool> saveActiveNote() async {
    if (activeFile == null) return false;
    return await saveFileToDisk(activeFile!.path, fileContent);
  }

  Future<bool> saveFileToDisk(String path, String content) async {
    try {
      await File(path).writeAsString(content, flush: true);
      unsavedPaths.remove(path);
      notifyListeners();
      return true;
    } catch (e) {
      debugPrint('Save failed: $e');
      return false;
    }
  }
}
