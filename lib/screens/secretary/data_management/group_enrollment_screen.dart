import 'package:centrally/core/constants/strings_manager.dart';
import 'package:centrally/core/theme/color_manager.dart';
import 'package:centrally/core/theme/style_manager.dart';
import 'package:centrally/core/theme/values_manager.dart';
import 'package:centrally/mock_data/centerly_mock_data.dart';
import 'package:centrally/models/centerly_models.dart';
import 'package:centrally/screens/teacher/teacher_shared.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

class GroupEnrollmentScreen extends StatefulWidget {
  const GroupEnrollmentScreen({required this.group, super.key});

  final Group group;

  @override
  State<GroupEnrollmentScreen> createState() => _GroupEnrollmentScreenState();
}

class _GroupEnrollmentScreenState extends State<GroupEnrollmentScreen> {
  late List<Student> _enrolledStudents;

  @override
  void initState() {
    super.initState();
    _loadEnrolledStudents();
  }

  void _loadEnrolledStudents() {
    _enrolledStudents = CenterlyMockData.students
        .where((s) => s.groupId == widget.group.id)
        .toList();
  }

  void _addStudentToGroup(Student student) {
    setState(() {
      final index = CenterlyMockData.students.indexWhere(
        (s) => s.id == student.id,
      );
      if (index != -1) {
        CenterlyMockData.students[index] = Student(
          id: student.id,
          teacherId: student.teacherId,
          groupId: widget.group.id,
          name: student.name,
          phone: student.phone,
          guardianPhone: student.guardianPhone,
          levelTag: student.levelTag,
          qrCodeValue: student.qrCodeValue,
          createdAt: student.createdAt,
          teacherNote: student.teacherNote,
        );
      }
      _loadEnrolledStudents();
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(StringsManager.dataMgmtStudentEnrolled.tr())),
    );
  }

  void _removeStudentFromGroup(Student student) {
    setState(() {
      final index = CenterlyMockData.students.indexWhere(
        (s) => s.id == student.id,
      );
      if (index != -1) {
        // Change group or clear group
        CenterlyMockData.students[index] = Student(
          id: student.id,
          teacherId: student.teacherId,
          groupId: '',
          name: student.name,
          phone: student.phone,
          guardianPhone: student.guardianPhone,
          levelTag: student.levelTag,
          qrCodeValue: student.qrCodeValue,
          createdAt: student.createdAt,
          teacherNote: student.teacherNote,
        );
      }
      _loadEnrolledStudents();
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(StringsManager.dataMgmtStudentRemoved.tr())),
    );
  }

  void _showAddStudentModal() {
    final availableStudents = CenterlyMockData.students
        .where((s) => s.groupId != widget.group.id)
        .toList();

    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      backgroundColor: ColorManager.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(AppRadius.r24),
        ),
      ),
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.fromLTRB(
            AppPadding.p16,
            AppPadding.p8,
            AppPadding.p16,
            AppPadding.p24,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                StringsManager.dataMgmtEnrollStudent.tr(),
                style: AppTextStyles.headlineSmall,
              ),
              const SizedBox(height: AppSize.s16),
              if (availableStudents.isEmpty)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: AppPadding.p24),
                  child: Center(
                    child: Text(
                      'جميع الطلاب مقيدون بالفعل في هذه المجموعة',
                      style: AppTextStyles.bodyMedium.copyWith(
                        color: ColorManager.textSecondary,
                      ),
                    ),
                  ),
                )
              else
                Flexible(
                  child: ListView.separated(
                    shrinkWrap: true,
                    itemCount: availableStudents.length,
                    separatorBuilder: (_, _) => const Divider(height: 1),
                    itemBuilder: (context, index) {
                      final student = availableStudents[index];
                      return ListTile(
                        contentPadding: EdgeInsets.zero,
                        leading: const StudentAvatar(radius: AppSize.s20),
                        title: Text(
                          student.name,
                          style: AppTextStyles.titleSmall,
                        ),
                        subtitle: Text(
                          student.phone,
                          style: AppTextStyles.labelSmall,
                        ),
                        trailing: IconButton(
                          icon: const Icon(
                            Icons.add_circle_outline,
                            color: ColorManager.primary,
                          ),
                          onPressed: () {
                            Navigator.of(context).pop();
                            _addStudentToGroup(student);
                          },
                        ),
                      );
                    },
                  ),
                ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ColorManager.background,
      appBar: AppBar(
        backgroundColor: ColorManager.background,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(
            Icons.chevron_right,
            color: ColorManager.textPrimary,
          ),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          '${widget.group.name} - ${StringsManager.dataMgmtEnrollmentTitle.tr()}',
          style: AppTextStyles.headlineSmall.copyWith(
            color: ColorManager.textPrimary,
          ),
        ),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(AppPadding.p16),
            child: SizedBox(
              width: double.infinity,
              height: AppSize.s48,
              child: FilledButton.icon(
                onPressed: _showAddStudentModal,
                icon: const Icon(Icons.person_add_outlined),
                label: Text(StringsManager.dataMgmtEnrollStudent.tr()),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppPadding.p16),
            child: Row(
              children: [
                Text(
                  StringsManager.dataMgmtEnrolledStudents.tr(
                    namedArgs: {'count': '${_enrolledStudents.length}'},
                  ),
                  style: AppTextStyles.titleMedium,
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSize.s10),
          Expanded(
            child: _enrolledStudents.isEmpty
                ? Center(
                    child: Text(
                      StringsManager.dataMgmtNoEnrolledStudents.tr(),
                      style: AppTextStyles.bodyMedium.copyWith(
                        color: ColorManager.textSecondary,
                      ),
                    ),
                  )
                : ListView.separated(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppPadding.p16,
                      vertical: AppPadding.p8,
                    ),
                    itemCount: _enrolledStudents.length,
                    separatorBuilder: (_, _) =>
                        const SizedBox(height: AppSize.s10),
                    itemBuilder: (context, index) {
                      final student = _enrolledStudents[index];
                      return Container(
                        padding: const EdgeInsets.all(AppPadding.p12),
                        decoration: BoxDecoration(
                          color: ColorManager.surface,
                          borderRadius: BorderRadius.circular(AppRadius.r12),
                          border: Border.all(color: ColorManager.divider),
                        ),
                        child: Row(
                          children: [
                            const StudentAvatar(radius: AppSize.s20),
                            const SizedBox(width: AppSize.s12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    student.name,
                                    style: AppTextStyles.titleSmall,
                                  ),
                                  const SizedBox(height: AppSize.s2),
                                  Text(
                                    student.phone,
                                    style: AppTextStyles.labelSmall,
                                  ),
                                ],
                              ),
                            ),
                            IconButton(
                              icon: const Icon(
                                Icons.remove_circle_outline,
                                color: ColorManager.error,
                              ),
                              tooltip: StringsManager.dataMgmtRemoveStudent
                                  .tr(),
                              onPressed: () => _removeStudentFromGroup(student),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
