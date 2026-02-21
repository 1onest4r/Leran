import 'dart:io';

class FileService {
  // 1. Load files from a SPECIFIC path provided by the user
  static List<FileSystemEntity> getNotesFromPath(String directoryPath) {
    final dir = Directory(directoryPath);

    // If folder doesn't exist (rare since user just picked it), return empty
    if (!dir.existsSync()) {
      return [];
    }

    // Get files and filter for .md or .txt
    List<FileSystemEntity> files = dir.listSync();

    files.sort((a, b) => a.path.compareTo(b.path));

    return files.where((file) {
      // Only show text files
      return file.path.endsWith(".md") || file.path.endsWith(".txt");
    }).toList();
  }

  // 2. Read the content of a specific file
  static Future<String> readFile(FileSystemEntity file) async {
    try {
      final File targetFile = File(file.path);
      return await targetFile.readAsString();
    } catch (e) {
      return "Error reading file: $e";
    }
  }

  //create a file
  static Future<void> createNote(String directoryPath, String fileName) async {
    if (!fileName.endsWith('.md') && !fileName.endsWith('.txt')) {
      fileName = '$fileName.md';
    }

    final path = '$directoryPath/$fileName';
    final file = File(path);

    //dont overwrite if exists
    if (!await file.exists()) {
      await file.writeAsString("# $fileName\nCreated on ${DateTime.now()}");
    }
  }
}
