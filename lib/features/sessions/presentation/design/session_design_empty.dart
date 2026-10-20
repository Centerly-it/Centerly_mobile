import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import '../../../../core/theme/style_manager.dart';
import '../../../../core/theme/values_manager.dart';
import 'session_design.dart';

class SessionDesignEmpty extends StatelessWidget {
  const SessionDesignEmpty({super.key});
  @override
  Widget build(BuildContext context) => Column(
    children: [
      SizedBox(
        height: 204,
        child: AspectRatio(
          aspectRatio: 332 / 204,
          child: ClipRect(
            child: OverflowBox(
              alignment: Alignment.bottomCenter,
              maxHeight: 239,
              child: Image.asset(
                '${SessionDesign.assets}92ea1.png',
                fit: BoxFit.contain,
              ),
            ),
          ),
        ),
      ),
      const SizedBox(height: AppSize.s24),
      Text('sessions_empty_title'.tr(), style: AppTextStyles.headlineMedium),
      Text(
        'sessions_empty_subtitle'.tr(),
        textAlign: TextAlign.center,
        style: AppTextStyles.bodyMedium,
      ),
    ],
  );
}

class SessionSearchEmpty extends StatelessWidget {
  const SessionSearchEmpty({super.key});
  @override
  Widget build(BuildContext context) => Column(
    children: [
      AspectRatio(
        aspectRatio: 290 / 216,
        child: Image.asset(
          '${SessionDesign.assets}9578e.png',
          fit: BoxFit.cover,
        ),
      ),
      const SizedBox(height: AppSize.s16),
      Text(
        'design_student_not_found'.tr(),
        textAlign: TextAlign.center,
        style: AppTextStyles.headlineMedium,
      ),
    ],
  );
}
