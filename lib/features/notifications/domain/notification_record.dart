class NotificationRecord {
  const NotificationRecord({
    required this.id,
    required this.type,
    required this.createdAt,
    this.readAt,
    this.sessionId,
    this.paymentId,
    this.studentName,
  });
  final String id, type;
  final DateTime createdAt;
  final DateTime? readAt;
  final String? sessionId, paymentId, studentName;
  factory NotificationRecord.fromJson(Map<String, dynamic> j) {
    final session = (j['payload'] as Map?)?['session_id'];
    final payment = (j['payload'] as Map?)?['payment_id'];
    return NotificationRecord(
      id: j['id'] as String,
      studentName: j['student_name'] as String?,
      type: j['type'] as String,
      createdAt: DateTime.parse(j['created_at'] as String),
      readAt: j['read_at'] == null
          ? null
          : DateTime.parse(j['read_at'] as String),
      sessionId:
          session is String && RegExp(r'^[0-9a-fA-F-]{36}$').hasMatch(session)
          ? session
          : null,
      paymentId:
          payment is String && RegExp(r'^[0-9a-fA-F-]{36}$').hasMatch(payment)
          ? payment
          : null,
    );
  }
  String get labelKey => switch (type) {
    'student_added' => 'notification_student_added',
    'student_withdrawn' => 'notification_student_withdrawn',
    'student_removed' => 'notification_student_removed',
    'session_cancelled' => 'completion_event_cancelled',
    'payment_collected' => 'completion_event_payment',
    'payment_reversed' => 'completion_event_reversed',
    'removal_handled' => 'completion_event_removal',
    _ => 'completion_event_admin',
  };
}
