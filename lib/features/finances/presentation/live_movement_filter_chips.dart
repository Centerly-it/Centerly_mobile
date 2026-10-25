import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import '../../../core/theme/color_manager.dart';
import '../../../core/theme/style_manager.dart';
import '../../../core/theme/values_manager.dart';

class LiveMovementFilterChips extends StatelessWidget {
  const LiveMovementFilterChips({
    required this.method,
    required this.onMethod,
    super.key,
  });
  final String? method;
  final ValueChanged<String?> onMethod;
  static const methods = ['all', 'cash', 'transfer', 'other'];
  String label(String value) =>
      value == 'all' ? 'detail_all'.tr() : 'completion_method_$value'.tr();
  IconData icon(String value) => switch (value) {
    'cash' => Icons.payments_outlined,
    'transfer' => Icons.account_balance_outlined,
    'other' => Icons.more_horiz_rounded,
    _ => Icons.receipt_long_outlined,
  };
  @override
  Widget build(BuildContext context) => PopupMenuButton<String>(
    tooltip: label(method ?? 'all'),
    initialValue: method ?? 'all',
    onSelected: (v) => onMethod(v == 'all' ? null : v),
    position: PopupMenuPosition.under,
    color: ColorManager.surface,
    surfaceTintColor: ColorManager.surface,
    elevation: 4,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(AppRadius.r16),
      side: const BorderSide(color: ColorManager.stroke),
    ),
    itemBuilder: (_) => [
      for (final value in methods)
        PopupMenuItem(
          value: value,
          child: Row(
            children: [
              Icon(icon(value), color: ColorManager.primary, size: AppSize.s20),
              const SizedBox(width: AppSize.s12),
              Expanded(
                child: Text(label(value), style: AppTextStyles.bodyMedium),
              ),
              if (value == (method ?? 'all'))
                const Icon(Icons.check_rounded, color: ColorManager.primary),
            ],
          ),
        ),
    ],
    child: Container(
      constraints: const BoxConstraints(minHeight: AppSize.s48),
      padding: const EdgeInsets.symmetric(horizontal: AppPadding.p16),
      decoration: BoxDecoration(
        color: ColorManager.primarySoft,
        borderRadius: BorderRadius.circular(AppRadius.r12),
        border: Border.all(color: ColorManager.stroke),
      ),
      child: Row(
        children: [
          Icon(
            icon(method ?? 'all'),
            color: ColorManager.primary,
            size: AppSize.s20,
          ),
          const SizedBox(width: AppSize.s12),
          Expanded(
            child: Text(
              label(method ?? 'all'),
              style: AppTextStyles.bodyMedium,
            ),
          ),
          const Icon(
            Icons.keyboard_arrow_down_rounded,
            color: ColorManager.primary,
          ),
        ],
      ),
    ),
  );
}
