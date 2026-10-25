import '../../../core/widgets/content_skeleton.dart';
import 'confirm_note_discard.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import '../../../core/api/teacher_read_client.dart';
import '../../../core/di/di.dart';
import '../../../core/theme/values_manager.dart';
import '../../../core/widgets/app_error_state.dart';
import '../data/student_note_repository.dart';
import 'student_note_editor.dart';
import 'student_note_fields.dart';

class StudentNotePage extends StatefulWidget {
  const StudentNotePage({
    required this.studentId,
    this.readOnly = false,
    super.key,
  });
  final String studentId;
  final bool readOnly;
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
  Future<void> leave() async {
    if (editor.busy || !await confirmDiscard() || !mounted) return;
    setState(() => exiting = true);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) Navigator.pop(context);
    });
  }

  @override
  Widget build(BuildContext context) => ListenableBuilder(
    listenable: editor,
    builder: (context, _) => PopScope(
      canPop: exiting || (!editor.dirty && !editor.busy),
      onPopInvokedWithResult: (didPop, _) async {
        if (!didPop) await leave();
      },
      child: Scaffold(
        appBar: AppBar(
          leading: BackButton(onPressed: leave),
          title: Text('completion_notes'.tr()),
        ),
        body: SafeArea(
          child: ListView(
            padding: const EdgeInsets.all(AppPadding.p16),
            children: [
              if (editor.busy && editor.saved == null)
                const ContentSkeleton(shape: LoadingShape.profile),
              if (editor.busy && editor.saved != null)
                const LinearProgressIndicator(),
              if (editor.failed && editor.saved == null)
                AppErrorState(onRetry: editor.load),
              if (editor.saved != null)
                StudentNoteFields(
                  editor: editor,
                  readOnly: widget.readOnly,
                  refresh: () async {
                    if (await confirmDiscard() && mounted) await editor.load();
                  },
                ),
            ],
          ),
        ),
      ),
    ),
  );
}
