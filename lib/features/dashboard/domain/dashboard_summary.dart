class DashboardSummary {
  const DashboardSummary({
    required this.students,
    required this.groups,
    required this.collectedEgp,
    required this.outstandingEgp,
    required this.localDate,
  });
  final int students, groups;
  final String collectedEgp, outstandingEgp, localDate;
  factory DashboardSummary.fromJson(Map<String, dynamic> data) {
    final students = data['total_students'], groups = data['total_groups'];
    final date = data['date'];
    String amount(String key) {
      final raw = data[key];
      if (raw is! num && raw is! String) {
        throw const FormatException('Invalid server amount');
      }
      final text = raw.toString();
      if (!RegExp(r'^-?\d+(\.\d{1,2})?$').hasMatch(text)) {
        throw const FormatException('Invalid server amount');
      }
      return text;
    }

    if (students is! int ||
        groups is! int ||
        students < 0 ||
        groups < 0 ||
        date is! String ||
        DateTime.tryParse(date) == null) {
      throw const FormatException('Invalid dashboard summary');
    }
    return DashboardSummary(
      students: students,
      groups: groups,
      localDate: date,
      collectedEgp: amount('collected_egp'),
      outstandingEgp: amount('outstanding_egp'),
    );
  }
}
