import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/api/teacher_read_client.dart';
import '../../../core/di/di.dart';
import '../../../core/data/completion_contracts.dart';
import '../../../core/presentation/paged_read_cubit.dart';
import '../../../core/widgets/paged_read_body.dart';
import '../../../core/format/cairo_time.dart';
import 'student_membership_card.dart';
import '../data/student_profile_repository.dart';
import '../domain/student_membership.dart';
import '../domain/student_record.dart';
import 'design/student_identity.dart';
import 'design/student_contact_info.dart';
import 'design/student_profile_tabs.dart';
import '../../academics/presentation/student_academics_page.dart';
import '../../attendance/presentation/student_attendance_page.dart';
import '../../finances/presentation/teacher_finance_page.dart';
import 'student_feature_links.dart';

class StudentProfilePage extends StatefulWidget {
  const StudentProfilePage({required this.studentId, super.key});
  final String studentId;
  @override
  State<StudentProfilePage> createState() => _StudentProfilePageState();
}

class _StudentProfilePageState extends State<StudentProfilePage> {
  int tab = 0;
  String get studentId => widget.studentId;
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
        child: Column(
          children: [
            if (CompletionContracts.enabled)
              StudentProfileTabs(
                index: tab,
                onChanged: (v) => setState(() => tab = v),
              ),
            Expanded(
              child: tab == 1
                  ? StudentAttendancePage(
                      studentId: studentId,
                      initialDate: CairoTime.local(DateTime.now()),
                      embedded: true,
                    )
                  : tab == 2
                  ? StudentAcademicsPage(
                      studentId: studentId,
                      initialDate: CairoTime.local(DateTime.now()),
                      embedded: true,
                    )
                  : tab == 3
                  ? TeacherFinancePage(
                      studentId: studentId,
                      initialDate: CairoTime.local(DateTime.now()),
                      embedded: true,
                    )
                  : PagedReadBody<StudentMembership, StudentRecord>(
                      header: (context, page) => Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          StudentIdentity(record: page.summary, large: true),
                          StudentContactInfo(student: page.summary),
                          Text('student_qr_deferred'.tr()),
                          SelectableText(page.summary.id),
                          if (CompletionContracts.enabled)
                            StudentFeatureLinks(
                              studentId: studentId,
                              initialDate: CairoTime.local(page.syncedAt),
                            ),
                          Text('completion_memberships'.tr()),
                        ],
                      ),
                      item: (context, row) => StudentMembershipCard(row: row),
                    ),
            ),
          ],
        ),
      ),
    ),
  );
}
