import 'package:flutter/material.dart';
import '../theme/color_manager.dart';
import '../theme/style_manager.dart';
import '../theme/values_manager.dart';

/// Label/value alignment shared by read-only operational details.
class AppInfoRow extends StatelessWidget {
  const AppInfoRow({
    required this.label,
    required this.value,
    this.icon,
    this.valueStyle,
    this.selectable = false,
    super.key,
  });
  final String label, value;
  final IconData? icon;
  final TextStyle? valueStyle;
  final bool selectable;
  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.symmetric(vertical: AppPadding.p8),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (icon != null) ...[
          ExcludeSemantics(
            child: Icon(
              icon,
              size: AppSize.s18,
              color: ColorManager.textSecondary,
            ),
          ),
          const SizedBox(width: AppSize.s8),
        ],
        Expanded(flex: 4, child: Text(label, style: AppTextStyles.caption)),
        const SizedBox(width: AppSize.s12),
        Expanded(
          flex: 6,
          child: selectable
              ? SelectableText(
                  value,
                  textAlign: TextAlign.end,
                  style: valueStyle ?? AppTextStyles.bodyMedium,
                )
              : Text(
                  value,
                  textAlign: TextAlign.end,
                  style: valueStyle ?? AppTextStyles.bodyMedium,
                ),
        ),
      ],
    ),
  );
}
