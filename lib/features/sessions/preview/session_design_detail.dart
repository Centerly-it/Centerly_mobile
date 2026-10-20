import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import '../../../core/theme/values_manager.dart';
import '../domain/session_design_data.dart';
import '../presentation/design/session_cancel_sheet.dart';
import '../presentation/design/session_design.dart';
import '../presentation/design/session_detail_actions.dart';
import '../presentation/design/session_info_panel.dart';
import '../presentation/design/session_detail_students.dart';
import '../presentation/design/session_subpage_bar.dart';
import '../presentation/design/session_summary_strip.dart';
import 'session_attendance_preview.dart';

class SessionDesignDetail extends StatefulWidget {
  const SessionDesignDetail({required this.data, super.key});
  final SessionDesignData data;
  @override
  State<SessionDesignDetail> createState() => _SessionDesignDetailState();
}

class _SessionDesignDetailState extends State<SessionDesignDetail> {
  bool _showingCancel = false;
  @override
  Widget build(BuildContext context) {
    final data = widget.data;
    return ImageFiltered(
      enabled: _showingCancel,
      imageFilter: ui.ImageFilter.blur(sigmaX: 2, sigmaY: 2),
      child: Scaffold(
        backgroundColor: SessionDesign.background,
        appBar: const SessionSubpageBar(title: 'session_details_title'),
        body: SafeArea(
          child: ListView(
            padding: const EdgeInsets.all(AppPadding.p16),
            children: [
              SessionInfoPanel(data: data),
              const SizedBox(height: AppSize.s16),
              SessionSummaryStrip(
                items: [
                  SessionSummaryItem(
                    data.expected,
                    'design_expected_students',
                    '517ef.svg',
                    Theme.of(context).colorScheme.primary,
                  ),
                  SessionSummaryItem(
                    data.present,
                    'attendance_present',
                    'b5cd6.svg',
                    SessionDesign.green,
                  ),
                ],
              ),
              const SizedBox(height: AppSize.s16),
              SessionDetailStudents(data: data),
              const SizedBox(height: AppSize.s24),
              SessionDetailActions(
                cancellationReason: data.cancellationReason,
                onAttendance: () => Navigator.of(context).push(
                  MaterialPageRoute<void>(
                    builder: (_) => SessionAttendancePreview(data: data),
                  ),
                ),
                onCancel: () async {
                  setState(() => _showingCancel = true);
                  final reason = await SessionCancelSheet.open(context);
                  if (mounted) setState(() => _showingCancel = false);
                  if (reason != null && mounted) {
                    setState(() => data.cancellationReason = reason);
                  }
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
