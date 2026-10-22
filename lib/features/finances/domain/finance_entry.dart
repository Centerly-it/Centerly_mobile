class FinanceInvoice {
  const FinanceInvoice({
    required this.id,
    required this.studentKey,
    required this.groupKey,
    required this.amount,
    required this.dueOn,
    this.createdBy,
    this.voided = false,
    this.localized = true,
  });
  final String id, studentKey, groupKey;
  final BigInt amount;
  final DateTime dueOn;
  final bool voided, localized;
  final String? createdBy;
}

class FinanceMovement {
  const FinanceMovement({
    required this.id,
    required this.invoiceId,
    required this.amount,
    required this.actor,
    required this.at,
    required this.method,
    this.reversalOf,
    this.reasonKey,
  });
  final String id, invoiceId, actor, method;
  final BigInt amount;
  final DateTime at;
  final String? reversalOf, reasonKey;
  bool get reversed => reversalOf != null;
  BigInt get signedAmount => reversed ? -amount : amount;
}
