class ReadPage<T, S> {
  const ReadPage({
    required this.rows,
    required this.summary,
    required this.total,
    required this.syncedAt,
    this.cursor,
  });
  final List<T> rows;
  final S summary;
  final int total;
  final DateTime syncedAt;
  final String? cursor;
}

class NoSummary {
  const NoSummary();
}

int readCount(dynamic value) {
  if (value is! int || value < 0) throw const FormatException('Invalid count');
  return value;
}

Map<String, dynamic> readMap(dynamic value) =>
    Map<String, dynamic>.from(value as Map);
