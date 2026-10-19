import 'package:centrally/features/dashboard/domain/attendance_counts.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test(
    'pending remains distinct; missing/negative counts are not silently zero',
    () {
      final counts = AttendanceCounts.fromJson({
        'present': 1,
        'absent': 0,
        'excused': 1,
        'not_marked': 2,
      });
      expect(counts.notMarked, 2);
      expect(counts.absent, 0);
      expect(
        () => AttendanceCounts.fromJson({'present': 1}),
        throwsFormatException,
      );
      expect(
        () => AttendanceCounts.fromJson({
          'present': 1,
          'absent': -1,
          'excused': 0,
          'not_marked': 0,
        }),
        throwsFormatException,
      );
    },
  );
}
