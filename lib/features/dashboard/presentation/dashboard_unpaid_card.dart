import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../../../core/theme/color_manager.dart';
import '../../../core/theme/style_manager.dart';
import '../../../core/theme/values_manager.dart';

class DashboardUnpaidCard extends StatelessWidget {
  const DashboardUnpaidCard({
    required this.count,
    required this.onView,
    super.key,
  });
  final int count;
  final VoidCallback onView;

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(AppPadding.p16),
    decoration: BoxDecoration(
      color: ColorManager.white,
      border: Border.all(color: ColorManager.divider),
      borderRadius: BorderRadius.circular(AppRadius.r12),
    ),
    child: LayoutBuilder(
      builder: (context, constraints) {
        final stacked =
            constraints.maxWidth < 320 ||
            MediaQuery.textScalerOf(context).scale(12) > 16;
        final info = Row(
          children: [
            Container(
              padding: const EdgeInsets.all(AppPadding.p8),
              decoration: BoxDecoration(
                color: ColorManager.errorSurface,
                border: Border.all(color: ColorManager.errorBorder),
                borderRadius: BorderRadius.circular(AppRadius.r12),
              ),
              child: SvgPicture.asset('assets/icons/home_unpaid_students.svg'),
            ),
            const SizedBox(width: AppSize.s8),
            Expanded(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    NumberFormat.decimalPattern(
                      context.locale.toString(),
                    ).format(count),
                    style: AppTextStyles.headlineSmall.copyWith(
                      color: ColorManager.errorText,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text('home_unpaid_month'.tr(), style: AppTextStyles.caption),
                ],
              ),
            ),
          ],
        );
        final button = FilledButton(
          onPressed: onView,
          style: FilledButton.styleFrom(
            minimumSize: const Size(0, 32),
            padding: const EdgeInsets.symmetric(horizontal: AppPadding.p12),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppRadius.r8),
            ),
            textStyle: AppTextStyles.caption.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          child: Text('home_unpaid_view'.tr()),
        );
        return stacked
            ? Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  info,
                  const SizedBox(height: AppSize.s8),
                  Align(
                    alignment: AlignmentDirectional.centerEnd,
                    child: button,
                  ),
                ],
              )
            : Row(
                children: [
                  Expanded(child: info),
                  const SizedBox(width: AppSize.s8),
                  button,
                ],
              );
      },
    ),
  );
}
