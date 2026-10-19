import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/di/di.dart';
import '../../../core/theme/values_manager.dart';
import '../../../core/widgets/app_empty_state.dart';
import '../../../core/widgets/app_error_state.dart';
import '../../../core/widgets/server_search_field.dart';
import '../data/student_repository.dart';
import 'student_browse_cubit.dart';
import 'student_browse_state.dart';
import 'student_read_card.dart';

class StudentDirectory extends StatelessWidget {
  const StudentDirectory({this.groupId, this.groupName, super.key});
  final String? groupId, groupName;
  @override
  Widget build(BuildContext context) => BlocProvider(
    create: (_) =>
        StudentBrowseCubit(getIt<StudentRepository>(), groupId: groupId)
          ..search(''),
    child: Scaffold(
      appBar: AppBar(title: Text(groupName ?? 'live_students'.tr())),
      body: const SafeArea(top: false, child: _StudentDirectoryBody()),
    ),
  );
}

class _StudentDirectoryBody extends StatelessWidget {
  const _StudentDirectoryBody();
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
                              StudentReadCard(student: student),
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
