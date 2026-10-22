import 'live_movement_body.dart';
import 'finance_movement_controls.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/api/teacher_read_client.dart';
import '../../../core/di/di.dart';
import '../../../core/presentation/paged_read_cubit.dart';
import '../data/finance_repository.dart';
import '../domain/finance_movements_summary.dart';
import 'live_finance.dart';

class LiveFinanceMovements extends StatefulWidget {
  const LiveFinanceMovements({required this.month, this.actor, super.key});
  final DateTime month;
  final String? actor;
  @override
  State<LiveFinanceMovements> createState() => _LiveFinanceMovementsState();
}

class _LiveFinanceMovementsState extends State<LiveFinanceMovements> {
  late final repository = FinanceRepository(getIt<TeacherReadClient>());
  late final cubit =
      PagedReadCubit<Map<String, dynamic>, FinanceMovementsSummary>(
        repository.movements,
        (r) => r['id'] as String,
      );
  late String? actor = widget.actor;
  String? group, method, kind;
  String search = '';
  void reload() => cubit.apply({
    ...financeDates(widget.month),
    'p_secretary_id': actor,
    'p_group_id': group,
    if (FinanceRepository.movementFilters) ...{
      'p_search': search,
      'p_method': method,
      'p_kind': kind,
    },
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
    child: Column(
      children: [
        FinanceMovementControls(
          actor: actor,
          method: method,
          kind: kind,
          onGroup: (v) {
            group = v;
            reload();
          },
          onActor: (v) {
            setState(() => actor = v);
            reload();
          },
          onSearch: (v) {
            search = v;
            reload();
          },
          onMethod: (v) {
            setState(() => method = v);
            reload();
          },
          onKind: (v) {
            setState(() => kind = v);
            reload();
          },
        ),
        Expanded(
          child: LiveMovementBody(
            repository: repository,
            onReturn: cubit.refresh,
          ),
        ),
      ],
    ),
  );
}
