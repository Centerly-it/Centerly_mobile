/// Exact decimal display boundary. No binary floating point for ledger amounts.
class MoneyEgp {
  MoneyEgp._(this.decimal, this.minorUnits);
  final String decimal;
  final BigInt minorUnits;
  factory MoneyEgp.parse(dynamic input) {
    if (input is! String || !RegExp(r'^-?\d{1,18}\.\d{2}$').hasMatch(input)) {
      throw const FormatException('Expected decimal money string');
    }
    return MoneyEgp._(input, BigInt.parse(input.replaceAll('.', '')));
  }
}
