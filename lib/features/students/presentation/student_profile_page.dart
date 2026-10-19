import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/api/teacher_read_client.dart';
import '../../../core/di/di.dart';
import '../../../core/data/completion_contracts.dart';
import '../../../core/presentation/paged_read_cubit.dart';
import '../../../core/widgets/paged_read_body.dart';
import '../../../core/format/cairo_time.dart';
import '../../../screens/teacher/teacher_shared.dart';
import '../data/student_profile_repository.dart';
import '../domain/student_membership.dart';
import '../domain/student_record.dart';
import 'student_read_card.dart';
import 'student_feature_links.dart';

class StudentProfilePage extends StatelessWidget {
  const StudentProfilePage({required this.studentId, super.key});
  final String studentId;
  @override
  Widget build(BuildContext context) => BlocProvider(
    create: (_) => PagedReadCubit<StudentMembership, StudentRecord>(
      (_, cursor) => StudentProfileRepository(
        getIt<TeacherReadClient>(),
      ).load(studentId, cursor: cursor),
      (row) => row.id,
    )..refresh(),
    child: Scaffold(
      appBar: AppBar(title: Text('completion_profile'.tr())),
      body: SafeArea(
        child: PagedReadBody<StudentMembership, StudentRecord>(
          header: (context, page) => Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              StudentReadCard(student: page.summary),
              if (CompletionContracts.enabled)
                StudentFeatureLinks(
                  studentId: studentId,
                  initialDate: CairoTime.local(page.syncedAt),
                ),
              Text('completion_memberships'.tr()),
            ],
          ),
          item: (context, row) => TeacherCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  row.groupName,
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                Text('${row.subject} · ${row.grade}'),
                Text('completion_${row.status}'.tr()),
                Text(
                  'completion_joined'.tr(
                    args: [CairoTime.date(CairoTime.local(row.joinedAt))],
                  ),
                ),
                if (row.leftAt != null)
                  Text(
                    'completion_left'.tr(
                      args: [CairoTime.date(CairoTime.local(row.leftAt!))],
                    ),
                  ),
                if (row.archivedAt != null)
                  Text('completion_archived_group'.tr()),
              ],
            ),
          ),
        ),
      ),
    ),
  );
}
