import 'package:flutter/material.dart';
import '../../../../core/theme/color_manager.dart';
import '../../../../core/theme/style_manager.dart';
import '../../../../core/theme/values_manager.dart';
import 'session_design.dart';

class SessionSectionTitle extends StatelessWidget {
  const SessionSectionTitle({required this.title, super.key});
  final String title;
  @override
  Widget build(BuildContext context) => Row(
    children: [
      Container(
        padding: const EdgeInsets.all(AppPadding.p8),
        decoration: const BoxDecoration(
          color: ColorManager.primaryBright,
          shape: BoxShape.circle,
        ),
        child: const SessionAsset('7a373.svg'),
      ),
      const SizedBox(width: AppSize.s12),
      Expanded(child: Text(title, style: AppTextStyles.titleSmall)),
    ],
  );
}
