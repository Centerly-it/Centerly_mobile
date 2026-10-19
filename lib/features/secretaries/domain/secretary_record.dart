class SecretaryRecord {
  const SecretaryRecord({
    required this.id,
    required this.name,
    required this.email,
    required this.status,
    this.phone,
    this.requestStatus,
    this.requestedAt,
    this.handledAt,
  });
  final String id, name, email, status;
  final String? phone, requestStatus;
  final DateTime? requestedAt, handledAt;
  factory SecretaryRecord.fromJson(Map<String, dynamic> j) {
    final request = j['removal_request'];
    if (!['active', 'inactive'].contains(j['status'])) {
      throw const FormatException('Invalid secretary status');
    }
    return SecretaryRecord(
      id: j['id'] as String,
      name: j['name'] as String,
      email: j['email'] as String,
      status: j['status'] as String,
      phone: j['phone'] as String?,
      requestStatus: request?['status'] as String?,
      requestedAt: request == null
          ? null
          : DateTime.parse(request['requested_at'] as String),
      handledAt: request?['handled_at'] == null
          ? null
          : DateTime.parse(request['handled_at'] as String),
    );
  }
}
