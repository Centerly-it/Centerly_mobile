import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import '../../core/widgets/read_date_controls.dart';
import '../../features/groups/presentation/teacher_group_filter.dart';
import '../../features/secretaries/presentation/teacher_secretary_filter.dart';

class ReportFilterControls extends StatelessWidget {
  const ReportFilterControls({
    required this.from,
    required this.to,
    required this.kinds,
    required this.selected,
    required this.onDates,
    required this.onKind,
    required this.onGroup,
    required this.onCollector,
    required this.collectorFilter,
    super.key,
  });
  final DateTime from, to;
  final Map<String?, String> kinds;
  final String? selected;
  final void Function(DateTime, DateTime) onDates;
  final ValueChanged<String?> onKind, onGroup, onCollector;
  final bool collectorFilter;
  @override
  Widget build(BuildContext context) => ConstrainedBox(
    constraints: BoxConstraints(
      maxHeight: MediaQuery.sizeOf(context).height * .38,
    ),
    child: SingleChildScrollView(
      child: Column(
        children: [
          ReadDateControls(from: from, to: to, onChanged: onDates),
          TeacherGroupFilter(onChanged: onGroup),
          if (collectorFilter) TeacherSecretaryFilter(onChanged: onCollector),
          Wrap(
            children: [
              for (final e in kinds.entries)
                ChoiceChip(
                  label: Text(e.value.tr()),
                  selected: selected == e.key,
                  onSelected: (_) => onKind(e.key),
                ),
            ],
          ),
        ],
      ),
    ),
  );
}
