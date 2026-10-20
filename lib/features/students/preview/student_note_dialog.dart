import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

class StudentNoteDialog extends StatefulWidget {
  const StudentNoteDialog({required this.initialText, super.key});
  final String initialText;
  @override
  State<StudentNoteDialog> createState() => _StudentNoteDialogState();
}

class _StudentNoteDialogState extends State<StudentNoteDialog> {
  late final _text = TextEditingController(text: widget.initialText);
  final _form = GlobalKey<FormState>();
  @override
  void dispose() {
    _text.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => AlertDialog(
    scrollable: true,
    title: Text('student_design_edit_note'.tr()),
    content: Form(
      key: _form,
      child: TextFormField(
        controller: _text,
        minLines: 3,
        maxLines: 8,
        maxLength: 2000,
        validator: (v) => v == null || v.trim().isEmpty
            ? 'student_design_note_required'.tr()
            : null,
      ),
    ),
    actions: [
      TextButton(
        onPressed: () => Navigator.of(context).pop(),
        child: Text('student_design_cancel'.tr()),
      ),
      FilledButton(
        onPressed: () {
          if (_form.currentState!.validate()) {
            Navigator.of(context).pop(_text.text.trim());
          }
        },
        child: Text('student_design_save'.tr()),
      ),
    ],
  );
}
