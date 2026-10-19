import '../../core/format/cairo_time.dart';

class ReportQuery {
  ReportQuery(DateTime initial, this.kind)
    : to = DateTime(initial.year, initial.month, initial.day),
      from = DateTime(initial.year, initial.month, 1);
  DateTime from, to;
  String? kind, group, collector;
  Map<String, dynamic> params(String kindKey, bool withCollector) => {
    'p_from': CairoTime.date(from),
    'p_to': CairoTime.date(to),
    kindKey: kind,
    'p_group_id': group,
    if (withCollector) 'p_secretary_id': collector,
  };
}
