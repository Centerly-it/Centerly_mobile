import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import '../../../core/widgets/server_search_field.dart';
import '../../groups/presentation/teacher_group_filter.dart';
import '../../secretaries/presentation/teacher_secretary_filter.dart';
import '../data/finance_repository.dart';
import 'live_movement_filter_chips.dart';

class FinanceMovementControls extends StatelessWidget {
  const FinanceMovementControls({
    required this.actor,
    required this.method,
    required this.kind,
    required this.onGroup,
    required this.onActor,
    required this.onSearch,
    required this.onMethod,
    required this.onKind,
    super.key,
  });
  final String? actor, method, kind;
  final ValueChanged<String?> onGroup, onActor, onMethod, onKind;
  final ValueChanged<String> onSearch;
  @override
  Widget build(BuildContext context) => ConstrainedBox(
    constraints: BoxConstraints(
      maxHeight: MediaQuery.sizeOf(context).height * .30,
    ),
    child: SingleChildScrollView(
      child: Column(
        children: [
          TeacherGroupFilter(onChanged: onGroup),
          TeacherSecretaryFilter(
            key: ValueKey(actor),
            initialLabel: actor == null
                ? null
                : 'finance_selected_collector'.tr(),
            onChanged: onActor,
          ),
          if (actor != null)
            TextButton(
              onPressed: () => onActor(null),
              child: Text('detail_all'.tr()),
            ),
          if (FinanceRepository.movementFilters) ...[
            ServerSearchField(
              maxLength: 100,
              label: 'finance_search_movements'.tr(),
              onSubmitted: onSearch,
            ),
            LiveMovementFilterChips(
              method: method,
              kind: kind,
              onMethod: onMethod,
              onKind: onKind,
            ),
          ],
        ],
      ),
    ),
  );
}
