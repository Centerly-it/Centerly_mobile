import 'package:flutter/material.dart';
import '../theme/color_manager.dart';
import '../theme/style_manager.dart';
import '../theme/values_manager.dart';
import 'app_surface_panel.dart';

class AppSurfaceSection extends StatelessWidget {
  const AppSurfaceSection({
    required this.title,
    required this.icon,
    required this.child,
    this.headerSpacing = AppSize.s12,
    super.key,
  });
  final String title;
  final Widget icon, child;
  final double headerSpacing;
  @override
  Widget build(BuildContext context) => AppSurfacePanel(
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            Container(
              padding: const EdgeInsets.all(AppPadding.p8),
              decoration: const BoxDecoration(
                color: ColorManager.primaryBright,
                shape: BoxShape.circle,
              ),
              child: icon,
            ),
            const SizedBox(width: AppSize.s12),
            Expanded(child: Text(title, style: AppTextStyles.bodySemiBold)),
          ],
        ),
        SizedBox(height: headerSpacing),
        child,
      ],
    ),
  );
}
