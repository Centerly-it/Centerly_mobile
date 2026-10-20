import 'package:centrally/core/format/cairo_time.dart';
import 'dart:async';

import 'package:centrally/core/constants/strings_manager.dart';
import 'package:centrally/core/theme/color_manager.dart';
import 'package:centrally/core/theme/style_manager.dart';
import 'package:centrally/core/theme/values_manager.dart';
import 'package:centrally/core/widgets/app_status_badge.dart';
import 'package:centrally/mock_data/centerly_mock_data.dart';
import 'package:centrally/models/centerly_models.dart';
import 'package:centrally/screens/teacher/student_profile/teacher_student_profile_screen.dart';
import 'package:centrally/screens/teacher/teacher_shared.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

class SecretaryAttendanceSheetScreen extends StatefulWidget {
  const SecretaryAttendanceSheetScreen({required this.session, super.key});

  final Session session;

  @override
  State<SecretaryAttendanceSheetScreen> createState() =>
      _SecretaryAttendanceSheetScreenState();
}

class _SecretaryAttendanceSheetScreenState
    extends State<SecretaryAttendanceSheetScreen> {
  AttendanceStatus? _filter;
  String _query = '';
  Timer? _timer;
  late Duration _remainingTime;
  late bool _isLocked;

  @override
  void initState() {
    super.initState();
    _checkLockStatus();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (mounted) {
        _checkLockStatus();
      }
    });
  }

  void _checkLockStatus() {
    final now = DateTime.now();
    // Use session lock time or simulate a active 25 min window if mock date is in future/past
    final lockTime = widget.session.attendanceLockAt;
    final diff = lockTime.difference(now);

    setState(() {
      // In mock mode, if lockTime has passed relative to 2026 or real now, we check session.isAttendanceLocked
      // For rich interactive demo, if session is ongoing, we simulate remaining window
      if (widget.session.status == SessionStatus.completed ||
          widget.session.status == SessionStatus.cancelled) {
        _isLocked = true;
        _remainingTime = Duration.zero;
      } else {
        _isLocked = diff.isNegative;
        _remainingTime = diff.isNegative ? Duration.zero : diff;
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _setAttendanceStatus(String studentId, AttendanceStatus newStatus) {
    if (_isLocked) return;

    setState(() {
      final records = CenterlyMockData.attendance;
      final index = records.indexWhere(
        (a) => a.sessionId == widget.session.id && a.studentId == studentId,
      );

      if (index != -1) {
        records[index] = Attendance(
          id: records[index].id,
          sessionId: widget.session.id,
          studentId: studentId,
          status: newStatus,
          markedByType: MarkedByType.secretary,
          markedById: 'secretary-1',
          markedAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );
      } else {
        records.add(
          Attendance(
            id: 'att-${DateTime.now().millisecondsSinceEpoch}',
            sessionId: widget.session.id,
            studentId: studentId,
            status: newStatus,
            markedByType: MarkedByType.secretary,
            markedById: 'secretary-1',
            markedAt: DateTime.now(),
            updatedAt: DateTime.now(),
          ),
        );
      }
    });
  }

  void _openQrScannerDialog() {
    final controller = TextEditingController();
    showDialog<void>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(StringsManager.secretaryScanQr.tr()),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.qr_code_scanner,
                size: AppSize.s64,
                color: ColorManager.primary,
              ),
              const SizedBox(height: AppSize.s16),
              TextField(
                controller: controller,
                decoration: InputDecoration(
                  labelText: StringsManager.dataMgmtQrCode.tr(),
                  hintText: '48923',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(AppRadius.r8),
                  ),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(StringsManager.actionBack.tr()),
            ),
            FilledButton(
              onPressed: () {
                final code = controller.text.trim();
                Navigator.of(context).pop();
                if (code.isNotEmpty) {
                  setState(() => _query = code);
                }
              },
              child: const Text('بحث'),
            ),
          ],
        );
      },
    );
  }

  String _formatDuration(Duration duration) {
    final minutes = duration.inMinutes.remainder(60).toString().padLeft(2, '0');
    final seconds = duration.inSeconds.remainder(60).toString().padLeft(2, '0');
    return '$minutes:$seconds';
  }

  @override
  Widget build(BuildContext context) {
    // Get all students for this group to ensure everyone is listed
    final groupStudents = CenterlyMockData.studentsForGroup(
      widget.session.groupId,
    );
    final allRecords = CenterlyMockData.attendanceForSession(widget.session.id);

    final counts = {
      null: groupStudents.length,
      AttendanceStatus.present: allRecords
          .where((a) => a.status == AttendanceStatus.present)
          .length,
      AttendanceStatus.absent: allRecords
          .where((a) => a.status == AttendanceStatus.absent)
          .length,
      AttendanceStatus.excused: allRecords
          .where((a) => a.status == AttendanceStatus.excused)
          .length,
      AttendanceStatus.notMarked:
          groupStudents.length -
          allRecords
              .where((a) => a.status != AttendanceStatus.notMarked)
              .length,
    };

    final filteredStudents = groupStudents.where((student) {
      final record = allRecords.firstWhere(
        (a) => a.studentId == student.id,
        orElse: () => Attendance(
          id: '',
          sessionId: widget.session.id,
          studentId: student.id,
          status: AttendanceStatus.notMarked,
          markedByType: MarkedByType.secretary,
          markedAt: DateTime.now(),
          updatedAt: DateTime.now(),
        ),
      );

      final matchesFilter = _filter == null || record.status == _filter;
      final matchesQuery =
          _query.isEmpty ||
          student.name.contains(_query.trim()) ||
          student.qrCodeValue.contains(_query.trim());
      return matchesFilter && matchesQuery;
    }).toList();

    final group = CenterlyMockData.groupById(widget.session.groupId);

    return Scaffold(
      backgroundColor: ColorManager.background,
      appBar: AppBar(
        backgroundColor: ColorManager.background,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(
            Icons.chevron_right,
            color: ColorManager.textPrimary,
          ),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          StringsManager.secretaryAttendanceSheetTitle.tr(),
          style: AppTextStyles.headlineSmall.copyWith(
            color: ColorManager.textPrimary,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(
              Icons.qr_code_scanner,
              color: ColorManager.primary,
            ),
            tooltip: StringsManager.secretaryScanQr.tr(),
            onPressed: _openQrScannerDialog,
          ),
        ],
      ),
      body: Column(
        children: [
          // Countdown Timer Banner
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(
              horizontal: AppPadding.p16,
              vertical: AppPadding.p10,
            ),
            decoration: BoxDecoration(
              color: _isLocked
                  ? ColorManager.errorLight
                  : ColorManager.primaryBright,
              border: Border(
                bottom: BorderSide(
                  color: _isLocked
                      ? ColorManager.error.withAlpha(50)
                      : ColorManager.primary.withAlpha(50),
                ),
              ),
            ),
            child: Row(
              children: [
                Icon(
                  _isLocked ? Icons.lock_outline : Icons.timer_outlined,
                  color: _isLocked ? ColorManager.error : ColorManager.primary,
                  size: AppSize.s20,
                ),
                const SizedBox(width: AppSize.s10),
                Expanded(
                  child: Text(
                    _isLocked
                        ? StringsManager.secretaryAttendanceWindowClosed.tr()
                        : StringsManager.secretaryAttendanceWindowRemaining.tr(
                            namedArgs: {
                              'time': _formatDuration(_remainingTime),
                            },
                          ),
                    style: AppTextStyles.bodyMedium.copyWith(
                      color: _isLocked
                          ? ColorManager.error
                          : ColorManager.primaryDark,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(AppPadding.p16),
              children: [
                // Group Info Card
                TeacherCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              '${group.name} - ${group.subjectName}',
                              style: AppTextStyles.titleLarge,
                            ),
                          ),
                          Text(
                            group.gradeLevelName,
                            style: AppTextStyles.labelSmall.copyWith(
                              color: ColorManager.primary,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: AppSize.s6),
                      Text(
                        '${CairoTime.clockRange(widget.session.startTime, widget.session.endTime, context.locale.toString())} | ${groupStudents.length} ${StringsManager.groupsStudentsLabel.tr()}',
                        style: AppTextStyles.bodySmall,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: AppSize.s16),
                // Filter chips
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      _FilterChip(
                        label: StringsManager.attendanceFilterAll.tr(
                          namedArgs: {'count': '${counts[null]}'},
                        ),
                        selected: _filter == null,
                        onTap: () => setState(() => _filter = null),
                      ),
                      const SizedBox(width: AppSize.s8),
                      _FilterChip(
                        label: StringsManager.attendanceFilterPresent.tr(
                          namedArgs: {
                            'count': '${counts[AttendanceStatus.present]}',
                          },
                        ),
                        selected: _filter == AttendanceStatus.present,
                        onTap: () =>
                            setState(() => _filter = AttendanceStatus.present),
                      ),
                      const SizedBox(width: AppSize.s8),
                      _FilterChip(
                        label: StringsManager.attendanceFilterAbsent.tr(
                          namedArgs: {
                            'count': '${counts[AttendanceStatus.absent]}',
                          },
                        ),
                        selected: _filter == AttendanceStatus.absent,
                        onTap: () =>
                            setState(() => _filter = AttendanceStatus.absent),
                      ),
                      const SizedBox(width: AppSize.s8),
                      _FilterChip(
                        label: StringsManager.attendanceFilterExcused.tr(
                          namedArgs: {
                            'count': '${counts[AttendanceStatus.excused]}',
                          },
                        ),
                        selected: _filter == AttendanceStatus.excused,
                        onTap: () =>
                            setState(() => _filter = AttendanceStatus.excused),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: AppSize.s12),
                // Search bar with QR shortcut
                TeacherSearchField(
                  hint: StringsManager.secretarySearchQrHint.tr(),
                  onChanged: (v) => setState(() => _query = v),
                ),
                const SizedBox(height: AppSize.s14),
                if (filteredStudents.isEmpty)
                  TeacherEmptyState(
                    title: StringsManager.attendanceEmptyTitle.tr(),
                    subtitle: StringsManager.attendanceEmptySubtitle.tr(),
                    icon: Icons.search_off_outlined,
                  )
                else
                  for (final student in filteredStudents) ...[
                    _SecretaryStudentAttendanceCard(
                      student: student,
                      currentStatus: allRecords
                          .firstWhere(
                            (a) => a.studentId == student.id,
                            orElse: () => Attendance(
                              id: '',
                              sessionId: widget.session.id,
                              studentId: student.id,
                              status: AttendanceStatus.notMarked,
                              markedByType: MarkedByType.secretary,
                              markedAt: DateTime.now(),
                              updatedAt: DateTime.now(),
                            ),
                          )
                          .status,
                      isLocked: _isLocked,
                      onStatusChanged: (status) =>
                          _setAttendanceStatus(student.id, status),
                      onProfileTap: () => Navigator.of(context).push(
                        MaterialPageRoute<void>(
                          builder: (_) =>
                              TeacherStudentProfileScreen(student: student),
                        ),
                      ),
                    ),
                    const SizedBox(height: AppSize.s10),
                  ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _SecretaryStudentAttendanceCard extends StatelessWidget {
  const _SecretaryStudentAttendanceCard({
    required this.student,
    required this.currentStatus,
    required this.isLocked,
    required this.onStatusChanged,
    required this.onProfileTap,
  });

  final Student student;
  final AttendanceStatus currentStatus;
  final bool isLocked;
  final ValueChanged<AttendanceStatus> onStatusChanged;
  final VoidCallback onProfileTap;

  @override
  Widget build(BuildContext context) {
    return TeacherCard(
      padding: const EdgeInsets.all(AppPadding.p12),
      child: Column(
        children: [
          InkWell(
            onTap: onProfileTap,
            child: Row(
              children: [
                const StudentAvatar(radius: AppSize.s20),
                const SizedBox(width: AppSize.s10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(student.name, style: AppTextStyles.titleSmall),
                      const SizedBox(height: AppSize.s2),
                      Text(
                        '#${student.qrCodeValue} • ${student.phone}',
                        style: AppTextStyles.labelSmall,
                      ),
                    ],
                  ),
                ),
                AppStatusBadge.attendance(status: currentStatus),
              ],
            ),
          ),
          const SizedBox(height: AppSize.s10),
          const Divider(height: 1, color: ColorManager.divider),
          const SizedBox(height: AppSize.s8),
          // Action Buttons: Present, Absent, Excused
          Row(
            children: [
              Expanded(
                child: _AttendanceActionButton(
                  label: StringsManager.secretaryMarkPresent.tr(),
                  icon: Icons.check_circle_outline,
                  color: ColorManager.success,
                  isSelected: currentStatus == AttendanceStatus.present,
                  isLocked: isLocked,
                  onTap: () => onStatusChanged(AttendanceStatus.present),
                ),
              ),
              const SizedBox(width: AppSize.s8),
              Expanded(
                child: _AttendanceActionButton(
                  label: StringsManager.secretaryMarkAbsent.tr(),
                  icon: Icons.cancel_outlined,
                  color: ColorManager.error,
                  isSelected: currentStatus == AttendanceStatus.absent,
                  isLocked: isLocked,
                  onTap: () => onStatusChanged(AttendanceStatus.absent),
                ),
              ),
              const SizedBox(width: AppSize.s8),
              Expanded(
                child: _AttendanceActionButton(
                  label: StringsManager.secretaryMarkExcused.tr(),
                  icon: Icons.info_outline,
                  color: ColorManager.warning,
                  isSelected: currentStatus == AttendanceStatus.excused,
                  isLocked: isLocked,
                  onTap: () => onStatusChanged(AttendanceStatus.excused),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _AttendanceActionButton extends StatelessWidget {
  const _AttendanceActionButton({
    required this.label,
    required this.icon,
    required this.color,
    required this.isSelected,
    required this.isLocked,
    required this.onTap,
  });

  final String label;
  final IconData icon;
  final Color color;
  final bool isSelected;
  final bool isLocked;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: isSelected
          ? color
          : (isLocked ? ColorManager.grey200 : color.withAlpha(20)),
      borderRadius: BorderRadius.circular(AppRadius.r8),
      child: InkWell(
        onTap: isLocked ? null : onTap,
        borderRadius: BorderRadius.circular(AppRadius.r8),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: AppPadding.p8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                size: AppSize.s16,
                color: isSelected
                    ? ColorManager.white
                    : (isLocked ? ColorManager.grey500 : color),
              ),
              const SizedBox(width: AppSize.s4),
              Text(
                label,
                style: AppTextStyles.labelSmall.copyWith(
                  color: isSelected
                      ? ColorManager.white
                      : (isLocked ? ColorManager.grey500 : color),
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// Replaced by AppStatusBadge.attendance

class _FilterChip extends StatelessWidget {
  const _FilterChip({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.symmetric(
          horizontal: AppPadding.p14,
          vertical: AppPadding.p8,
        ),
        decoration: BoxDecoration(
          color: selected ? ColorManager.primary : ColorManager.grey200,
          borderRadius: BorderRadius.circular(AppRadius.circular),
        ),
        child: Text(
          label,
          style: AppTextStyles.labelSmall.copyWith(
            color: selected ? ColorManager.white : ColorManager.textPrimary,
          ),
        ),
      ),
    );
  }
}
