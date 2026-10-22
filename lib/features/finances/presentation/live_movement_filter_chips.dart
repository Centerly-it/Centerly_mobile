import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

class LiveMovementFilterChips extends StatelessWidget {
  const LiveMovementFilterChips({
    required this.method,
    required this.kind,
    required this.onMethod,
    required this.onKind,
    super.key,
  });
  final String? method, kind;
  final ValueChanged<String?> onMethod, onKind;
  @override
  Widget build(BuildContext context) => Column(
    children: [
      Wrap(
        children: [
          for (final v in [null, 'cash', 'transfer', 'other'])
            ChoiceChip(
              label: Text(
                v == null ? 'detail_all'.tr() : 'completion_method_$v'.tr(),
              ),
              selected: method == v,
              onSelected: (_) => onMethod(v),
            ),
        ],
      ),
      Wrap(
        children: [
          for (final v in [null, 'collections', 'corrections'])
            ChoiceChip(
              label: Text(
                v == null
                    ? 'detail_all'.tr()
                    : (v == 'collections'
                              ? 'finance_gross'
                              : 'finance_corrections')
                          .tr(),
              ),
              selected: kind == v,
              onSelected: (_) => onKind(v),
            ),
        ],
      ),
    ],
  );
}
