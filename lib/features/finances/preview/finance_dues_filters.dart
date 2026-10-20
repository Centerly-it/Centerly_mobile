import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import '../../../core/theme/color_manager.dart';
import '../../../core/theme/values_manager.dart';

class FinanceDuesFilters extends StatelessWidget {
  const FinanceDuesFilters({
    required this.selectedStatus,
    required this.onQuery,
    required this.onStatus,
    super.key,
  });
  final String selectedStatus;
  final ValueChanged<String> onQuery, onStatus;
  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.stretch,
    children: [
      TextField(
        onChanged: (v) => onQuery(v.trim()),
        decoration: InputDecoration(
          prefixIcon: const Icon(Icons.search),
          hintText: 'finance_search_dues'.tr(),
        ),
      ),
      const SizedBox(height: AppSize.s12),
      Wrap(
        spacing: AppSize.s8,
        runSpacing: AppSize.s4,
        children: [
          for (final status in [
            'all',
            'overdue',
            'partial',
            'not_late',
            'paid',
          ])
            ChoiceChip(
              label: Text('finance_status_$status'.tr()),
              selected: selectedStatus == status,
              onSelected: (_) => onStatus(status),
              selectedColor: ColorManager.primaryBright,
              showCheckmark: false,
            ),
        ],
      ),
    ],
  );
}
