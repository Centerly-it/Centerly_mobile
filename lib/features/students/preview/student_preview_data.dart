import 'package:easy_localization/easy_localization.dart';
import '../../../core/format/money_egp.dart';
import 'student_preview_invoice.dart';

/// Synthetic design data. No server IDs or hosted writes are used here.
class StudentPreviewData {
  StudentPreviewData({
    required this.id,
    required this.paid,
    required this.level,
    this.group = 'b',
    this.customName,
  });
  final int id;
  final int present = 24, totalSessions = 30;
  int get absent => totalSessions - present;
  int get attendancePercent =>
      totalSessions == 0 ? 0 : present * 100 ~/ totalSessions;
  List<StudentPreviewInvoice> get invoices => [
    StudentPreviewInvoice(
      number: '4526',
      amountEgp: '900.00',
      paidEgp: '900.00',
      dueOn: DateTime(2026, 5, 10),
    ),
    StudentPreviewInvoice(
      number: '4527',
      amountEgp: '1000.00',
      paidEgp: paid ? '1000.00' : '400.00',
      dueOn: DateTime(2026, 5, 12),
    ),
  ];
  String get expectedEgp => MoneyEgp.fromMinorUnits(
    invoices.fold(
      BigInt.zero,
      (sum, i) => sum + MoneyEgp.parse(i.amountEgp).minorUnits,
    ),
  ).decimal;
  String get collectedEgp => MoneyEgp.fromMinorUnits(
    invoices.fold(
      BigInt.zero,
      (sum, i) => sum + MoneyEgp.parse(i.paidEgp).minorUnits,
    ),
  ).decimal;
  String get remainingEgp => MoneyEgp.fromMinorUnits(
    MoneyEgp.parse(expectedEgp).minorUnits -
        MoneyEgp.parse(collectedEgp).minorUnits,
  ).decimal;
  final bool paid;
  final String level, group;
  final String? customName;
  String get name => customName ?? 'student_design_name'.tr();
  String get groupName => 'student_design_group_$group'.tr();
  String? editedNote;
  DateTime noteDate = DateTime(2026, 5, 12);
  String get note => editedNote ?? 'student_design_sample_note'.tr();
  static List<StudentPreviewData> fixtures() => [
    for (var i = 0; i < 6; i++)
      StudentPreviewData(
        id: i + 1,
        paid: [false, true, true, false, false, true][i],
        level: ['excellent', 'good', 'average', 'weak'][i % 4],
        group: i == 2 ? 'a' : 'b',
      ),
  ];
}
