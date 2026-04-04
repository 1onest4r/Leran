import 'package:isar/isar.dart';
import 'package:path_provider/path_provider.dart';
import '../models/note.dart';

class IsarService {
  //late is for "i promise to initialize this before using"
  late Future<Isar> db;

  IsarService() {
    db = openDB();
  }

  Future<Isar> openDB() async {
    //check if its already open so we dont crash the app
    if (Isar.instanceNames.isEmpty) {
      //get the safe, hidden system directory "not the user's vault"
      final dir = await getApplicationDocumentsDirectory();

      return await Isar.open(
        [NoteSchema], //this comes from note.g.dart
        directory: dir.path,
      );
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
}
