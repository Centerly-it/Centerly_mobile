import 'package:flutter/material.dart';
import '../theme/color_manager.dart';
import '../theme/values_manager.dart';

class AppSurfacePanel extends StatelessWidget {
  const AppSurfacePanel({
    required this.child,
    this.padding = AppPadding.p12,
    super.key,
  });
  final Widget child;
  final double padding;
  @override
  Widget build(BuildContext context) => Container(
    padding: EdgeInsets.all(padding),
    decoration: BoxDecoration(
      color: ColorManager.surface,
      border: Border.all(color: ColorManager.stroke),
      borderRadius: BorderRadius.circular(AppRadius.r12),
    ),
    child: child,
  );
}
