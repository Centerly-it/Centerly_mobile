import 'package:easy_localization/easy_localization.dart';
import 'package:centrally/core/format/cairo_time.dart';
import 'package:centrally/core/theme/color_manager.dart';
import 'package:centrally/core/theme/style_manager.dart';
import 'package:centrally/core/theme/values_manager.dart';
import 'package:centrally/mock_data/centerly_mock_data.dart';
import 'package:centrally/models/centerly_models.dart';
import 'package:centrally/widgets/dashboard_metric_card.dart';
import 'package:centrally/widgets/section_widgets.dart';
import 'package:flutter/material.dart';

class RoleSectionsView extends StatelessWidget {
  const RoleSectionsView.home({required this.role, super.key})
    : _type = _RoleSectionType.home;
  const RoleSectionsView.sessions({required this.role, super.key})
    : _type = _RoleSectionType.sessions;
  const RoleSectionsView.groups({required this.role, super.key})
    : _type = _RoleSectionType.groups;
  const RoleSectionsView.finance({required this.role, super.key})
    : _type = _RoleSectionType.finance;

  final UserRole role;
  final _RoleSectionType _type;

  @override
  Widget build(BuildContext context) => switch (_type) {
    _RoleSectionType.home => _buildHome(),
    _RoleSectionType.sessions => _buildSessions(),
    _RoleSectionType.groups => _buildGroups(),
    _RoleSectionType.finance => _buildFinance(),
  };

  Widget _buildHome() {
    final paidTotal = CenterlyMockData.invoices
        .where((invoice) => invoice.status == InvoiceStatus.paid)
        .fold<double>(0, (sum, invoice) => sum + invoice.paidAmount);
    final dueTotal = CenterlyMockData.invoices
        .where((invoice) => invoice.status == InvoiceStatus.due)
        .fold<double>(0, (sum, invoice) => sum + invoice.amount);

    return SectionScaffold(
      title: 'Today overview',
      subtitle: role == UserRole.teacher
          ? 'Read-only monitoring for sessions, groups, and finance.'
          : 'Operational workspace for attendance, students, and payments.',
      children: [
        DashboardMetricCard(
          title: 'Today sessions',
          value: CenterlyMockData.sessions.length.toString(),
          icon: Icons.event_available_outlined,
          color: ColorManager.primary,
        ),
        DashboardMetricCard(
          title: 'Active students',
          value: CenterlyMockData.students.length.toString(),
          icon: Icons.school_outlined,
          color: ColorManager.success,
        ),
        DashboardMetricCard(
          title: 'Collected',
          value: '${paidTotal.toStringAsFixed(0)} EGP',
          icon: Icons.account_balance_wallet_outlined,
          color: ColorManager.success,
        ),
        DashboardMetricCard(
          title: 'Remaining',
          value: '${dueTotal.toStringAsFixed(0)} EGP',
          icon: Icons.pending_actions_outlined,
          color: ColorManager.warning,
        ),
        _PermissionNote(role: role),
      ],
    );
  }

  Widget _buildSessions() {
    return SectionScaffold(
      title: 'Sessions',
      subtitle: 'Both roles can view and cancel sessions with a reason.',
      children: [
        for (final session in CenterlyMockData.sessions)
          SectionListTileCard(
            title: CenterlyMockData.groups
                .firstWhere((group) => group.id == session.groupId)
                .name,
            subtitle:
                '${CairoTime.clockRange(session.startTime, session.endTime, Intl.getCurrentLocale())} | ${session.expectedStudentsCount} expected',
            trailing: session.isAttendanceLocked ? 'Locked' : 'Open',
            icon: Icons.calendar_today_outlined,
          ),
      ],
    );
  }

  Widget _buildGroups() {
    return SectionScaffold(
      title: 'Groups',
      subtitle: role == UserRole.secretary
          ? 'Secretary can manage groups, schedules, and enrollments.'
          : 'Teacher can view groups and student lists.',
      actionLabel: role == UserRole.secretary ? 'Add group' : null,
      children: [
        for (final group in CenterlyMockData.groups)
          SectionListTileCard(
            title: group.name,
            subtitle: '${group.subjectName} | Capacity ${group.capacity}',
            trailing: group.gradeLevelId,
            icon: Icons.groups_2_outlined,
          ),
      ],
    );
  }

  Widget _buildFinance() {
    return SectionScaffold(
      title: 'Finance',
      subtitle: role == UserRole.secretary
          ? 'Secretary records manual payment collection.'
          : 'Teacher monitors invoices and collection status.',
      actionLabel: role == UserRole.secretary ? 'Record payment' : null,
      children: [
        for (final invoice in CenterlyMockData.invoices)
          SectionListTileCard(
            title: invoice.invoiceNumber,
            subtitle:
                '${invoice.amount.toStringAsFixed(0)} EGP | due ${invoice.dueDate.day}/${invoice.dueDate.month}',
            trailing: invoice.status.name,
            icon: Icons.receipt_long_outlined,
          ),
      ],
    );
  }
}

enum _RoleSectionType { home, sessions, groups, finance }

class _PermissionNote extends StatelessWidget {
  const _PermissionNote({required this.role});

  final UserRole role;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: ColorManager.primaryBright,
        borderRadius: BorderRadius.circular(AppRadius.r8),
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppPadding.p16),
        child: Text(
          role == UserRole.teacher
              ? 'Teacher permissions: view data, edit personal notes, and cancel sessions.'
              : 'Secretary permissions: manage students, groups, attendance, exams, assignments, invoices, and cancel sessions.',
          style: AppTextStyles.bodyMedium.copyWith(
            color: ColorManager.primaryDark,
          ),
        ),
      ),
    );
  }
}
