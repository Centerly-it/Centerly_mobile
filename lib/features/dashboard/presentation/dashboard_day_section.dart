import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import '../../../core/format/cairo_time.dart';
import '../../../core/theme/color_manager.dart';
import '../../../core/theme/values_manager.dart';
import '../../../core/theme/style_manager.dart';
import '../../../core/theme/font_manager.dart';
import '../../../core/widgets/app_empty_state.dart';
import 'dashboard_session_schedule.dart';
import '../domain/dashboard_summary.dart';
import 'dashboard_metrics.dart';

class DashboardDaySection extends StatelessWidget {
  const DashboardDaySection({
    required this.data,
    required this.onDate,
    super.key,
  });
  final DashboardSummary data;
  final ValueChanged<DateTime> onDate;

  @override
  Widget build(BuildContext context) {
    final isToday =
        data.localDate == CairoTime.date(CairoTime.local(DateTime.now()));
    return DecoratedBox(
      decoration: BoxDecoration(
        color: ColorManager.primarySoft,
        borderRadius: BorderRadius.circular(AppRadius.r16),
        border: Border.all(color: ColorManager.primaryLight),
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppPadding.p12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextButton.icon(
              style: TextButton.styleFrom(
                textStyle: AppTextStyles.headlineSmall,
              ),
              icon: const Icon(Icons.calendar_month_outlined),
              label: Text(
                isToday
                    ? ('dashboard_today'.tr() != 'dashboard_today'
                          ? 'dashboard_today'.tr()
                          : 'sessions_day'.tr())
                    : data.localDate,
              ),
              onPressed: () async {
                final date = DateTime.parse(data.localDate);
                final selected = await showDatePicker(
                  context: context,
                  initialDate: date,
                  firstDate: DateTime(2000),
                  lastDate: DateTime(2100),
                );
                if (selected != null && context.mounted) onDate(selected);
              },
            ),
            DashboardMetrics(
              twoColumns: true,
              values: {
                'live_session_count': '${data.sessions.length}',
                'live_work_duration':
                    '${data.scheduledMinutes ~/ 60}:${(data.scheduledMinutes % 60).toString().padLeft(2, '0')}',
                'live_total_students': '${data.students}',
                'live_total_groups': '${data.scheduledGroups}',
              },
            ),
            const SizedBox(height: AppSize.s24),
            Text(
              isToday
                  ? 'home_today_sessions_title'.tr()
                  : 'dashboard_sessions_on_day'.tr(
                      namedArgs: {
                        'date': DateFormat.yMMMd(
                          context.locale.toString(),
                        ).format(DateTime.parse(data.localDate)),
                      },
                    ),
              style: Theme.of(context).textTheme.titleLarge,
            ),
            if (data.sessions.isEmpty)
              AppEmptyState(
                title: 'sessions_no_sessions_subtitle'.tr(),
                titleStyle: AppTextStyles.bodySmall.copyWith(
                  fontSize: FontSize.s15,
                ),
              ),
            if (data.sessions.isNotEmpty) ...[
              const SizedBox(height: AppSize.s12),
              DashboardSessionSchedule(sessions: data.sessions),
            ],
          ],
        ),
      ),
    );
  }
}
