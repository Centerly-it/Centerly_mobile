import 'package:centrally/core/res/color_manager.dart';
import 'package:centrally/core/res/icons_manager.dart';
import 'package:centrally/core/res/strings_manager.dart';
import 'package:centrally/core/res/style_manager.dart';
import 'package:centrally/features/auth/presentation/widgets/labeled_icon.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

class FeaturesCard extends StatelessWidget {
  const FeaturesCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadiusGeometry.circular(10),
        side: const BorderSide(color: ColorManager.grey300, width: 0.5),
      ),
      margin: EdgeInsets.zero,
      elevation: 0,
      color: ColorManager.grey200,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              StringsManager.youCanNow.tr(),
              style: AppTextStyles.bodyMedium,
            ),
            LabeledIcon(
              icon: IconsManager.peopleIcon,
              label: StringsManager.addStudentsAndTeachers.tr(),
            ),
            LabeledIcon(
              icon: IconsManager.calendarIcon,
              label: StringsManager.trackAttendance.tr(),
            ),
            LabeledIcon(
              icon: IconsManager.noteIcon,
              label: StringsManager.trackPaymentsAndReports.tr(),
            ),
          ],
        ),
      ),
    );
  }
}
