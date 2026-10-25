import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import '../../../core/format/cairo_time.dart';
import '../../../core/theme/values_manager.dart';
import '../../../core/widgets/app_empty_state.dart';
import '../../../models/centerly_models.dart';
import '../domain/session_record.dart';
import 'design/session_calendar.dart';
import 'design/session_design_controls.dart';
import 'session_date_controls.dart';

class SessionCalendarHeader extends StatelessWidget {
  const SessionCalendarHeader({
    required this.date,
    required this.period,
    required this.sessions,
    required this.onDate,
    required this.onPeriod,
    super.key,
  });
  final DateTime date;
  final SessionPeriod period;
  final List<SessionRecord> sessions;
  final ValueChanged<DateTime> onDate;
  final ValueChanged<SessionPeriod> onPeriod;
  @override
  Widget build(BuildContext context) {
    final activeDates = {
      for (final s in sessions)
        if (s.status != SessionStatus.cancelled) s.localDate,
    };
    final cancelledDates = {
      for (final s in sessions)
        if (s.status == SessionStatus.cancelled) s.localDate,
    };
    return Column(
      children: [
        SessionDesignControls(
          date: date,
          period: period,
          onDate: onDate,
          onPeriod: onPeriod,
        ),
        if (period != SessionPeriod.day)
          SessionCalendar(
            date: date,
            month: period == SessionPeriod.month,
            onDate: onDate,
            hasSessions: (d) => activeDates.contains(CairoTime.date(d)),
            hasCancelledSessions: (d) =>
                cancelledDates.contains(CairoTime.date(d)),
          ),
        if (period != SessionPeriod.day) const SizedBox(height: AppSize.s12),
        if (sessions.isEmpty)
          AppEmptyState(
            title: 'sessions_no_sessions_title'.tr(),
            subtitle: 'sessions_no_sessions_subtitle'.tr(),
          ),
      ],
    );
  }
}
