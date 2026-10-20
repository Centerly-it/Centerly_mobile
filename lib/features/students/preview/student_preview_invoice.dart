import '../../../core/format/money_egp.dart';

/// Synthetic invoice amounts shared by the profile summary and invoice table.
class StudentPreviewInvoice {
  const StudentPreviewInvoice({
    required this.number,
    required this.amountEgp,
    required this.paidEgp,
    required this.dueOn,
  });
  final String number, amountEgp, paidEgp;
  final DateTime dueOn;
  bool get settled =>
      MoneyEgp.parse(amountEgp).minorUnits ==
      MoneyEgp.parse(paidEgp).minorUnits;
}
