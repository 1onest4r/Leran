import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';

import '../services/file_service.dart';
import '../services/settings_service.dart';
import '../utils/app_dialogs.dart';
import '../utils/search_delegate.dart';
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
    // Explicit type added for search delegate
    final FileSystemEntity? result = await showSearch<FileSystemEntity?>(
      context: context,
      delegate: FileSearchDelegate(_files),
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
    if (SettingsService().autoSave) {
      _saveToDisk(_selectedFile!.path, newContent);
    } else {
      _fileContent = newContent;
      if (!_unsavedPaths.contains(_selectedFile!.path)) {
        setState(() => _unsavedPaths.add(_selectedFile!.path));
      }
    }
  }

  Future<void> _manualSave() async {
    if (_selectedFile != null)
      await _saveToDisk(_selectedFile!.path, _fileContent);
  }

  Future<void> _saveToDisk(String path, String content) async {
    try {
      await File(path).writeAsString(content);
      if (mounted) setState(() => _unsavedPaths.remove(path));
    } catch (e) {
      debugPrint("Save failed: $e");
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

  Future<void> _renameCurrentFile(String newName) async {
    // Logic for rename would go here or call FileService
  }

  Future<void> _handleFolderRename(String newName) async {
    // Logic for folder rename would go here or call FileService
  }

  @override
  Widget build(BuildContext context) {
    // Rebuild when settings change (theme toggle)
    return AnimatedBuilder(
      animation: SettingsService(),
      builder: (context, child) {
        final settings = SettingsService();
        return Scaffold(
          backgroundColor: settings.scaffoldColor,
          body: SafeArea(
            // RESTORED: The "No Vault" Screen
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
                // MAIN UI
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
