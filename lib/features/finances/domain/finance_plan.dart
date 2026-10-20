import '../../../core/format/cairo_time.dart';

/// A local planning scenario, never a payment or a promise of collection.
class FinancePlan {
  const FinancePlan({
    required this.month,
    required this.now,
    required this.net,
    required this.remaining,
    required this.target,
    required this.percent,
  });
  final DateTime month, now;
  final BigInt net, remaining, target;
  final int percent;
  BigInt get possibleAddition =>
      remaining * BigInt.from(percent.clamp(0, 100)) ~/ BigInt.from(100);
  BigInt get gap => target > net ? target - net : BigInt.zero;
  BigInt get beyondCurrentDues =>
      gap > remaining ? gap - remaining : BigInt.zero;
  int get days {
    final today = CairoTime.local(now), key = month.year * 12 + month.month;
    final current = today.year * 12 + today.month;
    final last = DateTime(month.year, month.month + 1, 0).day;
    return key < current
        ? 0
        : key > current
        ? last
        : last - today.day + 1;
  }

  BigInt? get perDay => days == 0
      ? null
      : (gap + BigInt.from(days * 100 - 1)) ~/
            BigInt.from(days * 100) *
            BigInt.from(100);
}
