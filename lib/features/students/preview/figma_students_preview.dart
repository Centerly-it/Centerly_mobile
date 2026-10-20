import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import '../../../core/theme/color_manager.dart';
import '../../../core/theme/values_manager.dart';
import 'student_preview_data.dart';
import 'student_filter_sheet.dart';
import 'student_directory_preview_body.dart';
import 'student_preview_filters.dart';

class FigmaStudentsPreview extends StatefulWidget {
  const FigmaStudentsPreview({required this.students, super.key});
  final List<StudentPreviewData> students;
  @override
  State<FigmaStudentsPreview> createState() => _FigmaStudentsPreviewState();
}

class _FigmaStudentsPreviewState extends State<FigmaStudentsPreview> {
  final _filters = StudentPreviewFilters();
  String _query = '';
  bool _filterOpen = false;
  Future<void> _pick(String kind) async {
    setState(() => _filterOpen = true);
    final result = await showModalBottomSheet<Set<String>>(
      context: context,
      isScrollControlled: true,
      backgroundColor: ColorManager.canvas,
      barrierColor: ColorManager.grey500.withAlpha(102),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(AppRadius.r16),
        ),
      ),
      builder: (_) =>
          StudentFilterSheet(kind: kind, selected: _filters.values[kind]!),
    );
    if (mounted) {
      setState(() {
        _filterOpen = false;
        if (result != null) _filters.values[kind] = result;
      });
    }
  }

  @override
  Widget build(BuildContext context) => ImageFiltered(
    enabled: _filterOpen,
    imageFilter: ui.ImageFilter.blur(sigmaX: 1, sigmaY: 1),
    child: StudentDirectoryPreviewBody(
      rows: widget.students.where((s) => _filters.matches(s, _query)).toList(),
      filters: _filters,
      onQuery: (v) => setState(() => _query = v.trim()),
      onPick: _pick,
      onReset: () => setState(_filters.clear),
    ),
  );
}
