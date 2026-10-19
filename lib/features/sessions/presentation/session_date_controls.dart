import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import '../../../core/format/cairo_time.dart';
import '../../../core/theme/values_manager.dart';

enum SessionPeriod { day, week, month }

class SessionDateControls extends StatelessWidget {
  const SessionDateControls({
    required this.date,
    required this.period,
    required this.onDate,
    required this.onPeriod,
    super.key,
  });
  final DateTime date;
  final SessionPeriod period;
  final ValueChanged<DateTime> onDate;
  final ValueChanged<SessionPeriod> onPeriod;
  @override
  Widget build(BuildContext context) => Column(
    children: [
      TextButton.icon(
        icon: const Icon(Icons.calendar_month_outlined),
        label: Text(CairoTime.date(date)),
        onPressed: () async {
          final selected = await showDatePicker(
            context: context,
            initialDate: date,
            firstDate: DateTime(2000),
            lastDate: DateTime(2100),
          );
          if (selected != null && context.mounted) onDate(selected);
        },
      ),
      Wrap(
        children: [
          for (final value in SessionPeriod.values)
            Padding(
              padding: const EdgeInsets.all(AppPadding.p4),
              child: ChoiceChip(
                label: Text('sessions_${value.name}'.tr()),
                selected: period == value,
                onSelected: (_) => onPeriod(value),
              ),
            ),
        ],
      ),
    ],
  );
}

(DateTime, DateTime) sessionRange(DateTime date, SessionPeriod period) {
  final day = DateTime.utc(date.year, date.month, date.day);
  return switch (period) {
    SessionPeriod.day => (day, day),
    SessionPeriod.week => (
      day.subtract(Duration(days: day.weekday % 7)),
      day.add(Duration(days: 6 - day.weekday % 7)),
    ),
    SessionPeriod.month => (
      DateTime.utc(day.year, day.month),
      DateTime.utc(day.year, day.month + 1, 0),
    ),
  };
}
