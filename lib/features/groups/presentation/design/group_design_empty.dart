import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import '../../../../core/theme/style_manager.dart';
import '../../../../core/theme/values_manager.dart';

class GroupDesignEmpty extends StatelessWidget {
  const GroupDesignEmpty({super.key});
  @override
  Widget build(BuildContext context) => Center(
    child: SingleChildScrollView(
      padding: const EdgeInsets.all(AppPadding.p24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 310),
            child: Image.asset(
              'assets/figma/groups/3dd9c.png',
              fit: BoxFit.contain,
            ),
          ),
          const SizedBox(height: AppSize.s8),
          Text(
            'group_design_empty'.tr(),
            textAlign: TextAlign.center,
            style: AppTextStyles.headlineMedium,
          ),
          const SizedBox(height: AppSize.s12),
          Text(
            'group_design_empty_hint'.tr(),
            textAlign: TextAlign.center,
            style: AppTextStyles.bodyLarge,
          ),
        ],
      ),
    ),
  );
}
