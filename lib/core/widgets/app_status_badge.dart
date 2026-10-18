import 'package:centrally/core/constants/strings_manager.dart';
import 'package:centrally/core/theme/color_manager.dart';
import 'package:centrally/core/theme/style_manager.dart';
import 'package:centrally/core/theme/values_manager.dart';
import 'package:centrally/models/centerly_models.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

/// Unified status badge for attendance, invoice, and session statuses.
/// Replaces all private _StatusChip / _StatusBadge widgets across screens.
class AppStatusBadge extends StatelessWidget {
  const AppStatusBadge.attendance({required AttendanceStatus status, super.key})
    : _attendanceStatus = status,
      _invoiceStatus = null,
      _sessionStatus = null;

  const AppStatusBadge.invoice({required InvoiceStatus status, super.key})
    : _attendanceStatus = null,
      _invoiceStatus = status,
      _sessionStatus = null;

  const AppStatusBadge.session({required SessionStatus status, super.key})
    : _attendanceStatus = null,
      _invoiceStatus = null,
      _sessionStatus = status;

  final AttendanceStatus? _attendanceStatus;
  final InvoiceStatus? _invoiceStatus;
  final SessionStatus? _sessionStatus;

  @override
  Widget build(BuildContext context) {
    final (label, color) = _resolve();
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppPadding.p10,
        vertical: AppPadding.p4,
      ),
      decoration: BoxDecoration(
        color: color.withAlpha(25),
        borderRadius: BorderRadius.circular(AppRadius.circular),
      ),
      child: Text(
        label,
        style: AppTextStyles.labelSmall.copyWith(color: color),
      ),
    );
  }

  (String, Color) _resolve() {
    if (_attendanceStatus != null) {
      return switch (_attendanceStatus) {
        AttendanceStatus.present => (
          StringsManager.attendancePresent.tr(),
          ColorManager.success,
        ),
        AttendanceStatus.absent => (
          StringsManager.attendanceAbsent.tr(),
          ColorManager.error,
        ),
        AttendanceStatus.excused => (
          StringsManager.attendanceExcused.tr(),
          ColorManager.warning,
        ),
        AttendanceStatus.notMarked => (
          StringsManager.attendanceNotMarked.tr(),
          ColorManager.grey500,
        ),
      };
    }
    if (_invoiceStatus != null) {
      return switch (_invoiceStatus) {
        InvoiceStatus.paid => (
          StringsManager.invoicePaid.tr(),
          ColorManager.success,
        ),
        InvoiceStatus.due => (
          StringsManager.invoiceDue.tr(),
          ColorManager.warning,
        ),
      };
    }
    // SessionStatus
    return switch (_sessionStatus!) {
      SessionStatus.completed => (
        StringsManager.statusCompleted.tr(),
        ColorManager.grey500,
      ),
      SessionStatus.ongoing => (
        StringsManager.statusOngoing.tr(),
        ColorManager.primary,
      ),
      SessionStatus.upcoming => (
        StringsManager.statusUpcoming.tr(),
        ColorManager.success,
      ),
      SessionStatus.cancelled => (
        StringsManager.statusCancelled.tr(),
        ColorManager.error,
      ),
    };
  }
}
