import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import '../../../core/theme/color_manager.dart';
import '../../../core/theme/style_manager.dart';
import '../../../core/theme/values_manager.dart';
import '../domain/session_design_data.dart';
import '../presentation/design/attendance_design_panel.dart';
import '../presentation/design/session_design.dart';
import '../presentation/design/session_info_panel.dart';
import '../presentation/design/session_subpage_bar.dart';

class SessionAttendancePreview extends StatelessWidget {
  const SessionAttendancePreview({required this.data, super.key});
  final SessionDesignData data;
  @override
  Widget build(BuildContext context) => Scaffold(
    backgroundColor: SessionDesign.background,
    appBar: const SessionSubpageBar(
      title: 'design_attendance_sheet',
      readOnly: true,
    ),
    body: SafeArea(
      child: ListView(
        padding: const EdgeInsets.all(AppPadding.p16),
        children: [
          SessionInfoPanel(data: data),
          const SizedBox(height: AppSize.s16),
          AttendanceDesignPanel(students: data.students),
        ],
      ),
    ),
    bottomNavigationBar: SafeArea(
      top: false,
      child: Container(
        padding: const EdgeInsets.all(AppPadding.p16),
        color: ColorManager.grey200,
        child: Container(
          padding: const EdgeInsets.all(AppPadding.p12),
          decoration: BoxDecoration(
            color: SessionDesign.stroke,
            borderRadius: BorderRadius.circular(AppRadius.r12),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const SessionAsset('81250.svg'),
              const SizedBox(width: AppSize.s8),
              Flexible(
                child: Text(
                  'design_secretary_attendance'.tr(),
                  textAlign: TextAlign.center,
                  style: AppTextStyles.bodyMedium,
                ),
              ),
            ],
          ),
        ),
      ),
    ),
  );
}
