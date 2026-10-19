import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import '../../../core/format/cairo_time.dart';
import '../../../core/theme/values_manager.dart';
import '../../../core/widgets/app_status_badge.dart';
import '../../../screens/teacher/teacher_shared.dart';
import '../domain/session_record.dart';
import '../../../models/centerly_models.dart';
import 'cancel_session_dialog.dart';
import 'session_detail_page.dart';

class LiveSessionCard extends StatelessWidget {
  const LiveSessionCard({
    required this.session,
    this.onTap,
    this.onChanged,
    this.showDetails = true,
    super.key,
  });
  final SessionRecord session;
  final bool showDetails;
  final VoidCallback? onTap;
  final VoidCallback? onChanged;
  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(bottom: AppPadding.p12),
    child: TeacherCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (session.groupName != null)
            Text(
              '${session.groupName} – ${session.subjectName ?? ''}',
              style: Theme.of(context).textTheme.titleMedium,
            ),
          Text(
            session.localDate,
            style: Theme.of(context).textTheme.titleMedium,
          ),
          Text(
            '${CairoTime.time(session.startsAt, context.locale.languageCode)} – '
            '${CairoTime.time(session.endsAt, context.locale.languageCode)}',
          ),
          Text('live_cairo_time'.tr()),
          Align(
            alignment: AlignmentDirectional.centerStart,
            child: AppStatusBadge.session(status: session.status),
          ),
          Text(
            (session.finalizedAt == null
                    ? 'live_attendance_pending'
                    : 'live_attendance_finalized')
                .tr(),
          ),
          if (onChanged != null &&
              session.groupName != null &&
              session.status != SessionStatus.cancelled &&
              session.status != SessionStatus.completed)
            TextButton(
              onPressed: () async {
                final changed = await showDialog<bool>(
                  context: context,
                  barrierDismissible: false,
                  builder: (_) => CancelSessionDialog(
                    sessionId: session.id,
                    sessionLabel: session.groupName!,
                  ),
                );
                // Errors may be ambiguous; always reconcile after closing.
                if (context.mounted && changed != null) onChanged!();
              },
              child: Text('session_cancel_button'.tr()),
            ),
          if (showDetails)
            TextButton(
              onPressed:
                  onTap ??
                  () async {
                    await SessionDetailPage.open(context, session.id);
                    if (context.mounted) onChanged?.call();
                  },
              child: Text('session_details_title'.tr()),
            ),
        ],
      ),
    ),
  );
}
