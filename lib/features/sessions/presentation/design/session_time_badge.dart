import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import '../../../../core/format/cairo_time.dart';
import '../../../../core/theme/color_manager.dart';
import '../../../../core/theme/style_manager.dart';
import '../../../../core/theme/values_manager.dart';
import 'session_design.dart';

class SessionTimeBadge extends StatelessWidget {
  const SessionTimeBadge({
    required this.start,
    required this.current,
    super.key,
  });
  final DateTime start;
  final bool current;
  @override
  Widget build(BuildContext context) {
    final time = CairoTime.local(start);
    final color = current ? ColorManager.white : SessionDesign.muted;
    return Container(
      padding: const EdgeInsets.all(AppPadding.p4),
      constraints: const BoxConstraints(minWidth: 49, minHeight: 43),
      decoration: BoxDecoration(
        color: current ? ColorManager.primary : SessionDesign.stroke,
        borderRadius: BorderRadius.circular(AppRadius.r8),
      ),
      child: Column(
        children: [
          Text(
            DateFormat('h:mm', context.locale.toString()).format(time),
            style: AppTextStyles.titleSmall.copyWith(color: color, height: 1.2),
          ),
          Text(
            (time.hour < 12
                    ? 'design_morning'
                    : time.hour < 15
                    ? 'design_noon'
                    : 'design_evening')
                .tr(),
            style: AppTextStyles.bodyMedium.copyWith(color: color, height: 1.2),
          ),
        ],
      ),
    );
  }
}
