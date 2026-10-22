import '../../../core/format/money_egp.dart';

Map<String, dynamic> validatedReceipt(Map<String, dynamic> row) {
  for (final key in [
    'id',
    'invoice_id',
    'receipt_number',
    'method',
    'collected_at',
  ]) {
    if (row[key] is! String || (row[key] as String).isEmpty) {
      throw const FormatException('Invalid receipt');
    }
  }
  final amount = MoneyEgp.parse(row['amount_egp']).minorUnits;
  final signed = MoneyEgp.parse(row['signed_amount_egp']).minorUnits;
  if (amount <= BigInt.zero ||
      signed != (row['reversal_of'] == null ? amount : -amount) ||
      !{'cash', 'transfer', 'other'}.contains(row['method'])) {
    throw const FormatException('Invalid receipt amounts');
  }
  DateTime.parse(row['collected_at'] as String);
  return Map.unmodifiable(row);
}
