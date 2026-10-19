class StudentMembership {
  const StudentMembership({
    required this.id,
    required this.groupId,
    required this.groupName,
    required this.subject,
    required this.grade,
    required this.status,
    required this.joinedAt,
    this.leftAt,
    this.archivedAt,
  });
  final String id, groupId, groupName, subject, grade, status;
  final DateTime joinedAt;
  final DateTime? leftAt, archivedAt;
  factory StudentMembership.fromJson(Map<String, dynamic> j) {
    final status = j['status'] as String;
    if (!['active', 'inactive'].contains(status)) {
      throw const FormatException('Invalid membership');
    }
    return StudentMembership(
      id: j['id'] as String,
      groupId: j['group_id'] as String,
      groupName: j['group_name'] as String,
      subject: j['subject_name'] as String,
      grade: j['grade_name'] as String,
      status: status,
      joinedAt: DateTime.parse(j['joined_at'] as String),
      leftAt: j['left_at'] == null
          ? null
          : DateTime.parse(j['left_at'] as String),
      archivedAt: j['group_archived_at'] == null
          ? null
          : DateTime.parse(j['group_archived_at'] as String),
    );
  }
}
