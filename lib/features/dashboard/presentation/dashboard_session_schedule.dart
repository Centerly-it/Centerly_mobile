import 'dart:ui' as ui;
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import '../../../core/format/cairo_time.dart';
import '../../../core/theme/color_manager.dart';
import '../../../core/theme/style_manager.dart';
import '../../../core/theme/values_manager.dart';
import '../../../screens/teacher/teacher_shared.dart';
import '../../sessions/domain/session_record.dart';

/// Dashboard glance only. Operational details live in the sessions tab.
class DashboardSessionSchedule extends StatelessWidget {
  const DashboardSessionSchedule({required this.sessions, super.key});
  final List<SessionRecord> sessions;

  @override
  Widget build(BuildContext context) => TeacherCard(
    padding: const EdgeInsets.all(AppPadding.p12),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        for (var i = 0; i < sessions.length; i++) ...[
          if (i > 0) const Divider(height: AppSize.s24),
          Wrap(
            alignment: WrapAlignment.spaceBetween,
            crossAxisAlignment: WrapCrossAlignment.center,
            spacing: AppSize.s12,
            runSpacing: AppSize.s4,
            children: [
              Text(
                sessions[i].groupName ?? 'nav_groups'.tr(),
                style: AppTextStyles.titleSmall,
              ),
              Row(
                textDirection: ui.TextDirection.ltr,
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
                      sessions[i].startsAt,
                      sessions[i].endsAt,
                      context.locale.languageCode,
                    ),
                    textDirection: ui.TextDirection.ltr,
                    style: AppTextStyles.bodySmall,
                  ),
                ],
              ),
            ],
          ),
        ],
      ],
    ),
  );
}
