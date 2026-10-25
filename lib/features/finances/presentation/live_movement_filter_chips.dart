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
  @override
  Widget build(BuildContext context) => Center(
    child: ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 220),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: AppPadding.p12),
        decoration: BoxDecoration(
          color: ColorManager.primarySoft,
          borderRadius: BorderRadius.circular(AppSize.s12),
          border: Border.all(color: ColorManager.stroke),
        ),
        child: DropdownButtonHideUnderline(
          child: DropdownButton<String>(
            alignment: Alignment.center,
            style: AppTextStyles.bodySmall.copyWith(
              color: ColorManager.textPrimary,
            ),
            icon: const Icon(
              Icons.keyboard_arrow_down_rounded,
              color: ColorManager.primary,
              size: 20,
            ),
            isExpanded: true,
            value: method ?? 'all',
            items: [
              for (final v in ['all', 'cash', 'transfer', 'other'])
                DropdownMenuItem(
                  value: v,
                  alignment: Alignment.center,
                  child: Text(
                    v == 'all'
                        ? 'detail_all'.tr()
                        : 'completion_method_$v'.tr(),
                    overflow: TextOverflow.ellipsis,
                    textAlign: TextAlign.center,
                  ),
                ),
            ],
            onChanged: (v) => onMethod(v == 'all' ? null : v),
          ),
        ),
      ),
    ),
  );
}
