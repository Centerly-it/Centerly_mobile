import '../../../../core/theme/color_manager.dart';
import 'package:flutter/material.dart';

enum SessionCalendarStatus { ended, available, cancelled }

/// Shared pastel markers keep the calendar and its legend consistent.
class SessionCalendarDot extends StatelessWidget {
  const SessionCalendarDot({required this.status, super.key});
  final SessionCalendarStatus status;

  @override
  Widget build(BuildContext context) => Container(
    width: 6,
    height: 6,
    decoration: BoxDecoration(
      shape: BoxShape.circle,
      color: switch (status) {
        SessionCalendarStatus.ended => ColorManager.calendarEnded,
        SessionCalendarStatus.available => ColorManager.calendarAvailable,
        SessionCalendarStatus.cancelled => ColorManager.calendarCancelled,
      },
    ),
  );
}
