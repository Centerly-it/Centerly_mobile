import '../../../core/format/calendar_month.dart';
import 'package:flutter/material.dart';
import '../../../core/api/teacher_read_client.dart';
import '../../../core/di/di.dart';
import '../../../core/format/cairo_time.dart';
import '../../../core/theme/color_manager.dart';
import '../data/finance_repository.dart';
import 'design/finance_month_bar.dart';
import 'design/finance_tabs.dart';
import 'live_finance_overview.dart';
import 'live_finance_dues.dart';
import 'live_finance_movements.dart';

class LiveFinance extends StatefulWidget {
  const LiveFinance({super.key});
  @override
  State<LiveFinance> createState() => _LiveFinanceState();
}

class _LiveFinanceState extends State<LiveFinance> {
  late final repository = FinanceRepository(getIt<TeacherReadClient>());
  late DateTime month = DateTime(
    CairoTime.local(DateTime.now()).year,
    CairoTime.local(DateTime.now()).month,
  );
  int tab = 0;
  String status = 'all';
  String? actor;
  @override
  Widget build(BuildContext context) => ColoredBox(
    color: ColorManager.canvas,
    child: Column(
      children: [
        FinanceMonthBar(
          month: month,
          onChanged: (v) => setState(() {
            month = v;
            actor = null;
          }),
        ),
        FinanceTabs(
          index: tab,
          onChanged: (v) => setState(() {
            tab = v;
            status = 'all';
            actor = null;
          }),
        ),
        Expanded(
          child: switch (tab) {
            0 => LiveFinanceOverview(
              key: ValueKey(month),
              repository: repository,
              month: month,
              onDues: (v) => setState(() {
                status = v;
                tab = 1;
              }),
              onActor: (v) => setState(() {
                actor = v;
                tab = 2;
              }),
            ),
            1 => LiveFinanceDues(
              key: ValueKey('$month-$status'),
              repository: repository,
              month: month,
              initialStatus: status,
            ),
            _ => LiveFinanceMovements(
              key: ValueKey('$month-$actor'),
              month: month,
              actor: actor,
            ),
          },
        ),
      ],
    ),
  );
}

Map<String, dynamic> financeDates(DateTime month) => calendarMonthDates(month);
