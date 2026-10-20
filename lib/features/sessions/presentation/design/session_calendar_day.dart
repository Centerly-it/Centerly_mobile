import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import '../../../../core/format/cairo_time.dart';
import '../../../../core/theme/color_manager.dart';
import '../../../../core/theme/style_manager.dart';
import '../../../../core/theme/values_manager.dart';
import 'session_design.dart';

class SessionCalendarDay extends StatelessWidget {
  const SessionCalendarDay({
    required this.day,
    required this.date,
    required this.month,
    required this.onDate,
    required this.hasSessions,
    super.key,
  });
  final DateTime day, date;
  final bool month, hasSessions;
  final ValueChanged<DateTime> onDate;
  @override
  Widget build(BuildContext context) {
    final selected = CairoTime.date(day) == CairoTime.date(date);
    return InkWell(
      key: ValueKey('calendar-${CairoTime.date(day)}'),
      onTap: () => onDate(day),
      borderRadius: BorderRadius.circular(AppRadius.r8),
      child: Container(
        decoration: BoxDecoration(
          color: !month
              ? (selected ? ColorManager.primary : SessionDesign.stroke)
              : null,
          borderRadius: BorderRadius.circular(AppRadius.r8),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (!month)
              Text(
                DateFormat.E(context.locale.toString()).format(day),
                style: AppTextStyles.caption.copyWith(
                  color: selected ? ColorManager.white : SessionDesign.muted,
                ),
              ),
            Container(
              padding: const EdgeInsets.all(AppPadding.p4),
              decoration: selected && month
                  ? const BoxDecoration(
                      color: ColorManager.primary,
                      shape: BoxShape.circle,
                    )
                  : null,
              child: Text(
                '${day.day}',
                style: AppTextStyles.caption.copyWith(
                  color: selected
                      ? ColorManager.white
                      : day.month == date.month
                      ? SessionDesign.text
                      : SessionDesign.muted,
                ),
              ),
            ),
            if (month && hasSessions)
              SessionAsset(
                day.isBefore(DateTime.now().subtract(const Duration(days: 1)))
                    ? '5e17e.svg'
                    : 'cd60c.svg',
              ),
          ],
        ),
      ),
    );
  }
}
