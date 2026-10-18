import 'package:centrally/core/constants/strings_manager.dart';
import 'package:centrally/core/theme/color_manager.dart';
import 'package:centrally/core/theme/style_manager.dart';
import 'package:centrally/core/theme/values_manager.dart';
import 'package:centrally/mock_data/centerly_mock_data.dart';
import 'package:centrally/models/centerly_models.dart';
import 'package:centrally/screens/teacher/teacher_shared.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

class EnterGradesAssignmentsScreen extends StatefulWidget {
  const EnterGradesAssignmentsScreen({super.key, this.preselectedGroupId});

  final String? preselectedGroupId;

  @override
  State<EnterGradesAssignmentsScreen> createState() =>
      _EnterGradesAssignmentsScreenState();
}

class _EnterGradesAssignmentsScreenState
    extends State<EnterGradesAssignmentsScreen>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;
  late String _selectedGroupId;
  late final TextEditingController _examTitleController;
  late final TextEditingController _assignmentTitleController;

  // Student Score Map {studentId: scoreText}
  final Map<String, TextEditingController> _scoreControllers = {};
  // Student Assignment Status Map {studentId: AssignmentStatus}
  final Map<String, AssignmentStatus> _assignmentStatuses = {};

  List<Student> get _groupStudents => CenterlyMockData.students
      .where((s) => s.groupId == _selectedGroupId)
      .toList();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _selectedGroupId =
        widget.preselectedGroupId ??
        (CenterlyMockData.groups.isNotEmpty
            ? CenterlyMockData.groups.first.id
            : 'group-1');
    _examTitleController = TextEditingController(text: 'اختبار شهر أبريل');
    _assignmentTitleController = TextEditingController(
      text: 'واجب الدرس الثالث',
    );
    _initStudentControllers();
  }

  void _initStudentControllers() {
    for (final s in _groupStudents) {
      _scoreControllers[s.id] = TextEditingController(text: '85');
      _assignmentStatuses[s.id] = AssignmentStatus.submitted;
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    _examTitleController.dispose();
    _assignmentTitleController.dispose();
    for (final controller in _scoreControllers.values) {
      controller.dispose();
    }
    super.dispose();
  }

  void _saveGrades() {
    final title = _examTitleController.text.trim();
    for (final student in _groupStudents) {
      final score =
          int.tryParse(_scoreControllers[student.id]?.text.trim() ?? '85') ??
          85;
      CenterlyMockData.exams.add(
        Exam(
          id: 'exam-${DateTime.now().millisecondsSinceEpoch}-${student.id}',
          teacherId: 'teacher-1',
          studentId: student.id,
          groupId: _selectedGroupId,
          title: title.isEmpty ? 'اختبار جديد' : title,
          date: DateTime.now(),
          scorePercent: score,
          enteredBy: 'secretary-1',
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        ),
      );
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(StringsManager.dataMgmtGradesSaved.tr())),
    );
    Navigator.of(context).pop(true);
  }

  void _saveAssignments() {
    final title = _assignmentTitleController.text.trim();
    for (final student in _groupStudents) {
      final status =
          _assignmentStatuses[student.id] ?? AssignmentStatus.submitted;
      CenterlyMockData.assignments.add(
        Assignment(
          id: 'assign-${DateTime.now().millisecondsSinceEpoch}-${student.id}',
          teacherId: 'teacher-1',
          studentId: student.id,
          groupId: _selectedGroupId,
          title: title.isEmpty ? 'واجب جديد' : title,
          date: DateTime.now(),
          status: status,
          enteredBy: 'secretary-1',
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        ),
      );
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(StringsManager.dataMgmtGradesSaved.tr())),
    );
    Navigator.of(context).pop(true);
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
          StringsManager.dataMgmtGradesAssignmentsTitle.tr(),
          style: AppTextStyles.headlineSmall.copyWith(
            color: ColorManager.textPrimary,
          ),
        ),
        bottom: TabBar(
          controller: _tabController,
          labelColor: ColorManager.primary,
          unselectedLabelColor: ColorManager.textSecondary,
          indicatorColor: ColorManager.primary,
          labelStyle: AppTextStyles.titleSmall,
          tabs: [
            Tab(text: StringsManager.dataMgmtTabExams.tr()),
            Tab(text: StringsManager.dataMgmtTabAssignments.tr()),
          ],
        ),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(
              AppPadding.p16,
              AppPadding.p12,
              AppPadding.p16,
              AppPadding.p4,
            ),
            child: Container(
              padding: const EdgeInsets.symmetric(
                horizontal: AppPadding.p14,
                vertical: AppPadding.p4,
              ),
              decoration: BoxDecoration(
                color: ColorManager.surface,
                borderRadius: BorderRadius.circular(AppRadius.r12),
                border: Border.all(color: ColorManager.divider),
              ),
              child: Row(
                children: [
                  Text(
                    StringsManager.dataMgmtGroupSelect.tr(),
                    style: AppTextStyles.titleSmall,
                  ),
                  const SizedBox(width: AppSize.s12),
                  Expanded(
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<String>(
                        value: _selectedGroupId,
                        items: CenterlyMockData.groups.map((group) {
                          return DropdownMenuItem<String>(
                            value: group.id,
                            child: Text('${group.name} - ${group.subjectName}'),
                          );
                        }).toList(),
                        onChanged: (val) {
                          if (val != null) {
                            setState(() {
                              _selectedGroupId = val;
                              _initStudentControllers();
                            });
                          }
                        },
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [_buildExamsTab(), _buildAssignmentsTab()],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildExamsTab() {
    final students = _groupStudents;

    return ListView(
      padding: const EdgeInsets.all(AppPadding.p16),
      children: [
        Container(
          padding: const EdgeInsets.all(AppPadding.p14),
          decoration: BoxDecoration(
            color: ColorManager.surface,
            borderRadius: BorderRadius.circular(AppRadius.r12),
            border: Border.all(color: ColorManager.divider),
          ),
          child: TextField(
            controller: _examTitleController,
            decoration: InputDecoration(
              labelText: StringsManager.dataMgmtExamTitle.tr(),
              hintText: StringsManager.dataMgmtExamTitleHint.tr(),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(AppRadius.r8),
              ),
            ),
          ),
        ),
        const SizedBox(height: AppSize.s16),
        for (final student in students) ...[
          Container(
            padding: const EdgeInsets.all(AppPadding.p12),
            margin: const EdgeInsets.only(bottom: AppPadding.p10),
            decoration: BoxDecoration(
              color: ColorManager.surface,
              borderRadius: BorderRadius.circular(AppRadius.r12),
              border: Border.all(color: ColorManager.divider),
            ),
            child: Row(
              children: [
                const StudentAvatar(radius: AppSize.s18),
                const SizedBox(width: AppSize.s10),
                Expanded(
                  child: Text(student.name, style: AppTextStyles.titleSmall),
                ),
                SizedBox(
                  width: AppSize.s80,
                  child: TextField(
                    controller: _scoreControllers[student.id],
                    keyboardType: TextInputType.number,
                    textAlign: TextAlign.center,
                    decoration: InputDecoration(
                      hintText: StringsManager.dataMgmtScoreHint.tr(),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: AppPadding.p8,
                        vertical: AppPadding.p8,
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(AppRadius.r8),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
        const SizedBox(height: AppSize.s16),
        SizedBox(
          width: double.infinity,
          height: AppSize.s48,
          child: FilledButton(
            onPressed: _saveGrades,
            child: Text(StringsManager.dataMgmtSaveAll.tr()),
          ),
        ),
      ],
    );
  }

  Widget _buildAssignmentsTab() {
    final students = _groupStudents;

    return ListView(
      padding: const EdgeInsets.all(AppPadding.p16),
      children: [
        Container(
          padding: const EdgeInsets.all(AppPadding.p14),
          decoration: BoxDecoration(
            color: ColorManager.surface,
            borderRadius: BorderRadius.circular(AppRadius.r12),
            border: Border.all(color: ColorManager.divider),
          ),
          child: TextField(
            controller: _assignmentTitleController,
            decoration: InputDecoration(
              labelText: StringsManager.dataMgmtAssignmentTitle.tr(),
              hintText: StringsManager.dataMgmtAssignmentTitleHint.tr(),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(AppRadius.r8),
              ),
            ),
          ),
        ),
        const SizedBox(height: AppSize.s16),
        for (final student in students) ...[
          Container(
            padding: const EdgeInsets.all(AppPadding.p12),
            margin: const EdgeInsets.only(bottom: AppPadding.p10),
            decoration: BoxDecoration(
              color: ColorManager.surface,
              borderRadius: BorderRadius.circular(AppRadius.r12),
              border: Border.all(color: ColorManager.divider),
            ),
            child: Row(
              children: [
                const StudentAvatar(radius: AppSize.s18),
                const SizedBox(width: AppSize.s10),
                Expanded(
                  child: Text(student.name, style: AppTextStyles.titleSmall),
                ),
                DropdownButton<AssignmentStatus>(
                  value:
                      _assignmentStatuses[student.id] ??
                      AssignmentStatus.submitted,
                  underline: const SizedBox.shrink(),
                  items: [
                    DropdownMenuItem(
                      value: AssignmentStatus.submitted,
                      child: Text(
                        StringsManager.assignmentSubmitted.tr(),
                        style: const TextStyle(color: ColorManager.success),
                      ),
                    ),
                    DropdownMenuItem(
                      value: AssignmentStatus.late,
                      child: Text(
                        StringsManager.assignmentLate.tr(),
                        style: const TextStyle(color: ColorManager.warning),
                      ),
                    ),
                    DropdownMenuItem(
                      value: AssignmentStatus.pending,
                      child: Text(
                        StringsManager.assignmentPending.tr(),
                        style: const TextStyle(color: ColorManager.error),
                      ),
                    ),
                  ],
                  onChanged: (status) {
                    if (status != null) {
                      setState(() => _assignmentStatuses[student.id] = status);
                    }
                  },
                ),
              ],
            ),
          ),
        ],
        const SizedBox(height: AppSize.s16),
        SizedBox(
          width: double.infinity,
          height: AppSize.s48,
          child: FilledButton(
            onPressed: _saveAssignments,
            child: Text(StringsManager.dataMgmtSaveAll.tr()),
          ),
        ),
      ],
    );
  }
}
