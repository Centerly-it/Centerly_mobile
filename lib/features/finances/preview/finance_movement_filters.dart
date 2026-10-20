import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import '../../../core/theme/values_manager.dart';

class FinanceMovementFilters extends StatelessWidget {
  const FinanceMovementFilters({
    required this.actors,
    required this.actor,
    required this.method,
    required this.kind,
    required this.onActor,
    required this.onMethod,
    required this.onKind,
    super.key,
  });
  final Set<String> actors;
  final String actor, method, kind;
  final ValueChanged<String> onActor, onMethod, onKind;
  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Wrap(
        spacing: AppSize.s16,
        children: [
          DropdownButton<String>(
            value: actor,
            onChanged: (v) => onActor(v!),
            items: [
              DropdownMenuItem(
                value: 'all',
                child: Text('finance_all_secretaries'.tr()),
              ),
              for (final actor in actors)
                DropdownMenuItem(
                  value: actor,
                  child: Text('finance_demo_secretary_$actor'.tr()),
                ),
            ],
          ),
          DropdownButton<String>(
            value: method,
            onChanged: (v) => onMethod(v!),
            items: [
              DropdownMenuItem(
                value: 'all',
                child: Text('finance_all_methods'.tr()),
              ),
              for (final method in ['cash', 'transfer', 'other'])
                DropdownMenuItem(
                  value: method,
                  child: Text('completion_method_$method'.tr()),
                ),
            ],
          ),
        ],
      ),
      Wrap(
        spacing: AppSize.s8,
        children: [
          for (final option in ['all', 'collections', 'corrections'])
            ChoiceChip(
              label: Text('finance_kind_$option'.tr()),
              selected: option == kind,
              onSelected: (_) => onKind(option),
              showCheckmark: false,
            ),
        ],
      ),
    ],
  );
}
