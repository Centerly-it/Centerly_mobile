import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import '../../../core/widgets/app_surface_section.dart';
import '../domain/finance_overview_data.dart';
import 'design/finance_secretary_row.dart';
import 'finance_calculator.dart';

class FinanceOverviewActors extends StatelessWidget {
  const FinanceOverviewActors({
    required this.value,
    required this.month,
    required this.onActor,
    super.key,
  });
  final FinanceOverviewData value;
  final DateTime month;
  final ValueChanged<String> onActor;
  @override
  Widget build(BuildContext context) => AppSurfaceSection(
    icon: const Icon(Icons.receipt_long_outlined),
    title: 'finance_by_secretary'.tr(),
    child: Material(
      child: Column(
        children: [
          for (final actor in value.actors)
            FinanceSecretaryRow(
              summary: actor,
              actor: actor.id,
              month: month,
              onTap: () => onActor(actor.id),
            ),
          if (value.actors.isEmpty) Text('finance_no_movements'.tr()),
        ],
      ),
    ),
  );
}

class FinanceCalculatorLink extends StatelessWidget {
  const FinanceCalculatorLink({
    required this.value,
    required this.month,
    super.key,
  });
  final FinanceOverviewData value;
  final DateTime month;
  @override
  Widget build(BuildContext context) => Material(
    child: ListTile(
      leading: const Icon(Icons.calculate_outlined),
      title: Text('finance_calculator'.tr()),
      subtitle: Text('finance_calculator_hint'.tr()),
      onTap: () => Navigator.of(context).push(
        MaterialPageRoute<void>(
          builder: (_) => FinanceCalculator(
            summary: value,
            month: month,
            now: value.syncedAt,
          ),
        ),
      ),
    ),
  );
}
