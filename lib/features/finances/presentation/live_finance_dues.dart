import 'finance_dues_controls.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/presentation/paged_read_cubit.dart';
import '../../../core/widgets/paged_read_body.dart';
import '../data/finance_repository.dart';
import '../domain/finance_due.dart';
import 'design/finance_design.dart';
import 'live_due_card.dart';
import 'live_finance.dart';

class LiveFinanceDues extends StatefulWidget {
  const LiveFinanceDues({
    required this.repository,
    required this.month,
    this.initialStatus = 'all',
    this.studentId,
    super.key,
  });
  final FinanceRepository repository;
  final DateTime month;
  final String initialStatus;
  final String? studentId;
  @override
  State<LiveFinanceDues> createState() => _LiveFinanceDuesState();
}

class _LiveFinanceDuesState extends State<LiveFinanceDues> {
  late final cubit = PagedReadCubit<FinanceDue, FinanceDuesSummary>(
    widget.repository.dues,
    (r) => r.id,
  );
  late String status = widget.initialStatus;
  String search = '';
  String? group;
  void reload() => cubit.apply({
    ...financeDates(widget.month),
    'p_status': status,
    'p_search': search,
    'p_student_id': widget.studentId,
    'p_group_id': group,
  });
  @override
  void initState() {
    super.initState();
    reload();
  }

  @override
  void dispose() {
    cubit.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => BlocProvider.value(
    value: cubit,
    child: PagedReadBody<FinanceDue, FinanceDuesSummary>(
      leading: FinanceDuesControls(
        status: status,
        onSearch: (v) {
          search = v.trim();
          reload();
        },
        onGroup: (v) {
          group = v;
          reload();
        },
        onStatus: (v) {
          setState(() => status = v);
          reload();
        },
      ),
      header: (_, p) => Text(
        'finance_dues_result'.tr(
          args: [
            '${p.total}',
            financeMoney(p.summary.amount('outstanding_egp')),
          ],
        ),
      ),
      item: (context, row) => LiveDueCard(
        row: row,
        asOf: cubit.state.page!.summary.asOf,
        repository: widget.repository,
        onReturn: cubit.refresh,
      ),
    ),
  );
}
