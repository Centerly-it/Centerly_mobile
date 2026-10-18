class TeacherProfile {
  const TeacherProfile({required this.id, required this.teacherId});
  final String id, teacherId;
  factory TeacherProfile.fromJson(Map<String, dynamic> json, String authId) {
    final id = json['id'], tenant = json['teacher_id'];
    final uuid = RegExp(
      r'^[0-9a-fA-F]{8}-(?:[0-9a-fA-F]{4}-){3}[0-9a-fA-F]{12}$',
    );
    if (json['role'] != 'teacher') {
      throw const TeacherAuthFailure('FORBIDDEN_ROLE');
    }
    if (id is! String ||
        tenant is! String ||
        id != authId ||
        tenant != id ||
        !uuid.hasMatch(id)) {
      throw const TeacherAuthFailure('TENANT_SCOPE');
    }
    return TeacherProfile(id: id, teacherId: tenant);
  }
}

class TeacherAuthFailure implements Exception {
  const TeacherAuthFailure(this.code);
  final String code;
  @override
  String toString() => code;
}
