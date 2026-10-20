import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import '../../../../core/theme/color_manager.dart';
import '../../../../core/theme/style_manager.dart';
import '../../../../core/theme/values_manager.dart';

class StudentProfileTabs extends StatelessWidget {
  const StudentProfileTabs({
    required this.index,
    required this.onChanged,
    super.key,
  });
  final int index;
  final ValueChanged<int> onChanged;
  static const labels = ['info', 'attendance', 'academics', 'payments'];
  @override
  Widget build(BuildContext context) {
    Widget tab(int i) => InkWell(
      onTap: () => onChanged(i),
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: AppPadding.p8,
          vertical: AppPadding.p8,
        ),
        decoration: BoxDecoration(
          border: Border(
            bottom: BorderSide(
              color: index == i ? ColorManager.primaryDark : Colors.transparent,
              width: 1.5,
            ),
          ),
        ),
        child: Text(
          'student_design_${labels[i]}'.tr(),
          textAlign: TextAlign.center,
          maxLines: 1,
          softWrap: false,
          style: AppTextStyles.bodyMedium.copyWith(
            color: index == i
                ? ColorManager.primaryDark
                : ColorManager.textSecondary,
            fontWeight: index == i ? FontWeight.bold : FontWeight.w500,
          ),
        ),
      ),
    );
    return LayoutBuilder(
      builder: (context, constraints) => SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: ConstrainedBox(
          constraints: BoxConstraints(minWidth: constraints.maxWidth),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [for (var i = 0; i < 4; i++) tab(i)],
          ),
        ),
      ),
    );
  }
}
