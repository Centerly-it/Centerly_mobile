import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'student_note_editor.dart';

class StudentNoteFields extends StatelessWidget {
  const StudentNoteFields({
    required this.editor,
    required this.refresh,
    this.readOnly = false,
    super.key,
  });
  final StudentNoteEditor editor;
  final Future<void> Function() refresh;
  final bool readOnly;
  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.stretch,
    children: [
      if (readOnly) Text('design_read_only'.tr()),
      TextField(
        readOnly: readOnly,
        controller: editor.text,
        enabled: !editor.busy,
        maxLength: 10000,
        minLines: 5,
        maxLines: 12,
        decoration: InputDecoration(labelText: 'completion_notes'.tr()),
        onChanged: (_) => editor.changed(),
      ),
      if (editor.error != null) Text('live_error_${editor.error}'.tr()),
      if (editor.mustReload) Text('completion_note_reconcile'.tr()),
      if (!readOnly)
        FilledButton(
          onPressed: editor.busy || !editor.dirty || editor.mustReload
              ? null
              : editor.save,
          child: Text('completion_save'.tr()),
        ),
      TextButton(
        onPressed: editor.busy ? null : refresh,
        child: Text('detail_refresh'.tr()),
      ),
    ],
  );
}
