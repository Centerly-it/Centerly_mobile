import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import '../../../../core/theme/style_manager.dart';
import '../../../../core/theme/values_manager.dart';
import 'session_calendar_dot.dart';

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
          SessionCalendarStatus.ended: 'design_ended',
          SessionCalendarStatus.available: 'design_available',
          SessionCalendarStatus.cancelled: 'design_cancelled',
        }.entries)
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              SessionCalendarDot(status: entry.key),
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
