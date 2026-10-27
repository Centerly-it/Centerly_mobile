import 'dart:ui' as ui;
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import '../../../../core/theme/color_manager.dart';
import '../../../../core/theme/style_manager.dart';
import '../../../../core/theme/values_manager.dart';
import '../../../../core/config/preview_mode.dart';
import '../../../../core/di/di.dart';
import '../../../auth/presentation/view_models/auth_session_cubit.dart';
import 'finance_design.dart';

class FinanceCreditCardContent extends StatelessWidget {
  const FinanceCreditCardContent({
    required this.amount,
    required this.month,
    super.key,
  });
  final BigInt amount;
  final DateTime month;
  String get _teacherName {
    final name = getIt.isRegistered<AuthSessionCubit>()
        ? getIt<AuthSessionCubit>().state.profile?.displayName
        : null;
    return name ??
        (PreviewMode.enabled
                ? 'home_preview_teacher_name'
                : 'home_teacher_name_fallback')
            .tr();
  }

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.all(AppPadding.p24),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          textDirection: ui.TextDirection.rtl,
          children: [
            Expanded(
              child: Text(
                _teacherName,
                textAlign: TextAlign.right,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: AppTextStyles.titleMedium.copyWith(
                  color: ColorManager.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(width: AppSize.s12),
            Transform.translate(
              offset: const Offset(-AppSize.s8, 0),
              child: Text(
                'app_name'.tr(),
                style: AppTextStyles.titleMedium.copyWith(
                  color: ColorManager.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: AppSize.s24),
        Text(
          'finance_period_net'.tr(),
          style: AppTextStyles.caption.copyWith(
            color: ColorManager.white.withAlpha(210),
          ),
        ),
        const SizedBox(height: AppSize.s4),
        FinanceMoney(
          amount,
          style: AppTextStyles.displayLarge.copyWith(
            color: ColorManager.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: AppSize.s20),
        Row(
          children: [
            DecoratedBox(
              decoration: BoxDecoration(
                color: ColorManager.white.withAlpha(18),
                borderRadius: BorderRadius.circular(AppRadius.r8),
                border: Border.all(color: ColorManager.white.withAlpha(36)),
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppPadding.p12,
                  vertical: AppPadding.p8,
                ),
                child: Text(
                  DateFormat.yMMM(context.locale.toString()).format(month),
                  style: AppTextStyles.caption.copyWith(
                    color: ColorManager.white,
                  ),
                ),
              ),
            ),
            const Spacer(),
            const ExcludeSemantics(
              child: Icon(
                Icons.contactless_outlined,
                color: ColorManager.white,
                size: AppSize.s28,
              ),
            ),
          ],
        ),
      ],
    ),
  );
}
