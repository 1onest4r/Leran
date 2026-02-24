import 'dart:io';

class FileService {
  // 1. Get List of Files
  static Future<List<FileSystemEntity>> getNotesFromPath(
    String directoryPath,
  ) async {
    final dir = Directory(directoryPath);
    if (!await dir.exists()) return [];

    final List<FileSystemEntity> files = dir.listSync();

    // Sort files alphabetically so they don't jump around
    files.sort((a, b) => a.path.toLowerCase().compareTo(b.path.toLowerCase()));

    return files.where((file) {
      return file.path.endsWith(".md") || file.path.endsWith(".txt");
    }).toList();
  }

  // 2. Read File
  static Future<String> readFile(FileSystemEntity file) async {
    try {
      final File targetFile = File(file.path);
      return await targetFile.readAsString();
    } catch (e) {
      return "Error reading file: $e";
    }
  }

  // 3. Create File
  static Future<void> createNote(String directoryPath, String fileName) async {
    if (!fileName.endsWith('.md') && !fileName.endsWith('.txt')) {
      fileName = '$fileName.md';
    }
    final path = '$directoryPath${Platform.pathSeparator}$fileName';
    final file = File(path);

    if (!await file.exists()) {
      await file.writeAsString("# $fileName\nCreated on ${DateTime.now()}");
    }
  }

  // 4. Rename Directory (The missing method causing your error)
  static Future<String> renameDirectory(String oldPath, String newName) async {
    final dir = Directory(oldPath);
    // Get the parent folder (e.g. C:/Users/Docs)
    final parentPath = dir.parent.path;
    // Make new path (e.g. C:/Users/Docs/NewName)
    final newPath = '$parentPath${Platform.pathSeparator}$newName';

    await dir.rename(newPath);
    return newPath;
  }
}
