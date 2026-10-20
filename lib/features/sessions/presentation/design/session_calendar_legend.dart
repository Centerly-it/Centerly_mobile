import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import '../../../../core/theme/style_manager.dart';
import '../../../../core/theme/values_manager.dart';
import 'session_design.dart';

class SessionCalendarLegend extends StatelessWidget {
  const SessionCalendarLegend({super.key});
  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.symmetric(vertical: AppPadding.p8),
    child: Wrap(
      spacing: AppSize.s8,
      runSpacing: AppSize.s4,
      children: [
        for (final entry in {
          '5e17e.svg': 'design_ended',
          'cd60c.svg': 'design_available',
          '82d1c.svg': 'design_cancelled',
        }.entries)
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              SessionAsset(entry.key),
              const SizedBox(width: AppSize.s4),
              Text(
                entry.value.tr(),
                style: AppTextStyles.caption.copyWith(fontSize: 10),
              ),
            ],
          ),
      ],
    ),
  );
}
