import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';

import '../services/file_service.dart';
import '../services/settings_service.dart';
import '../utils/app_dialogs.dart';
import '../utils/search_dialog.dart';
import '../widgets/left_sidebar.dart';
import '../widgets/right_sidebar.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  String? _selectedDirectory;
  List<FileSystemEntity> _files = [];
  StreamSubscription<FileSystemEvent>? _dirWatcher;
  List<FileSystemEntity> _openedTabs = [];
  FileSystemEntity? _selectedFile;
  String _fileContent = "";
  String _fileTitle = "";
  final Set<String> _unsavedPaths = {};

  @override
  void dispose() {
    _dirWatcher?.cancel();
    super.dispose();
  }

  // --- ACTIONS ---
  void _openSearch() async {
    if (_files.isEmpty) return;

    final FileSystemEntity? result = await showDialog<FileSystemEntity?>(
      context: context,
      barrierColor: Colors.black.withOpacity(0.4),
      builder: (context) => SearchDialog(files: _files),
    );

    if (result != null) _onFileSelected(result);
  }

  void _createNewNote() async {
    if (_selectedDirectory == null) return;
    final String? fileName = await AppDialogs.showNewNoteDialog(context);
    if (fileName != null) {
      await FileService.createNote(_selectedDirectory!, fileName);
    }
  }

  void _deleteCurrentFile() async {
    if (_selectedFile == null) return;
    final bool confirm = await AppDialogs.showDeleteConfirmation(context);
    if (confirm) {
      final path = _selectedFile!.path;
      try {
        await File(path).delete();
        setState(() {
          _openedTabs.removeWhere((f) => f.path == path);
          _files.removeWhere((f) => f.path == path);
          _unsavedPaths.remove(path);
          if (_openedTabs.isNotEmpty) {
            _onFileSelected(_openedTabs.last);
          } else {
            _selectedFile = null;
            _fileContent = "";
            _fileTitle = "";
          }
        });
      } catch (e) {
        debugPrint("Error deleting: $e");
      }
    }
  }

  void _handleContentChange(String newContent) {
    if (_selectedFile == null) return;
    _fileContent = newContent;
    if (SettingsService().autoSave) {
      _saveToDisk(_selectedFile!.path, newContent);
    } else {
      if (!_unsavedPaths.contains(_selectedFile!.path)) {
        setState(() => _unsavedPaths.add(_selectedFile!.path));
      }
    }
  }

  Future<void> _manualSave() async {
    if (_selectedFile != null) {
      final bool success = await _saveToDisk(_selectedFile!.path, _fileContent);
      if (success && mounted) {
        showDialog(
          context: context,
          barrierColor: Colors.black12,
          barrierDismissible: false,
          builder: (BuildContext dialogContext) {
            Future.delayed(const Duration(milliseconds: 1500), () {
              if (dialogContext.mounted &&
                  Navigator.of(dialogContext).canPop()) {
                Navigator.of(dialogContext).pop();
              }
            });
            final settings = SettingsService();
            return AlertDialog(
              backgroundColor: settings.sidebarColor,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
                side: BorderSide(color: settings.dividerColor),
              ),
              contentPadding: const EdgeInsets.symmetric(
                vertical: 20,
                horizontal: 24,
              ),
              content: Row(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.check_circle_outline,
                    color: settings.accentColor,
                    size: 28,
                  ),
                  const SizedBox(width: 12),
                  Text(
                    "File Saved!",
                    style: TextStyle(
                      color: settings.textColor,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            );
          },
        );
      }
    }
  }

  Future<bool> _saveToDisk(String path, String content) async {
    try {
      await File(path).writeAsString(content, flush: true);
      if (mounted) setState(() => _unsavedPaths.remove(path));
      return true;
    } catch (e) {
      debugPrint("Save failed: $e");
      if (mounted) {
        final settings = SettingsService();
        showDialog(
          context: context,
          builder: (ctx) => AlertDialog(
            backgroundColor: settings.sidebarColor,
            title: const Text(
              "Save Error",
              style: TextStyle(color: Colors.redAccent),
            ),
            content: Text(
              "Could not save the file.\n\nError details: $e",
              style: TextStyle(color: settings.textColor),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(ctx),
                child: Text(
                  "Close",
                  style: TextStyle(color: settings.accentColor),
                ),
              ),
            ],
          ),
        );
      }
      return false;
    }
  }

  Future<void> _pickFolder() async {
    String? result = await FilePicker.platform.getDirectoryPath();
    if (result != null) {
      setState(() => _selectedDirectory = result);
      _refreshFileList();
      _startWatching(result);
    }
  }

  void _startWatching(String path) {
    _dirWatcher?.cancel();
    _dirWatcher = Directory(path).watch().listen((event) {
      _refreshFileList();
      if (event is FileSystemDeleteEvent || event is FileSystemMoveEvent) {
        // Handle external deletes logic
      }
    });
  }

  Future<void> _refreshFileList() async {
    if (_selectedDirectory == null) return;
    if (!await Directory(_selectedDirectory!).exists()) return;
    final files = await FileService.getNotesFromPath(_selectedDirectory!);
    if (mounted) setState(() => _files = files);
  }

  Future<void> _onFileSelected(FileSystemEntity file) async {
    if (_selectedFile != null && _unsavedPaths.contains(_selectedFile!.path)) {
      await _saveToDisk(_selectedFile!.path, _fileContent);
    }
    final content = await FileService.readFile(file);
    final title = file.uri.pathSegments.lastWhere((s) => s.isNotEmpty);
    setState(() {
      _selectedFile = file;
      _fileContent = content;
      _fileTitle = title;
      if (!_openedTabs.any((f) => f.path == file.path)) _openedTabs.add(file);
    });
  }

  void _closeTab(FileSystemEntity file) {
    setState(() {
      _openedTabs.removeWhere((f) => f.path == file.path);
      if (_selectedFile?.path == file.path) {
        if (_openedTabs.isNotEmpty)
          _onFileSelected(_openedTabs.last);
        else {
          _selectedFile = null;
          _fileContent = "";
          _fileTitle = "";
        }
      }
    });
  }

  // --- NEW: Implemented File Rename Logic ---
  Future<void> _renameCurrentFile(String newName) async {
    if (_selectedFile == null) return;

    final oldPath = _selectedFile!.path;
    final file = File(oldPath);

    // Ensure it keeps the original extension if the user didn't type it
    final String extension = oldPath.split('.').last;
    if (!newName.endsWith('.$extension')) {
      newName = '$newName.$extension';
    }

    final parentDir = file.parent.path;
    final newPath = '$parentDir${Platform.pathSeparator}$newName';

    try {
      if (oldPath == newPath) return; // Name didn't change

      // Prevent accidental overwrites
      if (await File(newPath).exists()) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text("A file with that name already exists!"),
              backgroundColor: Colors.redAccent,
            ),
          );
        }
        return;
      }

      final newFile = await file.rename(newPath);

      setState(() {
        _selectedFile = newFile;
        _fileTitle = newName;

        // Update the file in the sidebar list
        final fileIndex = _files.indexWhere((f) => f.path == oldPath);
        if (fileIndex != -1) _files[fileIndex] = newFile;
        _files.sort(
          (a, b) => a.path.toLowerCase().compareTo(b.path.toLowerCase()),
        );

        // Update the file in opened tabs
        final tabIndex = _openedTabs.indexWhere((f) => f.path == oldPath);
        if (tabIndex != -1) _openedTabs[tabIndex] = newFile;

        // Carry over unsaved state to the new path
        if (_unsavedPaths.contains(oldPath)) {
          _unsavedPaths.remove(oldPath);
          _unsavedPaths.add(newPath);
        }
      });
    } catch (e) {
      debugPrint("Rename failed: $e");
    }
  }

  // --- NEW: Implemented Folder Rename Logic ---
  Future<void> _handleFolderRename(String newName) async {
    if (_selectedDirectory == null) return;
    try {
      final dir = Directory(_selectedDirectory!);
      final parentPath = dir.parent.path;
      final newPath = '$parentPath${Platform.pathSeparator}$newName';

      if (await Directory(newPath).exists()) return;

      final newDir = await dir.rename(newPath);

      setState(() => _selectedDirectory = newDir.path);
      await _refreshFileList();

      // Update the active paths of all opened tabs so they don't break
      setState(() {
        _openedTabs = _openedTabs.map((f) {
          final fileName = f.uri.pathSegments.lastWhere((s) => s.isNotEmpty);
          return File('${newDir.path}${Platform.pathSeparator}$fileName');
        }).toList();

        if (_selectedFile != null) {
          final fileName = _selectedFile!.uri.pathSegments.lastWhere(
            (s) => s.isNotEmpty,
          );
          _selectedFile = File(
            '${newDir.path}${Platform.pathSeparator}$fileName',
          );
        }

        final newUnsaved = <String>{};
        for (final p in _unsavedPaths) {
          final fileName = p.split(Platform.pathSeparator).last;
          newUnsaved.add('${newDir.path}${Platform.pathSeparator}$fileName');
        }
        _unsavedPaths.clear();
        _unsavedPaths.addAll(newUnsaved);
      });

      _startWatching(newDir.path);
    } catch (e) {
      debugPrint("Folder rename failed: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: SettingsService(),
      builder: (context, child) {
        final settings = SettingsService();
        return Scaffold(
          backgroundColor: settings.scaffoldColor,
          body: SafeArea(
            child: _selectedDirectory == null
                ? Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.folder_open,
                          size: 80,
                          color: settings.dimTextColor,
                        ),
                        const SizedBox(height: 20),
                        Text(
                          "No Vault Open",
                          style: TextStyle(
                            color: settings.textColor,
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 10),
                        Text(
                          "Select a folder to start writing.",
                          style: TextStyle(color: settings.dimTextColor),
                        ),
                        const SizedBox(height: 30),
                        ElevatedButton.icon(
                          onPressed: _pickFolder,
                          icon: const Icon(Icons.create_new_folder),
                          label: const Text("Open Folder"),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: settings.accentColor,
                            foregroundColor: Colors.black,
                            padding: const EdgeInsets.symmetric(
                              horizontal: 24,
                              vertical: 16,
                            ),
                          ),
                        ),
                      ],
                    ),
                  )
                : Row(
                    children: [
                      Expanded(
                        flex: 2,
                        child: LeftSidebar(
                          files: _files,
                          selectedFile: _selectedFile,
                          selectedDirectory: _selectedDirectory!,
                          onFileSelected: _onFileSelected,
                          onNewNote: _createNewNote,
                          onFolderRename: _handleFolderRename,
                          onSearchClick: _openSearch,
                          onSettingsClick: () =>
                              AppDialogs.showSettings(context),
                        ),
                      ),
                      VerticalDivider(width: 1, color: settings.dividerColor),
                      Expanded(
                        flex: 6,
                        child: _selectedFile == null
                            ? Center(
                                child: Text(
                                  "Select a file to edit",
                                  style: TextStyle(
                                    color: settings.dimTextColor,
                                  ),
                                ),
                              )
                            : RightSidebar(
                                key: ValueKey(_selectedFile!.path),
                                title: _fileTitle,
                                content: _fileContent,
                                openedTabs: _openedTabs,
                                activeTab: _selectedFile!,
                                unsavedPaths: _unsavedPaths,
                                onTabSelected: _onFileSelected,
                                onTabClosed: _closeTab,
                                onContentChanged: _handleContentChange,
                                onManualSave: _manualSave,
                                onRename: _renameCurrentFile,
                                onDelete: _deleteCurrentFile,
                              ),
                      ),
                    ],
                  ),
          ),
        );
      },
    );
  }
}
