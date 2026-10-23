import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../../../core/format/cairo_time.dart';
import '../../../core/theme/color_manager.dart';
import '../../../core/theme/style_manager.dart';
import '../../../core/theme/values_manager.dart';
import '../presentation/design/student_profile_header.dart';
import '../presentation/design/student_profile_tabs.dart';
import '../presentation/design/student_contact_info.dart';
import '../presentation/design/student_notes_info.dart';
import '../presentation/design/student_attendance_design.dart';
import '../presentation/design/student_academics_design.dart';
import '../presentation/design/student_payments_design.dart';
import 'student_preview_data.dart';
import 'student_note_dialog.dart';

class StudentProfilePreview extends StatefulWidget {
  const StudentProfilePreview({
    required this.data,
    this.initialTab = 0,
    super.key,
  });
  final StudentPreviewData data;
  final int initialTab;
  @override
  State<StudentProfilePreview> createState() => _StudentProfilePreviewState();
}

class _StudentProfilePreviewState extends State<StudentProfilePreview> {
  late int _tab = widget.initialTab;
  Future<void> _edit() async {
    final text = await showDialog<String>(
      context: context,
      builder: (_) => StudentNoteDialog(initialText: widget.data.note),
    );
    if (mounted && text != null) {
      setState(() {
        widget.data.editedNote = text;
        widget.data.noteDate = CairoTime.local(DateTime.now());
      });
    }
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    backgroundColor: ColorManager.canvas,
    appBar: AppBar(
      backgroundColor: ColorManager.canvas,
      centerTitle: false,
      title: Text(
        'student_design_profile'.tr(),
        style: AppTextStyles.headlineSmall.copyWith(
          fontWeight: FontWeight.bold,
        ),
      ),
      leading: IconButton(
        tooltip: MaterialLocalizations.of(context).backButtonTooltip,
        onPressed: () => Navigator.of(context).pop(),
        icon: RotatedBox(
          quarterTurns: context.locale.languageCode == 'ar' ? 0 : 2,
          child: SvgPicture.asset('assets/figma/sessions/ea117.svg'),
        ),
      ),
    ),
    body: SafeArea(
      child: ListView(
        padding: const EdgeInsets.all(AppPadding.p16),
        children: [
          StudentProfileHeader(data: widget.data),
          const SizedBox(height: AppSize.s16),
          StudentProfileTabs(
            index: _tab,
            onChanged: (v) => setState(() => _tab = v),
          ),
          const SizedBox(height: AppSize.s16),
          if (_tab == 0) ...[
            const StudentContactInfo(),
            const SizedBox(height: AppSize.s16),
            StudentNotesInfo(data: widget.data, onEdit: _edit),
          ] else if (_tab == 1)
            StudentAttendanceDesign(data: widget.data)
          else if (_tab == 2)
            const StudentAcademicsDesign()
          else
            StudentPaymentsDesign(data: widget.data),
        ],
      ),
    ),
  );
}
