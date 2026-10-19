import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import '../format/cairo_time.dart';

class ReadDateControls extends StatelessWidget {
  const ReadDateControls({
    required this.from,
    required this.to,
    required this.onChanged,
    super.key,
  });
  final DateTime from, to;
  final void Function(DateTime, DateTime) onChanged;
  @override
  Widget build(BuildContext context) => TextButton.icon(
    icon: const Icon(Icons.date_range),
    label: Text('${CairoTime.date(from)} – ${CairoTime.date(to)}'),
    onPressed: () async {
      final range = await showDateRangePicker(
        context: context,
        firstDate: DateTime(2000),
        lastDate: DateTime(2100),
        initialDateRange: DateTimeRange(start: from, end: to),
        helpText: 'completion_date_range'.tr(),
      );
      if (range == null || !context.mounted) return;
      if (range.end.difference(range.start).inDays > 365) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('completion_range_limit'.tr())));
        return;
      }
      onChanged(range.start, range.end);
    },
  );
}
