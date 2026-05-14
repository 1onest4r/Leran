import 'dart:io';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import '../models/note.dart';

class DatabaseService {
  Database? _db;

  // Promise to provide the DB
  Future<Database> get db async {
    if (_db != null) return _db!;
    _db = await _initDB();
    return _db!;
  }

  Future<Database> _initDB() async {
    // If we are on Desktop, we need to initialize FFI for SQLite
    if (Platform.isWindows || Platform.isLinux) {
      sqfliteFfiInit();
      databaseFactory = databaseFactoryFfi;
    }

    final dir = await getApplicationDocumentsDirectory();
    final path = join(dir.path, 'leran_index.db');

    return await databaseFactory.openDatabase(
      path,
      options: OpenDatabaseOptions(
        version: 1,
        onCreate: (db, version) async {
          // Create the main notes table
          await db.execute('''
            CREATE TABLE notes (
              id INTEGER PRIMARY KEY AUTOINCREMENT,
              title TEXT,
              content TEXT,
              filePath TEXT UNIQUE,
              updateAt TEXT
            )
          ''');

          // Index the filePath and title for extremely fast lookups
          await db.execute('CREATE INDEX idx_file_path ON notes(filePath)');
          await db.execute('CREATE INDEX idx_title ON notes(title)');
        },
      ),
    );
  }

  Future<void> saveNoteIndex(Note newNote) async {
    final database = await db;
    // ConflictAlgorithm.replace handles Upserts. If the filePath exists, it overwrites it.
    await database.insert(
      'notes',
      newNote.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<List<Note>> searchNotes(String query) async {
    final database = await db;
    // SQLite's LIKE operator is highly optimized.
    final maps = await database.query(
      'notes',
      where: 'title LIKE ? OR content LIKE ?',
      whereArgs: ['%$query%', '%$query%'],
      orderBy: 'title ASC',
      limit: 100,
    );
    return maps.map((map) => Note.fromMap(map)).toList();
  }

  Future<void> saveNotesBatch(List<Note> notes) async {
    final database = await db;
    // Using a Batch speeds up massive inserts (like your initial folder scan) immensely
    final batch = database.batch();
    for (var note in notes) {
      batch.insert(
        'notes',
        note.toMap(),
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    }
    await batch.commit(noResult: true);
  }

  Future<void> clearAllNotes() async {
    final database = await db;
    await database.delete('notes');
  }

  Future<List<Note>> getAllNotes() async {
    final database = await db;
    final maps = await database.query(
      'notes',
      orderBy: 'updateAt DESC',
      limit: 500,
    );
    return maps.map((map) => Note.fromMap(map)).toList();
  }

  Future<List<Note>> getRecentNotes({int limit = 30}) async {
    final database = await db;
    final maps = await database.query(
      'notes',
      orderBy: 'updateAt DESC',
      limit: limit,
    );
    return maps.map((map) => Note.fromMap(map)).toList();
  }

  Future<Note?> getNoteByPath(String path) async {
    final database = await db;
    final maps = await database.query(
      'notes',
      where: 'filePath = ?',
      whereArgs: [path],
    );

    if (maps.isEmpty) return null;

    // SQLite UNIQUE constraint guarantees we only ever get 1 back
    return Note.fromMap(maps.first);
  }

  Future<void> deleteNoteByPath(String path) async {
    final database = await db;
    await database.delete('notes', where: 'filePath = ?', whereArgs: [path]);
  }
}
