import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import '../../../core/theme/values_manager.dart';
import '../../../core/widgets/server_search_field.dart';
import '../../groups/presentation/teacher_group_filter.dart';

class FinanceDuesControls extends StatelessWidget {
  const FinanceDuesControls({
    required this.status,
    required this.onSearch,
    required this.onGroup,
    required this.onStatus,
    super.key,
  });
  final String status;
  final ValueChanged<String> onSearch, onStatus;
  final ValueChanged<String?> onGroup;
  @override
  Widget build(BuildContext context) => ConstrainedBox(
    constraints: BoxConstraints(
      maxHeight: MediaQuery.sizeOf(context).height * .36,
    ),
    child: SingleChildScrollView(
      child: Column(
        children: [
          ServerSearchField(
            maxLength: 100,
            label: 'finance_search_dues'.tr(),
            onSubmitted: onSearch,
          ),
          TeacherGroupFilter(onChanged: onGroup),
          Wrap(
            spacing: AppSize.s8,
            children: [
              for (final value in [
                'all',
                'overdue',
                'partial',
                'not_late',
                'paid',
              ])
                ChoiceChip(
                  label: Text('finance_status_$value'.tr()),
                  selected: status == value,
                  onSelected: (_) => onStatus(value),
                ),
            ],
          ),
        ],
      ),
    ),
  );
}
