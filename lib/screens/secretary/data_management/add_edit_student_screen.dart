import 'dart:math';

import 'package:centrally/core/constants/strings_manager.dart';
import 'package:centrally/core/theme/color_manager.dart';
import 'package:centrally/core/theme/style_manager.dart';
import 'package:centrally/core/theme/values_manager.dart';
import 'package:centrally/mock_data/centerly_mock_data.dart';
import 'package:centrally/models/centerly_models.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

class AddEditStudentScreen extends StatefulWidget {
  const AddEditStudentScreen({super.key, this.student});

  final Student? student;

  @override
  State<AddEditStudentScreen> createState() => _AddEditStudentScreenState();
}

class _AddEditStudentScreenState extends State<AddEditStudentScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameController;
  late final TextEditingController _phoneController;
  late final TextEditingController _guardianPhoneController;
  late final TextEditingController _levelTagController;
  String? _selectedGroupId;
  late String _qrCode;

  bool get _isEditing => widget.student != null;

  @override
  void initState() {
    super.initState();
    final student = widget.student;
    _nameController = TextEditingController(text: student?.name ?? '');
    _phoneController = TextEditingController(text: student?.phone ?? '');
    _guardianPhoneController = TextEditingController(
      text: student?.guardianPhone ?? '',
    );
    _levelTagController = TextEditingController(text: student?.levelTag ?? '');
    _selectedGroupId =
        student?.groupId ??
        (CenterlyMockData.groups.isNotEmpty
            ? CenterlyMockData.groups.first.id
            : null);
    _qrCode = student?.qrCodeValue ?? '${Random().nextInt(90000) + 10000}';
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _guardianPhoneController.dispose();
    _levelTagController.dispose();
    super.dispose();
  }

  void _saveStudent() {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedGroupId == null) return;

    if (_isEditing) {
      final index = CenterlyMockData.students.indexWhere(
        (s) => s.id == widget.student!.id,
      );
      if (index != -1) {
        CenterlyMockData.students[index] = Student(
          id: widget.student!.id,
          teacherId: widget.student!.teacherId,
          groupId: _selectedGroupId!,
          name: _nameController.text.trim(),
          phone: _phoneController.text.trim(),
          guardianPhone: _guardianPhoneController.text.trim(),
          levelTag: _levelTagController.text.trim().isEmpty
              ? 'الصف الأول الثانوي'
              : _levelTagController.text.trim(),
          qrCodeValue: _qrCode,
          createdAt: widget.student!.createdAt,
          teacherNote: widget.student!.teacherNote,
        );
      }
    } else {
      final newStudent = Student(
        id: 'student-${DateTime.now().millisecondsSinceEpoch}',
        teacherId: 'teacher-1',
        groupId: _selectedGroupId!,
        name: _nameController.text.trim(),
        phone: _phoneController.text.trim(),
        guardianPhone: _guardianPhoneController.text.trim(),
        levelTag: _levelTagController.text.trim().isEmpty
            ? 'الصف الأول الثانوي'
            : _levelTagController.text.trim(),
        qrCodeValue: _qrCode,
        createdAt: DateTime.now(),
      );
      CenterlyMockData.students.add(newStudent);
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(StringsManager.dataMgmtStudentSaved.tr())),
    );
    Navigator.of(context).pop(true);
  }

  @override
  Widget build(BuildContext context) {
    final title = _isEditing
        ? StringsManager.dataMgmtEditStudentTitle.tr()
        : StringsManager.dataMgmtAddStudentTitle.tr();

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
          title,
          style: AppTextStyles.headlineSmall.copyWith(
            color: ColorManager.textPrimary,
          ),
        ),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(AppPadding.p16),
          children: [
            _FormFieldCard(
              label: StringsManager.dataMgmtStudentName.tr(),
              child: TextFormField(
                controller: _nameController,
                decoration: InputDecoration(
                  hintText: StringsManager.dataMgmtStudentNameHint.tr(),
                  fillColor: ColorManager.grey200,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(AppRadius.r8),
                    borderSide: BorderSide.none,
                  ),
                ),
                validator: (val) => val == null || val.trim().isEmpty
                    ? StringsManager.validationRequired.tr()
                    : null,
              ),
            ),
            const SizedBox(height: AppSize.s14),
            _FormFieldCard(
              label: StringsManager.dataMgmtPhone.tr(),
              child: TextFormField(
                controller: _phoneController,
                keyboardType: TextInputType.phone,
                decoration: InputDecoration(
                  hintText: StringsManager.dataMgmtPhoneHint.tr(),
                  fillColor: ColorManager.grey200,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(AppRadius.r8),
                    borderSide: BorderSide.none,
                  ),
                ),
                validator: (val) => val == null || val.trim().isEmpty
                    ? StringsManager.validationRequired.tr()
                    : null,
              ),
            ),
            const SizedBox(height: AppSize.s14),
            _FormFieldCard(
              label: StringsManager.dataMgmtGuardianPhone.tr(),
              child: TextFormField(
                controller: _guardianPhoneController,
                keyboardType: TextInputType.phone,
                decoration: InputDecoration(
                  hintText: StringsManager.dataMgmtPhoneHint.tr(),
                  fillColor: ColorManager.grey200,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(AppRadius.r8),
                    borderSide: BorderSide.none,
                  ),
                ),
                validator: (val) => val == null || val.trim().isEmpty
                    ? StringsManager.validationRequired.tr()
                    : null,
              ),
            ),
            const SizedBox(height: AppSize.s14),
            _FormFieldCard(
              label: StringsManager.dataMgmtLevelTag.tr(),
              child: TextFormField(
                controller: _levelTagController,
                decoration: InputDecoration(
                  hintText: StringsManager.dataMgmtLevelTagHint.tr(),
                  fillColor: ColorManager.grey200,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(AppRadius.r8),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
            ),
            const SizedBox(height: AppSize.s14),
            _FormFieldCard(
              label: StringsManager.dataMgmtGroupSelect.tr(),
              child: DropdownButtonFormField<String>(
                initialValue: _selectedGroupId,
                decoration: InputDecoration(
                  fillColor: ColorManager.grey200,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(AppRadius.r8),
                    borderSide: BorderSide.none,
                  ),
                ),
                items: CenterlyMockData.groups.map((group) {
                  return DropdownMenuItem<String>(
                    value: group.id,
                    child: Text('${group.name} - ${group.subjectName}'),
                  );
                }).toList(),
                onChanged: (val) => setState(() => _selectedGroupId = val),
              ),
            ),
            const SizedBox(height: AppSize.s14),
            _FormFieldCard(
              label: StringsManager.dataMgmtQrCode.tr(),
              child: Container(
                padding: const EdgeInsets.all(AppPadding.p12),
                decoration: BoxDecoration(
                  color: ColorManager.grey200,
                  borderRadius: BorderRadius.circular(AppRadius.r8),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.qr_code, color: ColorManager.primary),
                    const SizedBox(width: AppSize.s10),
                    Text('#$_qrCode', style: AppTextStyles.titleMedium),
                    const Spacer(),
                    IconButton(
                      icon: const Icon(
                        Icons.refresh,
                        color: ColorManager.grey500,
                      ),
                      onPressed: () {
                        setState(() {
                          _qrCode = '${Random().nextInt(90000) + 10000}';
                        });
                      },
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: AppSize.s24),
            SizedBox(
              width: double.infinity,
              height: AppSize.s48,
              child: FilledButton(
                onPressed: _saveStudent,
                child: Text(StringsManager.dataMgmtSaveStudent.tr()),
              ),
            ),
            const SizedBox(height: AppSize.s20),
          ],
        ),
      ),
    );
  }
}

class _FormFieldCard extends StatelessWidget {
  const _FormFieldCard({required this.label, required this.child});

  final String label;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppPadding.p14),
      decoration: BoxDecoration(
        color: ColorManager.surface,
        borderRadius: BorderRadius.circular(AppRadius.r12),
        border: Border.all(color: ColorManager.divider),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: AppTextStyles.titleSmall),
          const SizedBox(height: AppSize.s8),
          child,
        ],
      ),
    );
  }
}
