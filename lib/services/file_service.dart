import 'dart:io';

class FileService {
  static Future<List<FileSystemEntity>> getNotesFromPath(
    String directoryPath,
  ) async {
    final dir = Directory(directoryPath);
    if (!await dir.exists()) return [];

    final List<FileSystemEntity> files = dir.listSync();

    files.sort((a, b) => a.path.toLowerCase().compareTo(b.path.toLowerCase()));

    return files.where((file) {
      return file.path.endsWith(".md") || file.path.endsWith(".txt");
    }).toList();
  }

  static Future<String> readFile(FileSystemEntity file) async {
    try {
      final File targetFile = File(file.path);
      return await targetFile.readAsString();
    } catch (e) {
      return "Error reading file: $e";
    }
  }

  /// Creates a new note file. The first line is the clean title (no extension,
  /// no timestamp) so the editor can parse it back correctly on re-open.
  static Future<void> createNote(String directoryPath, String fileName) async {
    if (!fileName.endsWith('.md') && !fileName.endsWith('.txt')) {
      fileName = '$fileName.md';
    }

    final path = '$directoryPath${Platform.pathSeparator}$fileName';
    final file = File(path);

    if (!await file.exists()) {
      // Strip extension so the title field shows a clean name, not "note.md"
      final cleanTitle = fileName
          .replaceAll(RegExp(r'\.md$'), '')
          .replaceAll(RegExp(r'\.txt$'), '');

      // Write only the title on the first line — body starts empty.
      // This prevents the "Created on …" line from appearing in the editor body.
      await file.writeAsString(cleanTitle);
    }
  }

  /// Generates a unique file path so we never silently overwrite an existing note.
  /// If "My Note.md" already exists it tries "My Note (2).md", "My Note (3).md", …
  static Future<String> resolveUniqueFilePath(
    String directoryPath,
    String fileName,
  ) async {
    if (!fileName.endsWith('.md') && !fileName.endsWith('.txt')) {
      fileName = '$fileName.md';
    }

    final ext = fileName.endsWith('.md') ? '.md' : '.txt';
    final base = fileName.substring(0, fileName.length - ext.length);

    String candidate = fileName;
    int counter = 2;

    while (await File(
      '$directoryPath${Platform.pathSeparator}$candidate',
    ).exists()) {
      candidate = '$base ($counter)$ext';
      counter++;
    }

    return '$directoryPath${Platform.pathSeparator}$candidate';
  }

  static Future<String> renameDirectory(String oldPath, String newName) async {
    final dir = Directory(oldPath);
    final parentPath = dir.parent.path;
    final newPath = '$parentPath${Platform.pathSeparator}$newName';
    await dir.rename(newPath);
    return newPath;
  }
}
