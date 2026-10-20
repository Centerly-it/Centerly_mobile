import 'dart:convert';
import 'teacher_read_endpoint.dart';

/// Balances, attendance and access-sensitive reads always revalidate remotely.
Duration teacherReadTtl(TeacherRead read) => switch (read) {
  TeacherRead.groups || TeacherRead.students => const Duration(seconds: 30),
  TeacherRead.studentProfile ||
  TeacherRead.academics => const Duration(seconds: 15),
  _ => Duration.zero,
};
String teacherReadKey(
  String namespace,
  String? identity,
  TeacherRead read,
  Map<String, dynamic>? params,
) => jsonEncode([
  namespace,
  identity,
  read.name,
  _canonical(params ?? const <String, dynamic>{}),
]);
Object? _canonical(Object? value) {
  if (value is Map<String, dynamic>) {
    final keys = value.keys.toList()..sort();
    return {for (final key in keys) key: _canonical(value[key])};
  }
  if (value is List) return value.map(_canonical).toList();
  return value;
}

Map<String, dynamic>? snapshotReadParams(Map<String, dynamic>? params) =>
    params == null ? null : (_canonical(params) as Map<String, dynamic>);
