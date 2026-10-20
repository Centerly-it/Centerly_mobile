/// Exact decimal display boundary. No binary floating point for ledger amounts.
class MoneyEgp {
  static const arabicCurrencySymbol = 'جـ';
  MoneyEgp._(this.decimal, this.minorUnits);
  final String decimal;
  final BigInt minorUnits;

  /// Display-only rounding to nearest pound; ledger values keep exact piastres.
  String get wholePounds {
    final rounded = (minorUnits.abs() + BigInt.from(50)) ~/ BigInt.from(100);
    return (minorUnits.isNegative && rounded != BigInt.zero
            ? -rounded
            : rounded)
        .toString();
  }

  /// Exact grouped whole pounds for display; no floating point conversion.
  String get groupedWholePounds => wholePounds.replaceAllMapped(
    RegExp(r'(\d)(?=(\d{3})+(?!\d))'),
    (match) => '${match[1]},',
  );

  factory MoneyEgp.fromMinorUnits(BigInt value) {
    final digits = value.abs().toString().padLeft(3, '0');
    final sign = value.isNegative ? '-' : '';
    return MoneyEgp._(
      '$sign${digits.substring(0, digits.length - 2)}.${digits.substring(digits.length - 2)}',
      value,
    );
  }

  factory MoneyEgp.parse(dynamic input) {
    if (input is! String || !RegExp(r'^-?\d{1,18}\.\d{2}$').hasMatch(input)) {
      throw const FormatException('Expected decimal money string');
    }
    return MoneyEgp._(input, BigInt.parse(input.replaceAll('.', '')));
  }
}
