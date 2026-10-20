import 'package:easy_localization/easy_localization.dart';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import '../../../core/theme/color_manager.dart';
import '../../../core/theme/style_manager.dart';
import '../../../core/format/cairo_time.dart';
import '../../../core/theme/values_manager.dart';
import '../../../core/widgets/app_status_badge.dart';
import '../../../screens/teacher/teacher_shared.dart';
import '../domain/session_record.dart';
import 'session_card_actions.dart';

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
          const SizedBox(height: AppSize.s12),
          Wrap(
            spacing: AppSize.s16,
            runSpacing: AppSize.s8,
            children: [
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(
                    Icons.calendar_today_outlined,
                    size: AppSize.s16,
                    color: ColorManager.primary,
                  ),
                  const SizedBox(width: AppSize.s4),
                  Text(session.localDate, style: AppTextStyles.bodySmall),
                ],
              ),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(
                    Icons.schedule_rounded,
                    size: AppSize.s16,
                    color: ColorManager.primary,
                  ),
                  const SizedBox(width: AppSize.s4),
                  Text(
                    CairoTime.range(
                      session.startsAt,
                      session.endsAt,
                      context.locale.languageCode,
                    ),
                    textDirection: ui.TextDirection.ltr,
                    style: AppTextStyles.bodySmall,
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: AppSize.s12),
          Wrap(
            spacing: AppSize.s8,
            runSpacing: AppSize.s8,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              AppStatusBadge.session(status: session.status),
              Text(
                (session.finalizedAt == null
                        ? 'live_attendance_pending'
                        : 'live_attendance_finalized')
                    .tr(),
                style: AppTextStyles.bodySmall,
              ),
            ],
          ),
          const Divider(height: AppSize.s24),
          SessionCardActions(
            session: session,
            showDetails: showDetails,
            onChanged: onChanged,
            onTap: onTap,
          ),
        ],
      ),
    ),
  );
}
