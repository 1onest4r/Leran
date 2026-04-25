import 'package:isar/isar.dart';
import 'package:path_provider/path_provider.dart';
import '../models/note.dart';
import 'package:flutter/foundation.dart' show kIsWeb; // <-- ADD THIS

class IsarService {
  //late is for "i promise to initialize this before using"
  late Future<Isar> db;

  IsarService() {
    db = openDB();
  }

  Future<Isar> openDB() async {
    // --- WEB FIX: Browsers don't have a file system directory ---
    if (kIsWeb) {
      if (Isar.instanceNames.isEmpty) {
        return await Isar.open(
          [NoteSchema],
          directory:
              '', // Isar uses IndexedDB on the web, so it doesn't need a path!
        );
      }
      return Future.value(Isar.getInstance());
    }

    // --- DESKTOP / MOBILE LOGIC ---
    if (Isar.instanceNames.isEmpty) {
      final dir = await getApplicationDocumentsDirectory();

      return await Isar.open([NoteSchema], directory: dir.path);
    }
    return Future.value(Isar.getInstance());
  }

  Future<void> saveNoteIndex(Note newNote) async {
    final isar = await db;

    //doing an edit
    await isar.writeTxn(() async {
      await isar.notes.put(newNote); //an update
    });
  }

  //supa mega fast search (check title or content)
  Future<List<Note>> searchNotes(String query) async {
    final isar = await db;
    return await isar.notes
        .filter()
        .titleContains(query, caseSensitive: false)
        .or()
        .contentContains(query, caseSensitive: false)
        .sortByTitle()
        .limit(100)
        .findAll();
  }

  Future<void> saveNotesBatch(List<Note> notes) async {
    final isar = await db;
    await isar.writeTxn(() async {
      await isar.notes.putAll(notes);
    });
  }

  Future<void> clearAllNotes() async {
    final isar = await db;
    await isar.writeTxn(() async {
      await isar.notes.clear();
    });
  }

  //fetch all notes to show on the home page (limiting at 500)
  Future<List<Note>> getAllNotes() async {
    final isar = await db;
    return await isar.notes.where().sortByUpdateAtDesc().limit(500).findAll();
  }

  //fetch recently modified notes for the default search page view
  Future<List<Note>> getRecentNotes({int limit = 30}) async {
    final isar = await db;
    return await isar.notes.where().sortByUpdateAtDesc().limit(limit).findAll();
  }

  //find an existing note by its file path to prevent duplicates
  Future<Note?> getNoteByPath(String path) async {
    final isar = await db;
    final notes = await isar.notes.filter().filePathEqualTo(path).findAll();

    if (notes.isEmpty) {
      return null;
    }

    //self healing if duplication happened keep the first and delete the rest
    if (notes.length > 1) {
      await isar.writeTxn(() async {
        await isar.notes.filter().filePathEqualTo(path).deleteAll();
        await isar.notes.put(notes.first);
      });
    }

    return notes.first;
  }

  Future<void> deleteNoteByPath(String path) async {
    final isar = await db;
    await isar.writeTxn(() async {
      await isar.notes.filter().filePathEqualTo(path).deleteAll();
    });
  }
}
