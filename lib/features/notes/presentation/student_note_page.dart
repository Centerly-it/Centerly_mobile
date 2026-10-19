import 'confirm_note_discard.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import '../../../core/api/teacher_read_client.dart';
import '../../../core/di/di.dart';
import '../../../core/theme/values_manager.dart';
import '../../../core/widgets/app_error_state.dart';
import '../data/student_note_repository.dart';
import 'student_note_editor.dart';

class StudentNotePage extends StatefulWidget {
  const StudentNotePage({required this.studentId, super.key});
  final String studentId;
  @override
  State<StudentNotePage> createState() => _StudentNotePageState();
}

class _StudentNotePageState extends State<StudentNotePage> {
  late final editor = StudentNoteEditor(
    StudentNoteRepository(getIt<TeacherReadClient>()),
    widget.studentId,
  );
  bool exiting = false;
  @override
  void initState() {
    super.initState();
    editor.load();
  }

  @override
  void dispose() {
    editor.dispose();
    super.dispose();
  }

  Future<bool> confirmDiscard() async =>
      !editor.dirty || await confirmNoteDiscard(context);
  @override
  Widget build(BuildContext context) => ListenableBuilder(
    listenable: editor,
    builder: (context, _) => PopScope(
      canPop: exiting || (!editor.dirty && !editor.busy),
      onPopInvokedWithResult: (didPop, _) async {
        if (didPop || editor.busy) return;
        if (await confirmDiscard() && mounted) {
          setState(() => exiting = true);
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (mounted) Navigator.pop(context);
          });
        }
      },
      child: Scaffold(
        appBar: AppBar(title: Text('completion_notes'.tr())),
        body: SafeArea(
          child: ListView(
            padding: const EdgeInsets.all(AppPadding.p16),
            children: [
              if (editor.busy) const LinearProgressIndicator(),
              if (editor.failed && editor.saved == null)
                AppErrorState(onRetry: editor.load),
              if (editor.saved != null) ...[
                TextField(
                  controller: editor.text,
                  enabled: !editor.busy,
                  maxLength: 10000,
                  minLines: 5,
                  maxLines: 12,
                  decoration: InputDecoration(
                    labelText: 'completion_notes'.tr(),
                  ),
                  onChanged: (_) => editor.changed(),
                ),
                if (editor.error != null)
                  Text('live_error_${editor.error}'.tr()),
                if (editor.mustReload) Text('completion_note_reconcile'.tr()),
                FilledButton(
                  onPressed: editor.busy || !editor.dirty || editor.mustReload
                      ? null
                      : editor.save,
                  child: Text('completion_save'.tr()),
                ),
                TextButton(
                  onPressed: editor.busy
                      ? null
                      : () async {
                          if (await confirmDiscard() && mounted) {
                            await editor.load();
                          }
                        },
                  child: Text('detail_refresh'.tr()),
                ),
              ],
            ],
          ),
        ),
      ),
    ),
  );
}
