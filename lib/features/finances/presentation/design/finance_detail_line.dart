import 'package:flutter/material.dart';
import '../../../../core/widgets/app_info_row.dart';

class FinanceDetailLine extends StatelessWidget {
  const FinanceDetailLine(this.label, this.value, {this.valueStyle, super.key});
  final String label, value;
  final TextStyle? valueStyle;
  @override
  Widget build(BuildContext context) => AppInfoRow(
    label: label,
    value: value,
    valueStyle: valueStyle,
    selectable: true,
  );
}
