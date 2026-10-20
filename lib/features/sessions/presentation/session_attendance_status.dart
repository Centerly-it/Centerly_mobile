import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import '../../../core/theme/style_manager.dart';
import '../domain/session_record.dart';

class SessionAttendanceStatus extends StatelessWidget {
  const SessionAttendanceStatus({required this.session, super.key});
  final SessionRecord session;
  @override
  Widget build(BuildContext context) => Text(
    (session.finalizedAt == null
            ? 'live_attendance_pending'
            : 'live_attendance_finalized')
        .tr(),
    style: AppTextStyles.bodySmall,
  );
}
