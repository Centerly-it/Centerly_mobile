import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import '../../../core/theme/values_manager.dart';
import '../../../core/widgets/app_empty_state.dart';
import '../data/session_detail_repository.dart';
import 'session_detail_state.dart';

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
              onSelected: (selected) {
                if (selected && state.status != value && !state.loading) {
                  onFilter(value);
                }
              },
            ),
        ],
      ),
      if (state.loading && state.detail != null)
        const Padding(
          padding: EdgeInsets.symmetric(vertical: AppPadding.p8),
          child: LinearProgressIndicator(minHeight: AppSize.s2),
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
    ],
  );
}
