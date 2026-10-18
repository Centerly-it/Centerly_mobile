class StudentRecord {
  const StudentRecord({
    required this.id,
    required this.fullName,
    required this.createdAt,
    this.phone,
    this.guardianPhone,
    this.levelTag,
  });
  final String id, fullName;
  final String? phone, guardianPhone, levelTag;
  final DateTime createdAt;
  factory StudentRecord.fromJson(Map<String, dynamic> json) {
    final id = json['id'],
        name = json['full_name'],
        created = json['created_at'];
    if (id is! String ||
        name is! String ||
        name.trim().isEmpty ||
        created is! String) {
      throw const FormatException('Invalid student record');
    }
    return StudentRecord(
      id: id,
      fullName: name,
      createdAt: DateTime.parse(created).toUtc(),
      phone: json['phone'] as String?,
      guardianPhone: json['guardian_phone'] as String?,
      levelTag: json['level_tag'] as String?,
    );
  }
}

class StudentPage {
  const StudentPage(this.students, this.nextCursor);
  final List<StudentRecord> students;
  final String? nextCursor;
}
