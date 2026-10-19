class StudentNote {
  const StudentNote(this.content, this.version);
  final String content;

  /// Preserve server microseconds. Never round timestamps to milliseconds.
  final String? version;
  factory StudentNote.fromJson(Map<String, dynamic> j) {
    final row = j['note'];
    if (row == null) return const StudentNote('', null);
    final content = row['content'] as String,
        version = row['updated_at'] as String;
    DateTime.parse(version);
    return StudentNote(content, version);
  }
}
