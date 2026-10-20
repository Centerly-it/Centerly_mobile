import 'dart:math' as math;
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import '../session_date_controls.dart';
import 'session_design.dart';
import 'session_date_button.dart';

class SessionPeriodNavigation extends StatelessWidget {
  const SessionPeriodNavigation({
    required this.date,
    required this.period,
    required this.onDate,
    super.key,
  });
  final DateTime date;
  final SessionPeriod period;
  final ValueChanged<DateTime> onDate;
  void _move(int direction) {
    if (period == SessionPeriod.month) {
      onDate(DateTime(date.year, date.month + direction));
    } else {
      onDate(
        date.add(
          Duration(days: direction * (period == SessionPeriod.week ? 7 : 1)),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final locale = context.locale.toString();
    final (from, to) = sessionRange(date, period);
    final title = period == SessionPeriod.month
        ? DateFormat.yMMMM(locale).format(date)
        : period == SessionPeriod.week
        ? '${DateFormat.MMMd(locale).format(from)} – ${DateFormat.MMMMd(locale).format(to)}'
        : DateFormat.yMMMMEEEEd(locale).format(date);
    if (period == SessionPeriod.day) {
      return Align(
        alignment: AlignmentDirectional.centerStart,
        child: SessionDateButton(
          date: date,
          title: title,
          onDate: onDate,
          icon: true,
        ),
      );
    }
    return Row(
      children: [
        if (period != SessionPeriod.day)
          IconButton(
            tooltip: 'design_previous'.tr(),
            onPressed: () => _move(-1),
            icon: Transform.rotate(
              angle: context.locale.languageCode == 'ar'
                  ? 3 * math.pi / 4
                  : -math.pi / 4,
              child: const SessionAsset('2e3cf.svg'),
            ),
          ),
        Expanded(
          child: SessionDateButton(date: date, title: title, onDate: onDate),
        ),
        if (period != SessionPeriod.day)
          IconButton(
            tooltip: 'design_next'.tr(),
            onPressed: () => _move(1),
            icon: Transform.rotate(
              angle: context.locale.languageCode == 'ar'
                  ? -math.pi / 4
                  : 3 * math.pi / 4,
              child: const SessionAsset('55a94.svg'),
            ),
          ),
      ],
    );
  }
}
