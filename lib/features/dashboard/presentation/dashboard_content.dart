import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import '../../../core/theme/values_manager.dart';
import '../../../core/widgets/app_empty_state.dart';
import '../../../screens/teacher/teacher_shared.dart';
import '../../sessions/presentation/live_session_card.dart';
import '../domain/dashboard_summary.dart';

class DashboardContent extends StatelessWidget {
  const DashboardContent({required this.data, required this.onDate, super.key});
  final DashboardSummary data;
  final ValueChanged<DateTime> onDate;
  @override
  Widget build(BuildContext context) => ListView(
    physics: const AlwaysScrollableScrollPhysics(),
    padding: const EdgeInsets.all(AppPadding.p16),
    children: [
      TextButton.icon(
        icon: const Icon(Icons.calendar_month_outlined),
        label: Text(data.localDate),
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
      for (final entry in {
        'live_total_students': '${data.students}',
        'live_total_groups': '${data.groups}',
        'live_collected': data.collectedEgp,
        'live_outstanding': data.outstandingEgp,
        'live_session_count': '${data.sessions.length}',
        'live_scheduled_minutes': '${data.scheduledMinutes}',
      }.entries)
        Padding(
          padding: const EdgeInsets.only(bottom: AppPadding.p16),
          child: TeacherStatCard(
            title: entry.key.tr(),
            value: entry.value,
            icon: Icons.analytics_outlined,
            color: Theme.of(context).colorScheme.primary,
          ),
        ),
      Text(
        'live_sessions_for_date'.tr(),
        style: Theme.of(context).textTheme.titleLarge,
      ),
      if (data.sessions.isEmpty)
        AppEmptyState(
          title: 'sessions_no_sessions_title'.tr(),
          subtitle: 'sessions_no_sessions_subtitle'.tr(),
        ),
      for (final session in data.sessions) LiveSessionCard(session: session),
    ],
  );
}
