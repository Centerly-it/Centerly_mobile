import 'package:flutter/material.dart';
import '../../../core/format/cairo_time.dart';
import '../../../core/theme/values_manager.dart';
import '../presentation/design/group_design.dart';
import '../presentation/design/group_info_header.dart';
import '../presentation/design/group_section.dart';
import '../presentation/design/group_subpage_bar.dart';
import '../presentation/design/group_notes_panel.dart';
import '../presentation/design/group_upcoming_rows.dart';
import '../presentation/design/group_student_rows.dart';
import 'group_note_editor.dart';
import 'group_preview_data.dart';

class GroupDesignDetail extends StatefulWidget {
  const GroupDesignDetail({required this.data, super.key});
  final GroupPreviewData data;
  @override
  State<GroupDesignDetail> createState() => _GroupDesignDetailState();
}

class _GroupDesignDetailState extends State<GroupDesignDetail> {
  void _view(String title, Widget child) => Navigator.of(context).push(
    MaterialPageRoute<void>(
      builder: (_) => Scaffold(
        backgroundColor: GroupDesign.background,
        appBar: GroupSubpageBar(title: title),
        body: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(AppPadding.p16),
            child: child,
          ),
        ),
      ),
    ),
  );
  Future<void> _add() async {
    final text = await Navigator.of(
      context,
    ).push<String>(MaterialPageRoute(builder: (_) => const GroupNoteEditor()));
    if (mounted && text != null) {
      setState(
        () => widget.data.notes.insert(
          0,
          GroupPreviewNote(text, CairoTime.local(DateTime.now())),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    backgroundColor: GroupDesign.background,
    appBar: const GroupSubpageBar(title: 'group_design_details'),
    body: SafeArea(
      child: ListView(
        padding: const EdgeInsets.all(AppPadding.p16),
        children: [
          GroupInfoHeader(data: widget.data),
          const SizedBox(height: AppSize.s16),
          GroupSection(
            title: 'group_design_upcoming',
            asset: 'f399a.svg',
            onViewAll: () => _view(
              'group_design_upcoming',
              GroupUpcomingRows(data: widget.data, count: 6),
            ),
            child: GroupUpcomingRows(data: widget.data),
          ),
          const SizedBox(height: AppSize.s16),
          GroupNotesPanel(
            notes: widget.data.notes,
            onAdd: _add,
            onViewAll: () => _view(
              'group_design_notes',
              Column(
                children: [
                  for (final note in widget.data.notes)
                    Padding(
                      padding: const EdgeInsets.only(bottom: AppPadding.p12),
                      child: GroupNoteTile(note: note),
                    ),
                ],
              ),
            ),
          ),
          const SizedBox(height: AppSize.s16),
          GroupSection(
            title: 'group_design_students',
            asset: 'a57fd.svg',
            onViewAll: () => _view(
              'group_design_students',
              GroupStudentRows(data: widget.data, count: widget.data.students),
            ),
            child: GroupStudentRows(data: widget.data),
          ),
        ],
      ),
    ),
  );
}
