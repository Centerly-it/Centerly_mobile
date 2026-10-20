import 'finance_movement_tags.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import '../../../../core/format/cairo_time.dart';
import '../../../../core/theme/color_manager.dart';
import '../../../../core/theme/style_manager.dart';
import '../../../../core/theme/values_manager.dart';
import '../../../../core/widgets/app_surface_panel.dart';
import '../../domain/finance_entry.dart';
import 'finance_design.dart';

class FinanceMovementCard extends StatelessWidget {
  const FinanceMovementCard({
    required this.movement,
    required this.invoice,
    required this.onTap,
    super.key,
  });
  final FinanceMovement movement;
  final FinanceInvoice invoice;
  final VoidCallback onTap;
  @override
  Widget build(BuildContext context) {
    final color = movement.reversed ? ColorManager.error : ColorManager.success;
    return Padding(
      padding: const EdgeInsets.only(bottom: AppPadding.p12),
      child: InkWell(
        onTap: onTap,
        child: AppSurfacePanel(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  CircleAvatar(
                    radius: 18,
                    backgroundColor: color.withAlpha(20),
                    child: Icon(
                      movement.reversed
                          ? Icons.undo_rounded
                          : Icons.south_west_rounded,
                      color: color,
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: AppSize.s8),
                  Expanded(
                    child: Text(
                      invoice.studentKey.tr(),
                      style: AppTextStyles.titleSmall,
                    ),
                  ),
                  const SizedBox(width: AppSize.s8),
                  Flexible(
                    child: FinanceMoney(
                      movement.signedAmount,
                      style: AppTextStyles.titleMedium.copyWith(
                        color: color,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppSize.s8),
              Text(
                'finance_movement_reference'.tr(
                  args: [movement.id, invoice.id],
                ),
                style: AppTextStyles.caption,
              ),
              const SizedBox(height: AppSize.s8),
              FinanceMovementTags(movement: movement, color: color),
              const SizedBox(height: AppSize.s8),
              Text(
                '${DateFormat.MMMMd(context.locale.toString()).format(CairoTime.local(movement.at))}  ·  ${CairoTime.time(movement.at, context.locale.toString())}',
                style: AppTextStyles.caption,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
