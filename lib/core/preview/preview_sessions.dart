import '../format/cairo_time.dart';

class PreviewSessions {
  final cancelled = <String, String>{};
  List<Map<String, dynamic>> list(String date) {
    final day = DateTime.parse(date);
    final offset = CairoTime.local(
      DateTime.utc(day.year, day.month, day.day, 12),
    ).timeZoneOffset;
    return List.generate(3, (i) {
      final id =
          '50000000-0000-0000-0000-${(i + 1).toString().padLeft(12, '0')}';
      final start = DateTime.utc(
        day.year,
        day.month,
        day.day,
        14 + i * 2,
      ).subtract(offset);
      return {
        'id': id,
        'group_id': '40000000-0000-0000-0000-000000000001',
        'group_name': 'مجموعة التفوق',
        'subject_name': 'رياضيات',
        'local_date': date,
        'starts_at': start.toIso8601String(),
        'ends_at': start.add(const Duration(minutes: 90)).toIso8601String(),
        'status': cancelled.containsKey(id) ? 'cancelled' : 'upcoming',
        'cancel_reason': cancelled[id],
        'attendance_finalized_at': null,
      };
    });
  }

  dynamic cancel(Map<String, dynamic> p) {
    cancelled[p['p_session_id'] as String] = p['p_reason'] as String;
    return null;
  }

  Map<String, dynamic> detail(Map<String, dynamic> p, List students) {
    final now = DateTime.now().toUtc().toIso8601String();
    final date = CairoTime.date(CairoTime.local(DateTime.now()));
    final session = list(
      date,
    ).firstWhere((s) => s['id'] == p['p_id'], orElse: () => list(date).first);
    final rows = List.generate(
      students.length,
      (i) => {
        'id': students[i]['id'],
        'student_id': students[i]['id'],
        'full_name': students[i]['full_name'],
        'status': ['present', 'absent', 'excused', 'present'][i % 4],
        'updated_at': now,
        'marked_at': now,
        'marked_by_name': 'سارة أحمد',
      },
    );
    final filtered = rows
        .where((r) => p['p_status'] == null || r['status'] == p['p_status'])
        .toList();
    return {
      'session': session,
      'attendance': filtered,
      'filtered_count': filtered.length,
      'attendance_counts': {
        'present': 2,
        'absent': 1,
        'excused': 1,
        'not_marked': 0,
      },
      'synced_at': now,
      'next_cursor': null,
    };
  }
}
