import '../domain/finance_overview_data.dart';
import 'finance_target_panel.dart';
import 'finance_scenario_panel.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import '../../../core/theme/color_manager.dart';
import '../../../core/theme/values_manager.dart';
import '../domain/finance_ledger.dart';
import '../domain/finance_plan.dart';

class FinanceCalculator extends StatefulWidget {
  const FinanceCalculator({
    this.ledger,
    this.summary,
    required this.month,
    required this.now,
    super.key,
  });
  final FinanceLedger? ledger;
  final FinanceOverviewData? summary;
  final DateTime month, now;
  @override
  State<FinanceCalculator> createState() => _FinanceCalculatorState();
}

class _FinanceCalculatorState extends State<FinanceCalculator> {
  final _target = TextEditingController();
  int _percent = 50;
  @override
  void dispose() {
    _target.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final target = BigInt.tryParse(_target.text);
    final plan = FinancePlan(
      month: widget.month,
      now: widget.now,
      net: widget.summary?.net ?? widget.ledger!.net(widget.month),
      remaining:
          widget.summary?.outstanding ??
          widget.ledger!.outstanding(widget.month),
      target: (target ?? BigInt.zero) * BigInt.from(100),
      percent: _percent,
    );
    return Scaffold(
      backgroundColor: ColorManager.canvas,
      appBar: AppBar(title: Text('finance_calculator'.tr())),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(AppPadding.p16),
          children: [
            FinanceScenarioPanel(
              plan: plan,
              onChanged: (value) => setState(() => _percent = value),
            ),
            const SizedBox(height: AppSize.s16),
            FinanceTargetPanel(
              plan: plan,
              target: target,
              controller: _target,
              onChanged: () => setState(() {}),
            ),
          ],
        ),
      ),
    );
  }
}
