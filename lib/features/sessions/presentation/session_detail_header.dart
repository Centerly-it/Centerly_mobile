import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import '../../../core/format/cairo_time.dart';
import '../../../core/theme/color_manager.dart';
import '../../../core/theme/style_manager.dart';
import '../../../core/theme/values_manager.dart';
import '../../../models/centerly_models.dart';
import '../../../screens/teacher/teacher_shared.dart';
import '../../dashboard/presentation/dashboard_metrics.dart';
import '../domain/session_detail.dart';
import 'design/session_info_panel.dart';
import 'session_card_actions.dart';

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
      SessionInfoPanel(data: detail.session.design),
      SessionCardActions(
        session: detail.session,
        showDetails: false,
        onChanged: detail.session.endsAt.isAfter(detail.syncedAt)
            ? onChanged
            : null,
      ),
      if (detail.session.status == SessionStatus.cancelled) ...[
        const SizedBox(height: AppSize.s12),
        TeacherCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                children: [
                  const Icon(
                    Icons.event_busy_outlined,
                    size: AppSize.s20,
                    color: ColorManager.error,
                  ),
                  const SizedBox(width: AppSize.s8),
                  Expanded(
                    child: Text(
                      'detail_cancel_history'.tr(),
                      style: AppTextStyles.titleSmall,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppSize.s8),
              Container(
                padding: const EdgeInsets.all(AppPadding.p8),
                decoration: BoxDecoration(
                  color: ColorManager.grey200,
                  borderRadius: BorderRadius.circular(AppRadius.r8),
                ),
                child: Text(
                  detail.cancelReason ?? 'detail_not_recorded'.tr(),
                  style: AppTextStyles.bodySmall,
                ),
              ),
              const SizedBox(height: AppSize.s8),
              _DetailMetadataRow(
                icon: Icons.person_outline,
                text: 'detail_actor'.tr(
                  args: [detail.cancelledBy ?? 'detail_not_recorded'.tr()],
                ),
              ),
              if (detail.cancelledAt != null)
                _DetailMetadataRow(
                  icon: Icons.schedule_outlined,
                  text: detailTimestamp(detail.cancelledAt!, context),
                ),
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

class _DetailMetadataRow extends StatelessWidget {
  const _DetailMetadataRow({required this.icon, required this.text});

  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(top: AppPadding.p4),
    child: Row(
      children: [
        Icon(icon, size: AppSize.s12, color: ColorManager.textSecondary),
        const SizedBox(width: AppSize.s4),
        Expanded(child: Text(text, style: AppTextStyles.metadata)),
      ],
    ),
  );
}
