import '../../../core/data/read_page.dart';

class AcademicRecord {
  const AcademicRecord({
    required this.id,
    required this.title,
    required this.date,
    required this.updatedAt,
    this.score,
    this.status,
    this.group,
    this.actor,
  });
  final String id, title, date;
  final String? score, status, group, actor;
  final DateTime updatedAt;
  factory AcademicRecord.fromJson(Map<String, dynamic> j) {
    final score = j['score_percent'] as String?,
        status = j['status'] as String?;
    if (score != null &&
        (!RegExp(r'^\d{1,3}\.\d{2}$').hasMatch(score) ||
            double.parse(score) > 100)) {
      throw const FormatException('Invalid score');
    }
    if (status != null && !['pending', 'submitted', 'late'].contains(status)) {
      throw const FormatException('Invalid assignment');
    }
    return AcademicRecord(
      id: j['id'] as String,
      title: j['title'] as String,
      date: j['date'] as String,
      updatedAt: DateTime.parse(j['updated_at'] as String),
      score: score,
      status: status,
      group: j['group_name'] as String?,
      actor: j['entered_by_name'] as String?,
    );
  }
}

class AcademicSummary {
  AcademicSummary(this.values, this.average);
  final Map<String, int> values;
  final String? average;
  factory AcademicSummary.fromJson(Map<String, dynamic> j) => AcademicSummary(
    Map.unmodifiable({
      for (final key in [
        'scored',
        'missing',
        'below_50',
        'from_50_to_64',
        'from_65_to_79',
        'from_80_to_100',
        'pending',
        'submitted',
        'late',
      ])
        if (j.containsKey(key)) key: readCount(j[key]),
    }),
    j['average_percent'] as String?,
  );
}
