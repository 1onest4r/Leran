import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import '../services/file_service.dart';
import '../widgets/left_sidebar.dart';
import '../widgets/right_sidebar.dart'; // Assumes you renamed this file based on your import

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  // -- VAULT STATE --
  String? _selectedDirectory;
  List<FileSystemEntity> _files = [];
  StreamSubscription<FileSystemEvent>? _dirWatcher;

  // -- TAB & EDITOR STATE --
  List<FileSystemEntity> _openedTabs = []; // List of open files
  FileSystemEntity? _selectedFile; // The currently visible file
  String _fileContent = "";
  String _fileTitle = "";

  @override
  void dispose() {
    _dirWatcher?.cancel();
    super.dispose();
  }

  // ====================================================================
  // 1. VAULT MANAGEMENT (Open, Close, Rename)
  // ====================================================================

  /// Opens the system folder picker
  Future<void> _pickFolder() async {
    String? result = await FilePicker.platform.getDirectoryPath();
    if (result != null) {
      setState(() {
        _selectedDirectory = result;
      });
      _refreshFileList();
      _startWatching(result);
    }
  }

  /// Closes the vault and resets state (used when folder is lost or renamed)
  void _closeVault({String reason = ""}) {
    _dirWatcher?.cancel();
    if (mounted) {
      setState(() {
        _selectedDirectory = null;
        _files = [];
        _selectedFile = null;
        _openedTabs = [];
        _fileContent = "";
      });

      if (reason.isNotEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(reason),
            backgroundColor: Colors.redAccent,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  /// Handles renaming the root vault directory
  Future<void> _handleRename(String newName) async {
    if (_selectedDirectory == null) return;

    try {
      // 1. Pause watcher to prevent errors during rename
      _dirWatcher?.cancel();

      // 2. Perform the rename via Service
      // Note: Ensure FileService.renameDirectory exists in your service file
      String newPath = await FileService.renameDirectory(
        _selectedDirectory!,
        newName,
      );

      // 3. Update State & Reset Tabs (Old paths are invalid now)
      setState(() {
        _selectedDirectory = newPath;
        _openedTabs = [];
        _selectedFile = null;
        _fileContent = "";
      });

      // 4. Restart Services
      _refreshFileList();
      _startWatching(newPath);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Vault renamed to '$newName'"),
            backgroundColor: const Color(0xFF52CB8B),
          ),
        );
      }
    } catch (e) {
      // If fail, restart watcher on old path
      _startWatching(_selectedDirectory!);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Rename failed: $e"),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  // ====================================================================
  // 2. FILE SYSTEM LOGIC (Watch, Refresh, Create)
  // ====================================================================

  /// Starts watching the directory for external changes
  void _startWatching(String path) {
    _dirWatcher?.cancel();
    try {
      final dir = Directory(path);
      _dirWatcher = dir.watch().listen(
        (event) {
          // File changed/added/deleted inside -> Refresh list
          _refreshFileList();
        },
        onError: (e) {
          // The root folder itself was lost/moved/deleted
          _closeVault(reason: "Vault folder lost or accessed denied.");
        },
      );
    } catch (e) {
      _closeVault(reason: "Unable to access vault.");
    }
  }

  /// Reloads the list of files from disk
  Future<void> _refreshFileList() async {
    if (_selectedDirectory == null) return;

    // Safety Check: Does folder still exist?
    if (!await Directory(_selectedDirectory!).exists()) {
      _closeVault(reason: "Vault folder no longer exists.");
      return;
    }

    final files = await FileService.getNotesFromPath(_selectedDirectory!);
    if (mounted) {
      setState(() {
        _files = files;
      });
    }
  }

  /// Shows dialog to create a new note
  void _createNewNote() {
    if (_selectedDirectory == null) return;
    final TextEditingController filenameController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: const Color(0xFF252526),
          title: const Text("New Note", style: TextStyle(color: Colors.white)),
          content: TextField(
            controller: filenameController,
            autofocus: true,
            style: const TextStyle(color: Colors.white),
            cursorColor: const Color(0xFF52CB8B),
            decoration: const InputDecoration(
              hintText: "Enter filename...",
              hintStyle: TextStyle(color: Colors.grey),
              enabledBorder: UnderlineInputBorder(
                borderSide: BorderSide(color: Colors.grey),
              ),
              focusedBorder: UnderlineInputBorder(
                borderSide: BorderSide(color: Color(0xFF52CB8B)),
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Cancel", style: TextStyle(color: Colors.grey)),
            ),
            TextButton(
              onPressed: () async {
                if (filenameController.text.isNotEmpty) {
                  await FileService.createNote(
                    _selectedDirectory!,
                    filenameController.text,
                  );
                  if (context.mounted) Navigator.pop(context);
                }
              },
              child: const Text(
                "Create",
                style: TextStyle(color: Color(0xFF52CB8B)),
              ),
            ),
          ],
        );
      },
    );
  }

  // ====================================================================
  // 3. TAB & SELECTION LOGIC
  // ====================================================================

  Future<void> _onFileSelected(FileSystemEntity file) async {
    // 1. Read Content
    final content = await FileService.readFile(file);
    final title = file.uri.pathSegments.lastWhere((s) => s.isNotEmpty);

    setState(() {
      _selectedFile = file;
      _fileContent = content;
      _fileTitle = title;

      // 2. Add to Tabs if not already there
      bool alreadyOpen = _openedTabs.any((f) => f.path == file.path);
      if (!alreadyOpen) {
        _openedTabs.add(file);
      }
    });
  }

  void _closeTab(FileSystemEntity file) {
    setState(() {
      _openedTabs.removeWhere((f) => f.path == file.path);

      // If we closed the ACTIVE file, switch logic
      if (_selectedFile?.path == file.path) {
        if (_openedTabs.isNotEmpty) {
          // Switch to the last opened tab
          _onFileSelected(_openedTabs.last);
        } else {
          // No tabs left
          _selectedFile = null;
          _fileContent = "";
          _fileTitle = "";
        }
      }
    });
  }

  // ====================================================================
  // 4. UI BUILD
  // ====================================================================

  @override
  Widget build(BuildContext context) {
    const Color bgDark = Color(0xFF1E1E1E);
    const Color accentGreen = Color(0xFF52CB8B);

    return Scaffold(
      backgroundColor: bgDark,
      body: SafeArea(
        child: _selectedDirectory == null
            // STATE 1: No Folder Selected
            ? Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.folder_open, size: 80, color: Colors.grey),
                    const SizedBox(height: 20),
                    const Text(
                      "No Vault Open",
                      style: TextStyle(color: Colors.white, fontSize: 24),
                    ),
                    const SizedBox(height: 30),
                    ElevatedButton.icon(
                      onPressed: _pickFolder,
                      icon: const Icon(Icons.create_new_folder),
                      label: const Text("Open Folder"),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: accentGreen,
                        foregroundColor: Colors.black,
                      ),
                    ),
                  ],
                ),
              )
            // STATE 2: Main App UI
            : Row(
                children: [
                  Expanded(
                    flex: 2,
                    child: LeftSidebar(
                      files: _files,
                      selectedFile: _selectedFile,
                      onFileSelected: _onFileSelected,
                      onNewNote: _createNewNote,
                      selectedDirectory: _selectedDirectory!,
                      onFolderRename:
                          _handleRename, // <--- Passing the rename logic
                    ),
                  ),
                  VerticalDivider(
                    width: 1,
                    thickness: 1,
                    color: Colors.grey[800],
                  ),
                  Expanded(
                    flex: 6,
                    child: _selectedFile == null
                        ? Center(
                            child: Text(
                              "Select a file to edit",
                              style: TextStyle(color: Colors.grey[600]),
                            ),
                          )
                        : RightSidebar(
                            key: ValueKey(_selectedFile!.path),
                            title: _fileTitle,
                            content: _fileContent,
                            openedTabs: _openedTabs,
                            activeTab: _selectedFile!,
                            onTabSelected: _onFileSelected,
                            onTabClosed: _closeTab,
                          ),
                  ),
                ],
              ),
      ),
    );
  }
}
