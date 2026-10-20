import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import '../../../core/format/cairo_time.dart';
import '../../../core/theme/values_manager.dart';
import '../../../models/centerly_models.dart';
import '../../../screens/teacher/teacher_shared.dart';
import '../../dashboard/presentation/dashboard_metrics.dart';
import '../domain/session_detail.dart';
import 'live_session_card.dart';

String detailTimestamp(DateTime value, BuildContext context) =>
    '${CairoTime.date(CairoTime.local(value))} ${CairoTime.time(value, context.locale.languageCode)}';

class SessionDetailHeader extends StatelessWidget {
  const SessionDetailHeader({
    required this.detail,
    required this.onChanged,
    super.key,
  });
  final SessionDetail detail;
  final VoidCallback onChanged;
  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.stretch,
    children: [
      LiveSessionCard(
        session: detail.session,
        showDetails: false,
        onChanged: detail.session.endsAt.isAfter(detail.syncedAt)
            ? onChanged
            : null,
      ),
      TeacherCard(
        padding: const EdgeInsets.all(AppPadding.p8),
        child: Material(
          color: Colors.transparent,
          child: ExpansionTile(
            title: Text('session_attendance_info'.tr()),
            subtitle: Text(
              'detail_synced'.tr(
                args: [detailTimestamp(detail.syncedAt, context)],
              ),
            ),
            childrenPadding: const EdgeInsets.all(AppPadding.p12),
            expandedCrossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text('detail_manual_read_only'.tr()),
              if (detail.session.finalizedAt != null)
                Text(
                  'detail_finalized'.tr(
                    args: [
                      detailTimestamp(detail.session.finalizedAt!, context),
                    ],
                  ),
                ),
            ],
          ),
        ),
      ),
      if (detail.session.status == SessionStatus.cancelled) ...[
        const SizedBox(height: AppSize.s12),
        TeacherCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text('detail_cancel_history'.tr()),
              Text(detail.cancelReason ?? 'detail_not_recorded'.tr()),
              Text(
                'detail_actor'.tr(
                  args: [detail.cancelledBy ?? 'detail_not_recorded'.tr()],
                ),
              ),
              if (detail.cancelledAt != null)
                Text(detailTimestamp(detail.cancelledAt!, context)),
            ],
          ),
        ),
      ],
      const SizedBox(height: AppSize.s16),
      DashboardMetrics(
        twoColumns: true,
        values: {
          'attendance_present': '${detail.counts.present}',
          'attendance_absent': '${detail.counts.absent}',
          'attendance_excused': '${detail.counts.excused}',
          'attendance_not_marked': '${detail.counts.notMarked}',
        },
      ),
    ],
  );
}
