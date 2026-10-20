import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import '../../../../core/format/cairo_time.dart';
import '../../../../core/theme/color_manager.dart';
import '../../../../core/theme/style_manager.dart';
import '../../../../core/theme/values_manager.dart';
import '../../preview/group_preview_data.dart';
import 'group_design.dart';

class GroupDesignCard extends StatelessWidget {
  const GroupDesignCard({required this.data, required this.onTap, super.key});
  final GroupPreviewData data;
  final VoidCallback onTap;
  @override
  Widget build(BuildContext context) {
    final next = DateTime.utc(2026, 5, data.id == 2 ? 26 : 25, data.hour - 3);
    return Semantics(
      button: true,
      child: GroupPanel(
        padding: 0,
        child: Material(
          color: Colors.transparent,
          borderRadius: BorderRadius.circular(AppRadius.r12),
          clipBehavior: Clip.antiAlias,
          child: InkWell(
            onTap: onTap,
            child: Padding(
              padding: const EdgeInsets.all(AppPadding.p16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    data.name,
                    style: AppTextStyles.titleMedium.copyWith(
                      fontWeight: FontWeight.bold,
                      height: 1.5,
                    ),
                  ),
                  const SizedBox(height: AppSize.s12),
                  GroupIconLabel(asset: 'b1b35.svg', label: data.days),
                  const SizedBox(height: AppSize.s8),
                  GroupIconLabel(
                    asset: '263e2.svg',
                    label: 'group_design_count'.tr(args: ['${data.students}']),
                  ),
                  const SizedBox(height: AppSize.s12),
                  Container(
                    padding: const EdgeInsets.all(AppPadding.p12),
                    decoration: BoxDecoration(
                      color: ColorManager.grey200,
                      borderRadius: BorderRadius.circular(AppRadius.r8),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Text(
                          'group_design_next'.tr(),
                          style: AppTextStyles.caption.copyWith(
                            color: ColorManager.primaryDark,
                          ),
                        ),
                        const SizedBox(height: AppSize.s12),
                        Wrap(
                          alignment: WrapAlignment.spaceBetween,
                          spacing: AppSize.s8,
                          runSpacing: AppSize.s8,
                          children: [
                            GroupIconLabel(
                              asset: 'a02c2.svg',
                              label: DateFormat.MMMMEEEEd(
                                context.locale.toString(),
                              ).format(CairoTime.local(next)),
                            ),
                            GroupIconLabel(
                              asset: '0122d.svg',
                              label: CairoTime.time(
                                next,
                                context.locale.toString(),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
