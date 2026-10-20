import 'package:flutter/material.dart';
import '../../../core/format/cairo_time.dart';
import '../../../core/theme/color_manager.dart';
import '../domain/finance_entry.dart';
import '../presentation/design/finance_month_bar.dart';
import '../presentation/design/finance_tabs.dart';
import 'finance_preview_fixture.dart';
import 'finance_overview.dart';
import 'finance_dues_list.dart';
import 'finance_movements_list.dart';
import 'finance_invoice_detail.dart';
import 'finance_movement_detail.dart';

class FinancePreview extends StatefulWidget {
  const FinancePreview({this.now, super.key});
  final DateTime? now;
  @override
  State<FinancePreview> createState() => _FinancePreviewState();
}

class _FinancePreviewState extends State<FinancePreview> {
  late final _now = widget.now ?? DateTime.now();
  late DateTime _month = DateTime(
    CairoTime.local(_now).year,
    CairoTime.local(_now).month,
  );
  int _tab = 0;
  String _duesStatus = 'all';
  String? _actor;
  @override
  Widget build(BuildContext context) {
    final ledger = FinancePreviewFixture.build(_month, _now);
    void invoice(FinanceInvoice invoice) => Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => FinanceInvoiceDetail(ledger: ledger, invoice: invoice),
      ),
    );
    void movement(FinanceMovement movement) => showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (_) => FinanceMovementDetail(ledger: ledger, movement: movement),
    );
    return ColoredBox(
      color: ColorManager.canvas,
      child: Column(
        children: [
          FinanceMonthBar(
            month: _month,
            onChanged: (month) => setState(() {
              _month = month;
              _duesStatus = 'all';
              _actor = null;
            }),
          ),
          FinanceTabs(
            index: _tab,
            onChanged: (tab) => setState(() {
              _tab = tab;
              _duesStatus = 'all';
              _actor = null;
            }),
          ),
          Expanded(
            child: _tab == 0
                ? FinanceOverview(
                    ledger: ledger,
                    month: _month,
                    now: _now,
                    onDues: (status) => setState(() {
                      _tab = 1;
                      _duesStatus = status;
                    }),
                    onActor: (actor) => setState(() {
                      _tab = 2;
                      _actor = actor;
                    }),
                  )
                : _tab == 1
                ? FinanceDuesList(
                    key: ValueKey('${_month.toIso8601String()}-$_duesStatus'),
                    ledger: ledger,
                    month: _month,
                    now: _now,
                    initialStatus: _duesStatus,
                    onInvoice: invoice,
                  )
                : FinanceMovementsList(
                    key: ValueKey('${_month.toIso8601String()}-$_actor'),
                    ledger: ledger,
                    month: _month,
                    initialActor: _actor,
                    onMovement: movement,
                  ),
          ),
        ],
      ),
    );
  }
}
