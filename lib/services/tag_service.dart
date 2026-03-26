/// Pure logic for tags — no Flutter imports, fully testable.
///
/// Tags are stored inline in the note body as `#tagname` tokens,
/// exactly like Obsidian. No separate database is needed.
///
/// Rules:
///  • A tag starts with `#` followed by one or more word characters [a-zA-Z0-9_-].
///  • Tags are case-insensitive and stored lowercase.
///  • Tags live anywhere in the body (not the title line).
///  • Duplicate tags in the same file are collapsed to one.
class TagService {
  // Matches #word, #multi-word, #snake_case — not #123 (pure numbers)
  static final RegExp _tagRegex = RegExp(r'#([a-zA-Z][a-zA-Z0-9_\-]*)');

  /// Extracts all unique lowercase tags from [content].
  /// [content] is the full file text (title line + body).
  static List<String> parseTags(String content) {
    final matches = _tagRegex.allMatches(content);
    final tags = matches
        .map((m) => m.group(1)!.toLowerCase())
        .toSet() // deduplicate
        .toList();
    tags.sort();
    return tags;
  }

  /// Returns [content] with [tag] appended to the body (new line at end).
  /// Does nothing if the tag already exists.
  static String addTag(String content, String tag) {
    final normalised = _normalise(tag);
    if (normalised.isEmpty) return content;
    if (hasTag(content, normalised)) return content;
    // Append on its own line so it doesn't run into body text
    final trimmed = content.trimRight();
    return '$trimmed\n#$normalised';
  }

  /// Returns [content] with every occurrence of [tag] removed.
  static String removeTag(String content, String tag) {
    final normalised = _normalise(tag);
    if (normalised.isEmpty) return content;
    // Remove the token including any leading space / newline padding
    return content
        .replaceAll(RegExp(r'\s*#' + RegExp.escape(normalised) + r'\b'), '')
        .trimRight();
  }

  /// Whether [content] contains [tag].
  static bool hasTag(String content, String tag) {
    final normalised = _normalise(tag);
    return RegExp(
      r'#' + RegExp.escape(normalised) + r'\b',
      caseSensitive: false,
    ).hasMatch(content);
  }

  /// Builds a map of tag → list-of-file-paths from a map of
  /// file-path → file-content. Used by the Tags view.
  static Map<String, List<String>> buildTagGroups(
    Map<String, String> fileContents,
  ) {
    final Map<String, List<String>> groups = {};
    for (final entry in fileContents.entries) {
      for (final tag in parseTags(entry.value)) {
        groups.putIfAbsent(tag, () => []).add(entry.key);
      }
    }
    // Sort group keys alphabetically
    final sorted = Map.fromEntries(
      groups.entries.toList()..sort((a, b) => a.key.compareTo(b.key)),
    );
    return sorted;
  }

  static String _normalise(String tag) =>
      tag.replaceAll('#', '').toLowerCase().trim();
}
