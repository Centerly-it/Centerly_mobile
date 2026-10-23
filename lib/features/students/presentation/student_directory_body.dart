import '../../groups/presentation/teacher_group_filter.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/theme/values_manager.dart';
import '../../../core/widgets/app_empty_state.dart';
import '../../../core/widgets/app_error_state.dart';
import '../../../core/widgets/server_search_field.dart';
import 'student_browse_cubit.dart';
import 'student_browse_state.dart';
import 'design/student_directory_row.dart';
import 'student_profile_page.dart';

class StudentDirectoryBody extends StatelessWidget {
  const StudentDirectoryBody({this.showGroupFilter = false, super.key});
  final bool showGroupFilter;
  @override
  Widget build(BuildContext context) =>
      BlocBuilder<StudentBrowseCubit, StudentBrowseState>(
        builder: (context, state) {
          final cubit = context.read<StudentBrowseCubit>();
          return Column(
            children: [
              ServerSearchField(
                label: 'live_student_search'.tr(),
                onSubmitted: cubit.search,
              ),
              SwitchListTile(
                title: Text('completion_archived_students'.tr()),
                value: cubit.archived,
                onChanged: cubit.showArchived,
              ),
              if (showGroupFilter && !cubit.archived)
                TeacherGroupFilter(onChanged: cubit.filterGroup),
              Expanded(
                child: state.loading && state.students.isEmpty
                    ? Center(
                        child: CircularProgressIndicator(
                          semanticsLabel: 'loading_data'.tr(),
                        ),
                      )
                    : RefreshIndicator(
                        onRefresh: cubit.refresh,
                        child: ListView(
                          physics: const AlwaysScrollableScrollPhysics(),
                          padding: const EdgeInsets.all(AppPadding.p16),
                          children: [
                            for (final student in state.students)
                              StudentDirectoryRow(
                                record: student,
                                onTap: () => Navigator.push(
                                  context,
                                  MaterialPageRoute<void>(
                                    builder: (_) => StudentProfilePage(
                                      studentId: student.id,
                                    ),
                                  ),
                                ),
                              ),
                            if (state.error != null)
                              AppErrorState(
                                onRetry: state.students.isEmpty
                                    ? cubit.refresh
                                    : cubit.next,
                              ),
                            if (state.students.isEmpty && state.error == null)
                              AppEmptyState(
                                title: 'live_no_students'.tr(),
                                subtitle: 'groups_empty_subtitle'.tr(),
                              ),
                            if (state.cursor != null && state.error == null)
                              TextButton(
                                onPressed: state.loading ? null : cubit.next,
                                child: Text(
                                  (state.loading
                                          ? 'loading_data'
                                          : 'live_load_more')
                                      .tr(),
                                ),
                              ),
                          ],
                        ),
                      ),
              ),
            ],
          );
        },
      );
}
