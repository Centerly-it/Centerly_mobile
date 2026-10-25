import '../../../core/widgets/read_directory_list.dart';
import '../../groups/presentation/teacher_group_filter.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
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
              if (showGroupFilter)
                TeacherGroupFilter(
                  onChanged: cubit.filterGroup,
                  archived: cubit.archived,
                  onArchived: () => cubit.showArchived(true),
                ),
              Expanded(
                child: ReadDirectoryList(
                  count: state.students.length,
                  loading: state.loading,
                  error: state.error != null,
                  hasMore: state.cursor != null,
                  retryMore: state.retryMore,
                  refresh: cubit.refresh,
                  next: cubit.next,
                  emptyTitle: 'live_no_students',
                  emptyHint: 'groups_empty_subtitle',
                  item: (context, index) {
                    final student = state.students[index];
                    return StudentDirectoryRow(
                      key: ValueKey(student.id),
                      record: student,
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute<void>(
                          builder: (_) =>
                              StudentProfilePage(studentId: student.id),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          );
        },
      );
}
