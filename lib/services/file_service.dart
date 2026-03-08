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

  static Future<void> createNote(String directoryPath, String fileName) async {
    if (!fileName.endsWith('.md') && !fileName.endsWith('.txt')) {
      fileName = '$fileName.txt';
    }
    final path = '$directoryPath${Platform.pathSeparator}$fileName';
    final file = File(path);

    if (!await file.exists()) {
      DateTime now = DateTime.now();
      String twoDigits(int n) => n.toString().padLeft(2, '0');
      String formatted =
          "${now.year}-${twoDigits(now.month)}-${twoDigits(now.day)} "
          "${twoDigits(now.hour)}:${twoDigits(now.minute)}:${twoDigits(now.second)}";

      // Makes sure standard newly created formats parse right on first lines natively
      await file.writeAsString("$fileName\nCreated on $formatted");
    }
  }

  static Future<String> renameDirectory(String oldPath, String newName) async {
    final dir = Directory(oldPath);
    final parentPath = dir.parent.path;
    final newPath = '$parentPath${Platform.pathSeparator}$newName';
    await dir.rename(newPath);
    return newPath;
  }
}
