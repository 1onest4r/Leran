import 'package:isar/isar.dart';

//this line tells isar to generate code here?
part 'note.g.dart';

@collection
class Note {
  Id id = Isar.autoIncrement;

  //index the title
  @Index(type: IndexType.value)
  String title = '';

  //actual words in the .md file
  String content = '';

  //index the path so we know exactly which .md file this is
  @Index(type: IndexType.hash)
  String filePath = '';

  DateTime updateAt = DateTime.now();
}
