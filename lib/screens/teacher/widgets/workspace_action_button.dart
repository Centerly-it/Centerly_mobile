import 'package:flutter/material.dart';
import '../../../core/theme/color_manager.dart';
import '../../../core/theme/values_manager.dart';

/// Shared home-header treatment for student and notification actions.
class WorkspaceActionButton extends StatelessWidget {
  const WorkspaceActionButton({
    required this.icon,
    required this.tooltip,
    required this.onPressed,
    this.boxed = false,
    super.key,
  });
  final Widget icon;
  final String tooltip;
  final VoidCallback onPressed;
  final bool boxed;

  @override
  Widget build(BuildContext context) => IconButton(
    tooltip: tooltip,
    icon: icon,
    style: boxed
        ? IconButton.styleFrom(
            backgroundColor: ColorManager.white,
            foregroundColor: ColorManager.primary,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppRadius.r8),
            ),
          )
        : null,
    onPressed: onPressed,
  );
}
