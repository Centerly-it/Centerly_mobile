import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../../../core/theme/color_manager.dart';
import '../../../core/theme/values_manager.dart';

class StudentSearchField extends StatelessWidget {
  const StudentSearchField({required this.onChanged, super.key});
  final ValueChanged<String> onChanged;
  @override
  Widget build(BuildContext context) => TextField(
    onChanged: onChanged,
    decoration: InputDecoration(
      hintText: 'student_design_search'.tr(),
      filled: true,
      fillColor: ColorManager.grey200,
      prefixIcon: Padding(
        padding: const EdgeInsets.all(AppPadding.p16),
        child: SvgPicture.asset('assets/figma/groups/451d4.svg'),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppRadius.r8),
        borderSide: BorderSide.none,
      ),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppRadius.r8),
        borderSide: BorderSide.none,
      ),
    ),
  );
}
