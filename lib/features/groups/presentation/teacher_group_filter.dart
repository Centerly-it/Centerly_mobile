import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'teacher_group_picker.dart';

class TeacherGroupFilter extends StatefulWidget {
  const TeacherGroupFilter({
    required this.onChanged,
    this.onArchived,
    this.archived = false,
    super.key,
  });
  final VoidCallback? onArchived;
  final bool archived;
  final ValueChanged<String?> onChanged;
  @override
  State<TeacherGroupFilter> createState() => _TeacherGroupFilterState();
}

class _TeacherGroupFilterState extends State<TeacherGroupFilter> {
  String? label;
  @override
  Widget build(BuildContext context) => TextButton.icon(
    icon: const Icon(Icons.filter_list),
    label: Text(
      widget.archived
          ? 'completion_archived_students'.tr()
          : label ?? 'completion_all_groups'.tr(),
    ),
    onPressed: () async {
      final result = await showTeacherGroupPicker(
        context,
        allowArchived: widget.onArchived != null,
        archived: widget.archived,
      );
      if (result != null && mounted) {
        setState(() => label = result.group?.name);
        if (result.archived) {
          widget.onArchived?.call();
        } else {
          widget.onChanged(result.group?.id);
        }
      }
    },
  );
}
