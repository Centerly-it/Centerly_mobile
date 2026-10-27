import '../../../core/widgets/content_skeleton.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/api/teacher_read_client.dart';
import '../../../core/data/completion_reads.dart';
import '../../../core/data/read_page.dart';
import '../../../core/data/teacher_actions.dart';
import '../../../core/di/di.dart';
import '../../../core/presentation/paged_read_cubit.dart';
import '../../../core/widgets/paged_read_body.dart';
import '../../../core/widgets/teacher_action_button.dart';
import 'secretary_card.dart';
import '../domain/secretary_record.dart';

class TeacherSecretariesPage extends StatelessWidget {
  const TeacherSecretariesPage({super.key});
  @override
  Widget build(BuildContext context) => BlocProvider(
    create: (_) => PagedReadCubit<SecretaryRecord, NoSummary>(
      (_, cursor) => CompletionReads(getIt<TeacherReadClient>()).page(
        TeacherRead.secretaries,
        params: {'p_cursor': cursor, 'p_limit': 30},
        row: SecretaryRecord.fromJson,
        summary: (_) => const NoSummary(),
      ),
      (r) => r.id,
    )..refresh(),
    child: Scaffold(
      appBar: AppBar(title: Text('completion_secretaries'.tr())),
      body: SafeArea(
        child: PagedReadBody<SecretaryRecord, NoSummary>(
          loadingShape: LoadingShape.cards,
          item: (context, r) => SecretaryCard(
            record: r,
            action: r.status == 'active'
                ? TeacherActionButton(
                    label: 'completion_request_removal'.tr(),
                    confirmation: 'completion_removal_confirm'.tr(
                      args: [r.name],
                    ),
                    action: () => TeacherActions(
                      getIt<TeacherReadClient>(),
                    ).deactivateSecretary(r.id),
                    onReconcile: context
                        .read<PagedReadCubit<SecretaryRecord, NoSummary>>()
                        .refresh,
                  )
                : null,
          ),
        ),
      ),
    ),
  );
}
