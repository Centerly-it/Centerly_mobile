import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import '../../../../core/format/money_egp.dart';
import '../../../../core/theme/color_manager.dart';
import '../../../../core/theme/style_manager.dart';
import '../../../../core/theme/values_manager.dart';

String financeMoney(BigInt amount, {bool exact = true}) {
  final money = MoneyEgp.fromMinorUnits(amount);
  final digits = exact && amount.remainder(BigInt.from(100)) != BigInt.zero
      ? money.decimal.replaceAllMapped(
          RegExp(r'(\d)(?=(\d{3})+\.)'),
          (m) => '${m[1]},',
        )
      : money.groupedWholePounds;
  final readable = amount.isNegative ? '\u2066$digits\u2069' : digits;
  return '$readable ${'finance_egp'.tr()}';
}

class FinanceMoney extends StatelessWidget {
  const FinanceMoney(this.amount, {this.style, super.key});
  final BigInt amount;
  final TextStyle? style;
  @override
  Widget build(BuildContext context) => Text(
    financeMoney(amount),
    style:
        style ??
        AppTextStyles.titleMedium.copyWith(fontWeight: FontWeight.bold),
  );
}

class FinancePill extends StatelessWidget {
  const FinancePill(this.label, {this.color = ColorManager.primary, super.key});
  final String label;
  final Color color;
  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(
      horizontal: AppPadding.p8,
      vertical: AppPadding.p4,
    ),
    decoration: BoxDecoration(
      color: color.withAlpha(22),
      borderRadius: BorderRadius.circular(AppRadius.r8),
    ),
    child: Text(label, style: AppTextStyles.caption.copyWith(color: color)),
  );
}
