import 'package:centrally/core/theme/color_manager.dart';
import 'package:centrally/core/theme/values_manager.dart';
import 'package:flutter/material.dart';

/// Generic bottom sheet shell that applies Centerly's standard bottom sheet
/// styling (drag handle, rounded top corners, surface background).
///
/// Use [AppBottomSheet.show] to display any [child] in the standard shell.
class AppBottomSheet extends StatelessWidget {
  const AppBottomSheet({
    required this.child,
    super.key,
    this.padding = const EdgeInsets.fromLTRB(
      AppPadding.p16,
      0,
      AppPadding.p16,
      AppPadding.p24,
    ),
  });

  final Widget child;
  final EdgeInsetsGeometry padding;

  /// Show any widget inside the standard Centerly bottom sheet.
  static Future<T?> show<T>({
    required BuildContext context,
    required Widget child,
    bool isScrollControlled = true,
    EdgeInsetsGeometry? padding,
  }) => showModalBottomSheet<T>(
    context: context,
    isScrollControlled: isScrollControlled,
    showDragHandle: true,
    backgroundColor: ColorManager.surface,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(AppRadius.r24)),
    ),
    builder: (_) => AppBottomSheet(
      padding:
          padding ??
          EdgeInsets.only(
            left: AppPadding.p16,
            right: AppPadding.p16,
            bottom: MediaQuery.of(context).viewInsets.bottom + AppPadding.p24,
          ),
      child: child,
    ),
  );

  @override
  Widget build(BuildContext context) {
    return Padding(padding: padding, child: child);
  }
}
