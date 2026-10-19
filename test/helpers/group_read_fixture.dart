Map<String, dynamic> groupJson(String id) => {
  'id': id,
  'name': 'مجموعة $id',
  'subject_name': 'الرياضيات',
  'grade_level_id': 'grade',
  'grade_name': 'الصف الأول الثانوي',
  'capacity': 30,
  'students_count': 1,
  'schedules_truncated': false,
  'roster_preview': [
    {'id': 'student', 'full_name': 'طالب تجريبي'},
  ],
  'schedules': [
    {
      'weekday': 0,
      'local_start_time': '23:00:00',
      'local_end_time': '01:00:00',
      'effective_from': '2026-01-01',
      'effective_to': null,
    },
  ],
};
