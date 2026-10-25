import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import '../../../core/widgets/server_search_field.dart';
import '../../../core/theme/values_manager.dart';
import '../../groups/presentation/teacher_group_filter.dart';
import '../../secretaries/presentation/teacher_secretary_filter.dart';
import '../data/finance_repository.dart';
import 'live_movement_filter_chips.dart';

class FinanceMovementControls extends StatelessWidget {
  const FinanceMovementControls({
    required this.actor,
    required this.method,
    required this.onGroup,
    required this.onActor,
    required this.onSearch,
    required this.onMethod,
    super.key,
  });
  final String? actor, method;
  final ValueChanged<String?> onGroup, onActor, onMethod;
  final ValueChanged<String> onSearch;
  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.symmetric(
      horizontal: AppPadding.p12,
      vertical: AppPadding.p4,
    ),
    child: Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          children: [
            Expanded(child: TeacherGroupFilter(onChanged: onGroup)),
            Expanded(
              child: TeacherSecretaryFilter(
                key: ValueKey(actor),
                initialLabel: actor == null
                    ? null
                    : 'finance_selected_collector'.tr(),
                onChanged: onActor,
              ),
            ),
            if (actor != null)
              IconButton(
                tooltip: 'detail_all'.tr(),
                onPressed: () => onActor(null),
                icon: const Icon(Icons.filter_alt_off_outlined),
              ),
          ],
        ),
        if (FinanceRepository.movementFilters) ...[
          ServerSearchField(
            maxLength: 100,
            label: 'finance_search_movements'.tr(),
            onSubmitted: onSearch,
          ),
          LiveMovementFilterChips(method: method, onMethod: onMethod),
        ],
      ],
    ),
  );
}
