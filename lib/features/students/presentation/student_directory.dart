import 'student_directory_body.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/di/di.dart';
import '../data/student_repository.dart';
import 'student_browse_cubit.dart';

class StudentDirectory extends StatelessWidget {
  const StudentDirectory({
    this.groupId,
    this.groupName,
    this.embedded = false,
    super.key,
  });
  final String? groupId, groupName;
  final bool embedded;
  @override
  Widget build(BuildContext context) => BlocProvider(
    create: (_) =>
        StudentBrowseCubit(getIt<StudentRepository>(), groupId: groupId)
          ..search(''),
    child: embedded
        ? const StudentDirectoryBody(showGroupFilter: true)
        : Scaffold(
            appBar: AppBar(title: Text(groupName ?? 'live_students'.tr())),
            body: const SafeArea(top: false, child: StudentDirectoryBody()),
          ),
  );
}
