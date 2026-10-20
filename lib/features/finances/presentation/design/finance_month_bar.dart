import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import '../../../../core/theme/color_manager.dart';
import '../../../../core/theme/style_manager.dart';

class FinanceMonthBar extends StatelessWidget {
  const FinanceMonthBar({
    required this.month,
    required this.onChanged,
    super.key,
  });
  final DateTime month;
  final ValueChanged<DateTime> onChanged;
  Future<void> _pick(BuildContext context) async {
    final date = await showDatePicker(
      context: context,
      initialDate: month,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100, 12, 31),
    );
    if (date != null) onChanged(DateTime(date.year, date.month));
  }

  @override
  Widget build(BuildContext context) => Row(
    children: [
      IconButton(
        tooltip: 'finance_previous_month'.tr(),
        icon: Icon(
          context.locale.languageCode == 'ar'
              ? Icons.chevron_right
              : Icons.chevron_left,
        ),
        onPressed: month.year == 2000 && month.month == 1
            ? null
            : () => onChanged(DateTime(month.year, month.month - 1)),
      ),
      Expanded(
        child: TextButton.icon(
          onPressed: () => _pick(context),
          icon: const Icon(Icons.calendar_month_outlined, size: 20),
          label: Text(
            DateFormat.yMMMM(context.locale.toString()).format(month),
            style: AppTextStyles.titleMedium.copyWith(
              color: ColorManager.primary,
            ),
          ),
        ),
      ),
      IconButton(
        tooltip: 'finance_next_month'.tr(),
        icon: Icon(
          context.locale.languageCode == 'ar'
              ? Icons.chevron_left
              : Icons.chevron_right,
        ),
        onPressed: month.year == 2100 && month.month == 12
            ? null
            : () => onChanged(DateTime(month.year, month.month + 1)),
      ),
    ],
  );
}
