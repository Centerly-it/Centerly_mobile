import 'package:flutter/material.dart';
import '../../../../core/theme/color_manager.dart';
import '../../../../core/theme/style_manager.dart';
import '../../../../core/theme/values_manager.dart';

class StudentSummaryValue {
  const StudentSummaryValue(
    this.title,
    this.value, {
    this.unit = '',
    this.color = ColorManager.textPrimary,
  });
  final String title, value, unit;
  final Color color;
}

class StudentSummaryTiles extends StatelessWidget {
  const StudentSummaryTiles({required this.values, super.key});
  final List<StudentSummaryValue> values;
  @override
  Widget build(BuildContext context) => Row(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      for (var i = 0; i < values.length; i++) ...[
        if (i > 0) const SizedBox(width: AppSize.s12),
        Expanded(
          child: Container(
            padding: const EdgeInsets.all(AppPadding.p8),
            constraints: const BoxConstraints(minHeight: 70),
            decoration: BoxDecoration(
              border: Border.all(color: ColorManager.stroke),
              borderRadius: BorderRadius.circular(AppRadius.r8),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(values[i].title, style: AppTextStyles.caption),
                const SizedBox(height: AppSize.s4),
                Text.rich(
                  TextSpan(
                    children: [
                      TextSpan(
                        text: values[i].value,
                        style: AppTextStyles.titleSmall.copyWith(
                          color: values[i].color,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      if (values[i].unit.isNotEmpty)
                        TextSpan(
                          text: ' ${values[i].unit}',
                          style: AppTextStyles.caption.copyWith(fontSize: 10),
                        ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    ],
  );
}
