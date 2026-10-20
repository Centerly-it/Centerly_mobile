import 'finance_movement_filters.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import '../../../core/theme/style_manager.dart';
import '../../../core/theme/values_manager.dart';
import '../../../core/widgets/app_search_empty.dart';
import '../domain/finance_entry.dart';
import '../domain/finance_ledger.dart';
import '../presentation/design/finance_design.dart';
import '../presentation/design/finance_movement_card.dart';

class FinanceMovementsList extends StatefulWidget {
  const FinanceMovementsList({
    required this.ledger,
    required this.month,
    required this.onMovement,
    this.initialActor,
    super.key,
  });
  final FinanceLedger ledger;
  final DateTime month;
  final ValueChanged<FinanceMovement> onMovement;
  final String? initialActor;
  @override
  State<FinanceMovementsList> createState() => _FinanceMovementsListState();
}

class _FinanceMovementsListState extends State<FinanceMovementsList> {
  late String _actor = widget.initialActor ?? 'all';
  String _method = 'all', _kind = 'all', _query = '';
  @override
  Widget build(BuildContext context) {
    final period = widget.ledger.receivedIn(widget.month);
    final rows =
        period
            .where(
              (m) =>
                  (_actor == 'all' || m.actor == _actor) &&
                  (_method == 'all' || m.method == _method) &&
                  (_kind == 'all' || (_kind == 'corrections') == m.reversed) &&
                  '${widget.ledger.invoice(m.invoiceId).studentKey.tr()} ${m.id} ${m.invoiceId}'
                      .toLowerCase()
                      .contains(_query.toLowerCase()),
            )
            .toList()
          ..sort((a, b) => b.at.compareTo(a.at));
    return ListView(
      padding: const EdgeInsets.all(AppPadding.p16),
      children: [
        TextField(
          onChanged: (v) => setState(() => _query = v.trim()),
          decoration: InputDecoration(
            prefixIcon: const Icon(Icons.search),
            hintText: 'finance_search_movements'.tr(),
          ),
        ),
        const SizedBox(height: AppSize.s12),
        FinanceMovementFilters(
          actors: period.map((m) => m.actor).toSet(),
          actor: _actor,
          method: _method,
          kind: _kind,
          onActor: (v) => setState(() => _actor = v),
          onMethod: (v) => setState(() => _method = v),
          onKind: (v) => setState(() => _kind = v),
        ),
        const SizedBox(height: AppSize.s12),
        Text(
          'finance_filtered_net'.tr(
            args: [
              '${rows.length}',
              financeMoney(
                rows.fold(BigInt.zero, (sum, m) => sum + m.signedAmount),
              ),
            ],
          ),
          style: AppTextStyles.bodySemiBold,
        ),
        const SizedBox(height: AppSize.s16),
        if (rows.isEmpty) AppSearchEmpty(title: 'finance_no_movements'.tr()),
        for (final movement in rows)
          FinanceMovementCard(
            movement: movement,
            invoice: widget.ledger.invoice(movement.invoiceId),
            onTap: () => widget.onMovement(movement),
          ),
      ],
    );
  }
}
