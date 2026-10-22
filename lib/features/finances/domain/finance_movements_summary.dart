import '../../../core/format/money_egp.dart';

class FinanceMovementsSummary {
  FinanceMovementsSummary(Map<String, dynamic> json, {bool filtered = true})
    : net = MoneyEgp.parse(
        json[filtered ? 'net_egp' : 'period_net_collected_egp'],
      ).minorUnits {
    if (filtered) {
      final gross = MoneyEgp.parse(json['gross_egp']).minorUnits;
      final corrections = MoneyEgp.parse(json['corrections_egp']).minorUnits;
      if (gross < BigInt.zero ||
          corrections < BigInt.zero ||
          gross - corrections != net) {
        throw const FormatException('Unreconciled filtered receipts');
      }
    }
  }
  final BigInt net;
}
