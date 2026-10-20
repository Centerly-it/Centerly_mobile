import 'package:flutter/material.dart';
import '../../../../core/theme/color_manager.dart';
import 'session_design.dart';

class SessionSummaryItem {
  const SessionSummaryItem(this.value, this.label, this.asset, this.color);
  final int value;
  final String label, asset;
  final Color color;
}

List<SessionSummaryItem> sessionSummaryItems(
  int sessions,
  int present,
  int expected, {
  int? cancelled,
  bool daily = false,
}) => [
  SessionSummaryItem(
    sessions,
    daily ? 'sessions_today_count' : 'design_session_total',
    '646b5.svg',
    ColorManager.primary,
  ),
  SessionSummaryItem(
    present,
    daily ? 'design_present_students' : 'design_attendance_total',
    'b5cd6.svg',
    SessionDesign.green,
  ),
  SessionSummaryItem(
    expected,
    'design_expected_students',
    '4a7d6.svg',
    SessionDesign.text,
  ),
  if (cancelled != null)
    SessionSummaryItem(
      cancelled,
      'design_cancelled_sessions',
      'be784.svg',
      SessionDesign.red,
    ),
];
