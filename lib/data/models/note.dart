class Note {
  int? id;
  String title;
  String content;
  String filePath;
  DateTime updateAt;

  Note({
    this.id,
    this.title = '',
    this.content = '',
    this.filePath = '',
    DateTime? updateAt,
  }) : updateAt = updateAt ?? DateTime.now();

  // search for tags that are formatted as #tagname#
  List<String> get tags {
    // Regex looks for a '#' followed by anything that isn't a space or '#', ending with '#'
    final regex = RegExp(r'#([^#\s]+)#');
    final matches = regex.allMatches(content);

    // Using a Set prevents duplicates (e.g. if the user types #idea# twice in one note)
    return matches.map((m) => m.group(1)!).toSet().toList();
  }

  // Convert a Note into a Map to save to SQLite
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'content': content,
      'filePath': filePath,
      'updateAt': updateAt.toIso8601String(),
    };
  }

  // Create a Note from a SQLite Map
  factory Note.fromMap(Map<String, dynamic> map) {
    return Note(
      id: map['id'],
      title: map['title'],
      content: map['content'],
      filePath: map['filePath'],
      updateAt: DateTime.parse(map['updateAt']),
    );
  }
}
