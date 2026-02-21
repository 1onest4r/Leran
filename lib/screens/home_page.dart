import 'dart:io';
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import '../services/file_service.dart';
import '../widgets/left_sidebar.dart';
import '../widgets/right_sidebar.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  // State Variables
  String? _selectedDirectory; // Stores the folder path
  List<FileSystemEntity> _files = [];
  FileSystemEntity? _selectedFile;
  String _fileContent = "";
  String _fileTitle = "";

  //the watcher
  StreamSubscription<FileSystemEvent>? _dirWatcher;

  @override
  void dispose() {
    //stop watching when app closes
    _dirWatcher?.cancel();
    super.dispose();
  }

  // 1. The Method to Pick a Folder
  Future<void> _pickFolder() async {
    // Opens the native system dialog
    String? result = await FilePicker.platform.getDirectoryPath();

    if (result != null) {
      // User picked a folder!
      setState(() {
        _selectedDirectory = result;
      });
      _refreshFileList();
      _startWatching(result);
    }
  }

  void _startWatching(String path) {
    //cancel any previous watcher
    _dirWatcher?.cancel();

    //watch the directory for any changes
    _dirWatcher = Directory(path).watch().listen((event) {
      //when event happens refresh the list
      _refreshFileList();
    });
  }

  Future<void> _refreshFileList() async {
    if (_selectedDirectory == null) return;
    final files = await FileService.getNotesFromPath(_selectedDirectory!);
    setState(() {
      _files = files;
    });
  }

  // 3. Handle File Click (Same as before)
  Future<void> _onFileSelected(FileSystemEntity file) async {
    final content = await FileService.readFile(file);
    final title = file.path.split(Platform.pathSeparator).last;

    setState(() {
      _selectedFile = file;
      _fileContent = content;
      _fileTitle = title;
    });
  }

  //new note logic
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
              hintText: "Enter filename (e.g, inventing univers)",
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
                  // Create the file via Service
                  await FileService.createNote(
                    _selectedDirectory!,
                    filenameController.text,
                  );
                  Navigator.pop(context); // Close dialog
                  // The _dirWatcher will detect the new file and auto-refresh the list!
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

  @override
  Widget build(BuildContext context) {
    // Colors
    const Color bgDark = Color(0xFF1E1E1E);
    const Color accentGreen = Color(0xFF52CB8B);

    return Scaffold(
      backgroundColor: bgDark,
      body: SafeArea(
        child: _selectedDirectory == null
            // STATE 1: NO FOLDER SELECTED -> SHOW WELCOME SCREEN
            ? Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.folder_open, size: 80, color: Colors.grey),
                    const SizedBox(height: 20),
                    const Text(
                      "No Vault Open",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 10),
                    const Text(
                      "Select a folder to start writing.",
                      style: TextStyle(color: Colors.grey),
                    ),
                    const SizedBox(height: 30),
                    ElevatedButton.icon(
                      onPressed: _pickFolder,
                      icon: const Icon(Icons.create_new_folder),
                      label: const Text("Open Folder"),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: accentGreen,
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
            // STATE 2: FOLDER SELECTED -> SHOW MAIN APP
            : Row(
                children: [
                  // LEFT SIDEBAR
                  Expanded(
                    flex: 2,
                    child: LeftSidebar(
                      files: _files,
                      selectedFile: _selectedFile,
                      onFileSelected: _onFileSelected,
                      onNewNote: _createNewNote,
                    ),
                  ),

                  VerticalDivider(
                    width: 1,
                    thickness: 1,
                    color: Colors.grey[800],
                  ),

                  // RIGHT SECTION
                  Expanded(
                    flex: 6,
                    child: _selectedFile == null
                        ? Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.description_outlined,
                                  size: 60,
                                  color: Colors.grey[800],
                                ),
                                const SizedBox(height: 10),
                                const Text(
                                  "Select a file to view",
                                  style: TextStyle(color: Colors.grey),
                                ),
                              ],
                            ),
                          )
                        : RightSidebar(
                            key: ValueKey(_selectedFile!.path),
                            title: _fileTitle,
                            content: _fileContent,
                          ),
                  ),
                ],
              ),
      ),
    );
  }
}
