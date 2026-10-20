import 'package:flutter/material.dart';
import '../../../../core/format/cairo_time.dart';
import '../../../../core/theme/values_manager.dart';
import 'session_calendar_dot.dart';

class SessionCalendarMarkers extends StatelessWidget {
  const SessionCalendarMarkers({
    required this.day,
    required this.hasSessions,
    required this.hasCancelledSessions,
    super.key,
  });
  final DateTime day;
  final bool hasSessions, hasCancelledSessions;
  @override
  Widget build(BuildContext context) => Row(
    mainAxisAlignment: MainAxisAlignment.center,
    children: [
      if (hasSessions)
        SessionCalendarDot(
          status:
              DateUtils.dateOnly(
                day,
              ).isBefore(DateUtils.dateOnly(CairoTime.local(DateTime.now())))
              ? SessionCalendarStatus.ended
              : SessionCalendarStatus.available,
        ),
      if (hasSessions && hasCancelledSessions)
        const SizedBox(width: AppSize.s4),
      if (hasCancelledSessions)
        const SessionCalendarDot(status: SessionCalendarStatus.cancelled),
    ],
  );
}
