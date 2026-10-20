import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import '../../../../core/theme/style_manager.dart';
import '../../../../core/theme/values_manager.dart';
import 'session_calendar_day.dart';
import 'session_calendar_legend.dart';

class SessionCalendar extends StatelessWidget {
  const SessionCalendar({
    required this.date,
    required this.month,
    required this.onDate,
    required this.hasSessions,
    super.key,
  });
  final DateTime date;
  final bool month;
  final ValueChanged<DateTime> onDate;
  final bool Function(DateTime) hasSessions;
  @override
  Widget build(BuildContext context) {
    final from = month
        ? DateTime(date.year, date.month)
        : date.subtract(Duration(days: date.weekday % 7));
    final start = month
        ? from.subtract(Duration(days: from.weekday % 7))
        : from;
    final count = month
        ? ((DateTime(date.year, date.month + 1, 0).day +
                      from.weekday % 7 +
                      6) ~/
                  7) *
              7
        : 7;
    final scale = MediaQuery.textScalerOf(context).scale(12) / 12;
    return Column(
      children: [
        if (month)
          Row(
            children: [
              for (var i = 0; i < 7; i++)
                Expanded(
                  child: Text(
                    DateFormat.E(
                      context.locale.toString(),
                    ).format(DateTime(2026, 1, 4 + i)),
                    textAlign: TextAlign.center,
                    style: AppTextStyles.caption,
                  ),
                ),
            ],
          ),
        const SizedBox(height: AppSize.s8),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: count,
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 7,
            childAspectRatio: month ? 1.55 / scale : 0.9 / scale,
            crossAxisSpacing: month ? 0 : AppSize.s4,
            mainAxisSpacing: AppSize.s4,
          ),
          itemBuilder: (context, i) {
            final day = start.add(Duration(days: i));
            return SessionCalendarDay(
              day: day,
              date: date,
              month: month,
              onDate: onDate,
              hasSessions: hasSessions(day),
            );
          },
        ),
        if (month) const SessionCalendarLegend(),
      ],
    );
  }
}
