/// Pending stays separate. Nothing in the client converts it to absent.
class AttendanceCounts {
  const AttendanceCounts({
    required this.present,
    required this.absent,
    required this.excused,
    required this.notMarked,
  });
  final int present, absent, excused, notMarked;
  factory AttendanceCounts.fromJson(Map<String, dynamic> json) {
    int count(String key) {
      final value = json[key];
      if (value is! int || value < 0) {
        throw const FormatException('Invalid attendance count');
      }
      return value;
    }

    return AttendanceCounts(
      present: count('present'),
      absent: count('absent'),
      excused: count('excused'),
      notMarked: count('not_marked'),
    );
  }
}
