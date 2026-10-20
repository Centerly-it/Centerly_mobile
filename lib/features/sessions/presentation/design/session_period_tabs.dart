import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import '../../../../core/theme/color_manager.dart';
import '../../../../core/theme/style_manager.dart';
import '../../../../core/theme/values_manager.dart';
import '../session_date_controls.dart';
import 'session_design.dart';

class SessionPeriodTabs extends StatelessWidget {
  const SessionPeriodTabs({
    required this.period,
    required this.onChanged,
    super.key,
  });
  final SessionPeriod period;
  final ValueChanged<SessionPeriod> onChanged;
  @override
  Widget build(BuildContext context) => Row(
    children: [
      for (final value in SessionPeriod.values)
        Expanded(
          child: InkWell(
            onTap: () => onChanged(value),
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: AppPadding.p8),
              margin: const EdgeInsets.symmetric(horizontal: AppPadding.p32),
              decoration: BoxDecoration(
                border: Border(
                  bottom: BorderSide(
                    color: value == period
                        ? ColorManager.primaryDark
                        : Colors.transparent,
                    width: 1.5,
                  ),
                ),
              ),
              child: Text(
                'sessions_${value.name}'.tr(),
                textAlign: TextAlign.center,
                style: AppTextStyles.titleSmall.copyWith(
                  color: value == period
                      ? ColorManager.primaryDark
                      : SessionDesign.muted,
                ),
              ),
            ),
          ),
        ),
    ],
  );
}
