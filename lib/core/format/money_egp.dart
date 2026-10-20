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

  factory MoneyEgp.parse(dynamic input) {
    if (input is! String || !RegExp(r'^-?\d{1,18}\.\d{2}$').hasMatch(input)) {
      throw const FormatException('Expected decimal money string');
    }
    return MoneyEgp._(input, BigInt.parse(input.replaceAll('.', '')));
  }
}
