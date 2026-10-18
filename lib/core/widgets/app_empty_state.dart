import 'package:centrally/core/theme/color_manager.dart';
import 'package:centrally/core/theme/style_manager.dart';
import 'package:centrally/core/theme/values_manager.dart';
import 'package:flutter/material.dart';

/// Enhanced empty state widget — reusable across all screens.
/// Supports an optional action button and configurable icon.
class AppEmptyState extends StatelessWidget {
  const AppEmptyState({
    required this.title,
    required this.subtitle,
    super.key,
    this.icon,
    this.iconColor,
    this.actionLabel,
    this.onAction,
  });

  final String title;
  final String subtitle;
  final IconData? icon;
  final Color? iconColor;
  final String? actionLabel;
  final VoidCallback? onAction;

  @override
  Widget build(BuildContext context) {
    final resolvedColor = iconColor ?? ColorManager.primary;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppPadding.p32),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          CircleAvatar(
            radius: AppSize.s40,
            backgroundColor: resolvedColor.withAlpha(20),
            child: Icon(
              icon ?? Icons.event_busy_outlined,
              color: resolvedColor,
              size: AppSize.s40,
            ),
          ),
          const SizedBox(height: AppSize.s20),
          Text(
            title,
            style: AppTextStyles.headlineSmall,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: AppSize.s8),
          Text(
            subtitle,
            style: AppTextStyles.bodySmall,
            textAlign: TextAlign.center,
          ),
          if (actionLabel != null && onAction != null) ...[
            const SizedBox(height: AppSize.s20),
            FilledButton(onPressed: onAction, child: Text(actionLabel!)),
          ],
        ],
      ),
    );
  }
}
