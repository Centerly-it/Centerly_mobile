import 'package:centrally/features/notifications/domain/notification_record.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  for (final type in [
    'student_added',
    'student_withdrawn',
    'student_removed',
  ]) {
    test(
      'student lifecycle notice has an explicit label and trusted name: $type',
      () {
        final r = NotificationRecord.fromJson({
          'id': 'notice',
          'type': type,
          'created_at': '2026-10-25T10:00:00Z',
          'student_name': 'أحمد حسن',
          'payload': {'student_id': 'student'},
        });
        expect(r.labelKey, 'notification_$type');
        expect(r.studentName, 'أحمد حسن');
        expect(r.paymentId, isNull);
      },
    );
  }
}
