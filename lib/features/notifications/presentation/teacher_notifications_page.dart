import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/api/teacher_read_client.dart';
import '../../../core/data/completion_reads.dart';
import '../../../core/data/read_page.dart';
import '../../../core/data/teacher_actions.dart';
import '../../../core/di/di.dart';
import '../../../core/format/cairo_time.dart';
import '../../../core/theme/style_manager.dart';
import '../../../core/presentation/paged_read_cubit.dart';
import '../../../core/widgets/paged_read_body.dart';
import '../../../core/widgets/teacher_action_button.dart';
import '../../../screens/teacher/teacher_shared.dart';
import '../../sessions/presentation/session_detail_page.dart';
import '../domain/notification_record.dart';
import 'notification_payment_button.dart';

class TeacherNotificationsPage extends StatelessWidget {
  const TeacherNotificationsPage({super.key});
  @override
  Widget build(BuildContext context) => BlocProvider(
    create: (_) => PagedReadCubit<NotificationRecord, int>(
      (_, cursor) => CompletionReads(getIt<TeacherReadClient>()).page(
        TeacherRead.notifications,
        params: {'p_cursor': cursor, 'p_limit': 30},
        row: NotificationRecord.fromJson,
        summary: (j) => readCount(j['unread_count']),
      ),
      (r) => r.id,
    )..refresh(),
    child: Scaffold(
      appBar: AppBar(title: Text('completion_notifications'.tr())),
      body: SafeArea(
        child: PagedReadBody<NotificationRecord, int>(
          header: (_, p) =>
              Text('completion_unread'.tr(args: ['${p.summary}'])),
          item: (context, r) => TeacherCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  r.labelKey.tr(),
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                Text(
                  '${CairoTime.date(CairoTime.local(r.createdAt))} ${CairoTime.time(r.createdAt, context.locale.languageCode)}',
                  style: AppTextStyles.metadata,
                ),
                Text(
                  (r.readAt == null
                          ? 'completion_unread_label'
                          : 'completion_read_label')
                      .tr(),
                ),
                if (r.sessionId != null)
                  TextButton(
                    onPressed: () =>
                        SessionDetailPage.open(context, r.sessionId!),
                    child: Text('session_details_title'.tr()),
                  ),
                if (r.paymentId != null)
                  NotificationPaymentButton(
                    paymentId: r.paymentId!,
                    reversed: r.type == 'payment_reversed',
                  ),
                if (r.readAt == null)
                  TeacherActionButton(
                    label: 'completion_mark_read'.tr(),
                    action: () => TeacherActions(
                      getIt<TeacherReadClient>(),
                    ).markRead(r.id),
                    onReconcile: context
                        .read<PagedReadCubit<NotificationRecord, int>>()
                        .refresh,
                  ),
              ],
            ),
          ),
        ),
      ),
    ),
  );
}
