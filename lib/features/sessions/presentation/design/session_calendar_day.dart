import 'session_calendar_markers.dart';
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
    this.hasCancelledSessions = false,
    super.key,
  });
  final DateTime day, date;
  final bool month, hasSessions, hasCancelledSessions;
  final ValueChanged<DateTime> onDate;
  @override
  Widget build(BuildContext context) {
    final selected = DateUtils.isSameDay(day, date);
    final today = DateUtils.isSameDay(day, CairoTime.local(DateTime.now()));
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
          border: !month && today
              ? Border.all(color: ColorManager.primary)
              : null,
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (!month)
              Text(
                DateFormat.E(context.locale.toString()).format(day),
                style: AppTextStyles.caption.copyWith(
                  fontWeight: today ? FontWeight.bold : null,
                  color: selected ? ColorManager.white : SessionDesign.muted,
                ),
              ),
            Container(
              key: today ? const ValueKey('calendar-today-marker') : null,
              padding: const EdgeInsets.all(AppPadding.p4),
              decoration: month && (selected || today)
                  ? BoxDecoration(
                      color: selected ? ColorManager.primary : null,
                      shape: BoxShape.circle,
                      border: Border.all(color: ColorManager.primary),
                    )
                  : null,
              child: Text(
                '${day.day}',
                style: AppTextStyles.caption.copyWith(
                  fontWeight: today ? FontWeight.bold : null,
                  color: selected
                      ? ColorManager.white
                      : today
                      ? ColorManager.primary
                      : day.month == date.month
                      ? SessionDesign.text
                      : SessionDesign.muted,
                ),
              ),
            ),
            if (month && (hasSessions || hasCancelledSessions))
              SessionCalendarMarkers(
                day: day,
                hasSessions: hasSessions,
                hasCancelledSessions: hasCancelledSessions,
              ),
          ],
        ),
      ),
    );
  }
}
