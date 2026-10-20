import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import '../../../core/theme/values_manager.dart';
import '../../../core/widgets/app_empty_state.dart';
import '../../../core/widgets/app_error_state.dart';
import '../../../core/widgets/app_status_badge.dart';
import '../../../screens/teacher/teacher_shared.dart';
import '../data/session_detail_repository.dart';
import 'session_detail_state.dart';
import 'session_detail_header.dart';

class SessionAttendanceList extends StatelessWidget {
  const SessionAttendanceList({
    required this.state,
    required this.onFilter,
    required this.onMore,
    super.key,
  });
  final SessionDetailState state;
  final ValueChanged<String?> onFilter;
  final VoidCallback onMore;
  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.stretch,
    children: [
      const SizedBox(height: AppSize.s24),
      Wrap(
        spacing: AppSize.s8,
        children: [
          for (final value in [null, ...SessionDetailRepository.statuses])
            ChoiceChip(
              label: Text(
                (value == null ? 'detail_all' : 'attendance_$value').tr(),
              ),
              selected: state.status == value,
              onSelected: (_) => onFilter(value),
            ),
        ],
      ),
      Text(
        'detail_filtered_count'.tr(args: ['${state.detail!.filteredCount}']),
      ),
      if (state.rows.isEmpty)
        AppEmptyState(
          title: 'detail_empty_title'.tr(),
          subtitle:
              (state.status == null
                      ? 'detail_empty_records'
                      : 'detail_empty_filter')
                  .tr(),
        ),
      for (final row in state.rows)
        Padding(
          padding: const EdgeInsets.symmetric(vertical: AppPadding.p8),
          child: TeacherCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        row.name,
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                    ),
                    const SizedBox(width: AppSize.s8),
                    AppStatusBadge.attendance(status: row.status),
                  ],
                ),
                const SizedBox(height: AppSize.s12),
                Text(
                  'detail_actor'.tr(
                    args: [row.marker ?? 'detail_not_recorded'.tr()],
                  ),
                ),
                if (row.markedAt != null)
                  Text(
                    'detail_marked'.tr(
                      args: [detailTimestamp(row.markedAt!, context)],
                    ),
                  ),
                Text(
                  'detail_updated'.tr(
                    args: [detailTimestamp(row.updatedAt, context)],
                  ),
                ),
              ],
            ),
          ),
        ),
      if (state.error) AppErrorState(onRetry: onMore),
      if (state.loading) const Center(child: CircularProgressIndicator()),
      if (state.nextCursor != null && !state.loading && !state.error)
        TextButton(onPressed: onMore, child: Text('detail_more'.tr())),
    ],
  );
}
