import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import '../../../core/format/cairo_time.dart';
import '../../../core/theme/color_manager.dart';
import '../../../core/theme/style_manager.dart';
import '../../../core/theme/values_manager.dart';
import '../domain/notification_record.dart';

class NotificationSummary extends StatelessWidget {
  const NotificationSummary({required this.record, super.key});
  final NotificationRecord record;
  @override
  Widget build(BuildContext context) => Row(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Container(
        padding: const EdgeInsets.all(AppPadding.p8),
        decoration: const BoxDecoration(
          color: ColorManager.primaryBright,
          shape: BoxShape.circle,
        ),
        child: Icon(
          record.type == 'student_added'
              ? Icons.person_add_alt_1_outlined
              : record.type == 'student_withdrawn' ||
                    record.type == 'student_removed'
              ? Icons.person_remove_outlined
              : record.type == 'session_cancelled'
              ? Icons.event_busy_outlined
              : record.paymentId != null
              ? Icons.receipt_long_outlined
              : Icons.notifications_none,
          color: ColorManager.primary,
          size: AppSize.s20,
        ),
      ),
      const SizedBox(width: AppSize.s12),
      Expanded(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(record.labelKey.tr(), style: AppTextStyles.titleSmall),
            if (record.studentName != null) ...[
              const SizedBox(height: AppSize.s4),
              Text(record.studentName!, style: AppTextStyles.bodyMedium),
            ],
            const SizedBox(height: AppSize.s8),
            Text(
              '${CairoTime.date(CairoTime.local(record.createdAt))} · ${CairoTime.time(record.createdAt, context.locale.languageCode)}',
              style: AppTextStyles.metadata,
            ),
            const SizedBox(height: AppSize.s8),
            Text(
              (record.readAt == null
                      ? 'completion_unread_label'
                      : 'completion_read_label')
                  .tr(),
              style: AppTextStyles.caption.copyWith(
                color: record.readAt == null
                    ? ColorManager.primary
                    : ColorManager.textSecondary,
              ),
            ),
            const SizedBox(height: AppSize.s12),
          ],
        ),
      ),
    ],
  );
}
