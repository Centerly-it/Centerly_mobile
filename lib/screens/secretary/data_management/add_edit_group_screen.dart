import 'package:centrally/core/constants/strings_manager.dart';
import 'package:centrally/core/theme/color_manager.dart';
import 'package:centrally/core/theme/style_manager.dart';
import 'package:centrally/core/theme/values_manager.dart';
import 'package:centrally/mock_data/centerly_mock_data.dart';
import 'package:centrally/models/centerly_models.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

class AddEditGroupScreen extends StatefulWidget {
  const AddEditGroupScreen({super.key, this.group});

  final Group? group;

  @override
  State<AddEditGroupScreen> createState() => _AddEditGroupScreenState();
}

class _AddEditGroupScreenState extends State<AddEditGroupScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameController;
  late final TextEditingController _subjectController;
  late final TextEditingController _capacityController;
  late final TextEditingController _scheduleController;
  String _selectedGradeLevel = 'الصف الأول الثانوي';

  bool get _isEditing => widget.group != null;

  @override
  void initState() {
    super.initState();
    final group = widget.group;
    _nameController = TextEditingController(text: group?.name ?? '');
    _subjectController = TextEditingController(text: group?.subjectName ?? '');
    _capacityController = TextEditingController(
      text: group?.capacity.toString() ?? '30',
    );
    _scheduleController = TextEditingController(
      text: group?.scheduleLabel ?? 'السبت - الثلاثاء',
    );
    _selectedGradeLevel = group?.gradeLevelName ?? 'الصف الأول الثانوي';
  }

  @override
  void dispose() {
    _nameController.dispose();
    _subjectController.dispose();
    _capacityController.dispose();
    _scheduleController.dispose();
    super.dispose();
  }

  void _saveGroup() {
    if (!_formKey.currentState!.validate()) return;

    final capacity = int.tryParse(_capacityController.text.trim()) ?? 30;

    if (_isEditing) {
      final index = CenterlyMockData.groups.indexWhere(
        (g) => g.id == widget.group!.id,
      );
      if (index != -1) {
        CenterlyMockData.groups[index] = Group(
          id: widget.group!.id,
          teacherId: widget.group!.teacherId,
          gradeLevelId: widget.group!.gradeLevelId,
          gradeLevelName: _selectedGradeLevel,
          name: _nameController.text.trim(),
          subjectName: _subjectController.text.trim(),
          capacity: capacity,
          scheduleLabel: _scheduleController.text.trim(),
          nextSessionAt: widget.group!.nextSessionAt,
          createdAt: widget.group!.createdAt,
        );
      }
    } else {
      final newGroup = Group(
        id: 'group-${DateTime.now().millisecondsSinceEpoch}',
        teacherId: 'teacher-1',
        gradeLevelId: 'grade-${DateTime.now().millisecondsSinceEpoch}',
        gradeLevelName: _selectedGradeLevel,
        name: _nameController.text.trim(),
        subjectName: _subjectController.text.trim(),
        capacity: capacity,
        scheduleLabel: _scheduleController.text.trim(),
        nextSessionAt: DateTime.now().add(const Duration(days: 2)),
        createdAt: DateTime.now(),
      );
      CenterlyMockData.groups.add(newGroup);
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(StringsManager.dataMgmtGroupSaved.tr())),
    );
    Navigator.of(context).pop(true);
  }

  @override
  Widget build(BuildContext context) {
    final title = _isEditing
        ? StringsManager.dataMgmtEditGroupTitle.tr()
        : StringsManager.dataMgmtAddGroupTitle.tr();

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
              label: StringsManager.dataMgmtGroupName.tr(),
              child: TextFormField(
                controller: _nameController,
                decoration: InputDecoration(
                  hintText: StringsManager.dataMgmtGroupNameHint.tr(),
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
              label: StringsManager.dataMgmtSubjectName.tr(),
              child: TextFormField(
                controller: _subjectController,
                decoration: InputDecoration(
                  hintText: StringsManager.dataMgmtSubjectNameHint.tr(),
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
              label: StringsManager.dataMgmtGradeLevel.tr(),
              child: DropdownButtonFormField<String>(
                initialValue: _selectedGradeLevel,
                decoration: InputDecoration(
                  fillColor: ColorManager.grey200,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(AppRadius.r8),
                    borderSide: BorderSide.none,
                  ),
                ),
                items: const [
                  DropdownMenuItem(
                    value: 'الصف الأول الثانوي',
                    child: Text('الصف الأول الثانوي'),
                  ),
                  DropdownMenuItem(
                    value: 'الصف الثاني الثانوي',
                    child: Text('الصف الثاني الثانوي'),
                  ),
                  DropdownMenuItem(
                    value: 'الصف الثالث الثانوي',
                    child: Text('الصف الثالث الثانوي'),
                  ),
                ],
                onChanged: (val) {
                  if (val != null) {
                    setState(() => _selectedGradeLevel = val);
                  }
                },
              ),
            ),
            const SizedBox(height: AppSize.s14),
            _FormFieldCard(
              label: StringsManager.dataMgmtCapacity.tr(),
              child: TextFormField(
                controller: _capacityController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  hintText: StringsManager.dataMgmtCapacityHint.tr(),
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
              label: StringsManager.dataMgmtScheduleDays.tr(),
              child: TextFormField(
                controller: _scheduleController,
                decoration: InputDecoration(
                  hintText: StringsManager.dataMgmtScheduleHint.tr(),
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
            const SizedBox(height: AppSize.s24),
            SizedBox(
              width: double.infinity,
              height: AppSize.s48,
              child: FilledButton(
                onPressed: _saveGroup,
                child: Text(StringsManager.dataMgmtSaveGroup.tr()),
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
