import 'package:centrally/core/format/cairo_time.dart';
import 'package:centrally/core/constants/strings_manager.dart';
import 'package:centrally/core/theme/color_manager.dart';
import 'package:centrally/core/theme/style_manager.dart';
import 'package:centrally/core/theme/values_manager.dart';
import 'package:centrally/mock_data/centerly_mock_data.dart';
import 'package:centrally/models/centerly_models.dart';
import 'package:centrally/screens/secretary/data_management/add_edit_group_screen.dart';
import 'package:centrally/screens/secretary/data_management/add_edit_student_screen.dart';
import 'package:centrally/screens/secretary/data_management/create_invoice_payment_screen.dart';
import 'package:centrally/screens/secretary/data_management/enter_grades_assignments_screen.dart';
import 'package:centrally/screens/secretary/secretary_attendance_sheet_screen.dart';
import 'package:centrally/screens/teacher/teacher_session_details_screen.dart';
import 'package:centrally/screens/teacher/teacher_shared.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

class SecretaryHomeScreen extends StatefulWidget {
  const SecretaryHomeScreen({super.key});

  @override
  State<SecretaryHomeScreen> createState() => _SecretaryHomeScreenState();
}

class _SecretaryHomeScreenState extends State<SecretaryHomeScreen> {
  @override
  Widget build(BuildContext context) {
    final todaySessions = CenterlyMockData.sessions
        .where((s) => s.date.day == 14 && s.date.month == 4)
        .toList();

    final ongoingSession = todaySessions.firstWhere(
      (s) => s.status == SessionStatus.ongoing,
      orElse: () => todaySessions.first,
    );

    final totalCollected = CenterlyMockData.invoices.fold<double>(
      0,
      (sum, inv) => sum + inv.paidAmount,
    );

    return Scaffold(
      backgroundColor: ColorManager.background,
      body: CustomScrollView(
        slivers: [
          const _SecretaryAppBar(),
          SliverPadding(
            padding: const EdgeInsets.all(AppPadding.p16),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                // Live attendance action banner
                _LiveAttendanceBanner(
                  session: ongoingSession,
                  onTakeAttendance: () => Navigator.of(context).push(
                    MaterialPageRoute<void>(
                      builder: (_) => SecretaryAttendanceSheetScreen(
                        session: ongoingSession,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: AppSize.s20),

                // Quick Actions Section
                Text(
                  StringsManager.secretaryQuickActions.tr(),
                  style: AppTextStyles.headlineSmall,
                ),
                const SizedBox(height: AppSize.s12),
                _QuickActionsGrid(
                  onAddStudent: () => Navigator.of(context)
                      .push(
                        MaterialPageRoute<void>(
                          builder: (_) => const AddEditStudentScreen(),
                        ),
                      )
                      .then((_) => setState(() {})),
                  onAddGroup: () => Navigator.of(context)
                      .push(
                        MaterialPageRoute<void>(
                          builder: (_) => const AddEditGroupScreen(),
                        ),
                      )
                      .then((_) => setState(() {})),
                  onRecordPayment: () => Navigator.of(context)
                      .push(
                        MaterialPageRoute<void>(
                          builder: (_) => const CreateInvoicePaymentScreen(
                            initialMode: InvoicePaymentMode.recordPayment,
                          ),
                        ),
                      )
                      .then((_) => setState(() {})),
                  onEnterGrades: () => Navigator.of(context)
                      .push(
                        MaterialPageRoute<void>(
                          builder: (_) => const EnterGradesAssignmentsScreen(),
                        ),
                      )
                      .then((_) => setState(() {})),
                ),
                const SizedBox(height: AppSize.s20),

                // Stats row
                Row(
                  children: [
                    Expanded(
                      child: TeacherStatCard(
                        title: StringsManager.secretaryActiveStudentsStat.tr(),
                        value: '${CenterlyMockData.students.length}',
                        color: ColorManager.primary,
                        icon: Icons.school_outlined,
                      ),
                    ),
                    const SizedBox(width: AppSize.s12),
                    Expanded(
                      child: TeacherStatCard(
                        title: StringsManager.secretaryCollectedTodayStat.tr(),
                        value: '${totalCollected.toStringAsFixed(0)} EGP',
                        color: ColorManager.success,
                        icon: Icons.account_balance_wallet_outlined,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppSize.s24),

                // Today's Sessions Section
                TeacherSectionTitle(
                  title: StringsManager.secretaryTodaySessionsTitle.tr(),
                  actionLabel: StringsManager.homeViewAll.tr(),
                  onAction: () {},
                ),
                const SizedBox(height: AppSize.s12),
                for (final session in todaySessions) ...[
                  _SecretarySessionTile(
                    session: session,
                    onTap: () => Navigator.of(context).push(
                      MaterialPageRoute<void>(
                        builder: (_) =>
                            TeacherSessionDetailsScreen(session: session),
                      ),
                    ),
                    onAttendanceTap: () => Navigator.of(context).push(
                      MaterialPageRoute<void>(
                        builder: (_) =>
                            SecretaryAttendanceSheetScreen(session: session),
                      ),
                    ),
                  ),
                  const SizedBox(height: AppSize.s10),
                ],
                const SizedBox(height: AppSize.s20),
              ]),
            ),
          ),
        ],
      ),
    );
  }
}

class _SecretaryAppBar extends StatelessWidget {
  const _SecretaryAppBar();

  @override
  Widget build(BuildContext context) {
    return SliverAppBar(
      automaticallyImplyLeading: false,
      expandedHeight: AppSize.s100,
      pinned: true,
      backgroundColor: ColorManager.primary,
      flexibleSpace: FlexibleSpaceBar(
        background: Padding(
          padding: const EdgeInsets.fromLTRB(
            AppPadding.p16,
            48.0,
            AppPadding.p16,
            AppPadding.p12,
          ),
          child: Row(
            children: [
              Container(
                width: AppSize.s40,
                height: AppSize.s40,
                decoration: BoxDecoration(
                  color: ColorManager.white.withAlpha(40),
                  borderRadius: BorderRadius.circular(AppRadius.r12),
                ),
                child: const Icon(
                  Icons.notifications_outlined,
                  color: ColorManager.white,
                  size: AppSize.s24,
                ),
              ),
              const Spacer(),
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    StringsManager.homeGreeting.tr(namedArgs: {'name': 'سارة'}),
                    style: AppTextStyles.titleMedium.copyWith(
                      color: ColorManager.white,
                    ),
                  ),
                  Text(
                    StringsManager.secretaryDashboardTitle.tr(),
                    style: AppTextStyles.labelSmall.copyWith(
                      color: ColorManager.white.withAlpha(200),
                    ),
                  ),
                ],
              ),
              const SizedBox(width: AppSize.s12),
              const StudentAvatar(radius: AppSize.s20),
            ],
          ),
        ),
      ),
    );
  }
}

class _LiveAttendanceBanner extends StatelessWidget {
  const _LiveAttendanceBanner({
    required this.session,
    required this.onTakeAttendance,
  });

  final Session session;
  final VoidCallback onTakeAttendance;

  @override
  Widget build(BuildContext context) {
    final group = CenterlyMockData.groupById(session.groupId);

    return Container(
      padding: const EdgeInsets.all(AppPadding.p16),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF1558D6), ColorManager.primary],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(AppRadius.r16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppPadding.p8,
                  vertical: AppPadding.p4,
                ),
                decoration: BoxDecoration(
                  color: ColorManager.white.withAlpha(50),
                  borderRadius: BorderRadius.circular(AppRadius.circular),
                ),
                child: Row(
                  children: [
                    const Icon(
                      Icons.circle,
                      size: AppSize.s8,
                      color: ColorManager.success,
                    ),
                    const SizedBox(width: AppSize.s4),
                    Text(
                      StringsManager.secretaryLiveAttendanceBanner.tr(),
                      style: AppTextStyles.labelSmall.copyWith(
                        color: ColorManager.white,
                      ),
                    ),
                  ],
                ),
              ),
              const Spacer(),
              const Icon(
                Icons.timer_outlined,
                color: ColorManager.white,
                size: AppSize.s18,
              ),
            ],
          ),
          const SizedBox(height: AppSize.s10),
          Text(
            '${group.name} - ${group.subjectName}',
            style: AppTextStyles.headlineSmall.copyWith(
              color: ColorManager.white,
            ),
          ),
          const SizedBox(height: AppSize.s4),
          Text(
            CairoTime.clockRange(
              session.startTime,
              session.endTime,
              context.locale.toString(),
            ),
            style: AppTextStyles.bodySmall.copyWith(
              color: ColorManager.white.withAlpha(220),
            ),
          ),
          const SizedBox(height: AppSize.s14),
          SizedBox(
            width: double.infinity,
            child: FilledButton(
              onPressed: onTakeAttendance,
              style: FilledButton.styleFrom(
                backgroundColor: ColorManager.white,
                foregroundColor: ColorManager.primary,
              ),
              child: Text(
                StringsManager.secretaryRecordAttendanceNow.tr(),
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _QuickActionsGrid extends StatelessWidget {
  const _QuickActionsGrid({
    required this.onAddStudent,
    required this.onAddGroup,
    required this.onRecordPayment,
    required this.onEnterGrades,
  });

  final VoidCallback onAddStudent;
  final VoidCallback onAddGroup;
  final VoidCallback onRecordPayment;
  final VoidCallback onEnterGrades;

  @override
  Widget build(BuildContext context) {
    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisSpacing: AppSize.s10,
      mainAxisSpacing: AppSize.s10,
      childAspectRatio: 2.2,
      children: [
        _QuickActionButton(
          label: StringsManager.secretaryActionAddStudent.tr(),
          icon: Icons.person_add_outlined,
          color: ColorManager.primary,
          onTap: onAddStudent,
        ),
        _QuickActionButton(
          label: StringsManager.secretaryActionAddGroup.tr(),
          icon: Icons.group_add_outlined,
          color: ColorManager.success,
          onTap: onAddGroup,
        ),
        _QuickActionButton(
          label: StringsManager.secretaryActionRecordPayment.tr(),
          icon: Icons.payments_outlined,
          color: ColorManager.warning,
          onTap: onRecordPayment,
        ),
        _QuickActionButton(
          label: StringsManager.secretaryActionEnterGrades.tr(),
          icon: Icons.edit_note_outlined,
          color: const Color(0xFF8B5CF6),
          onTap: onEnterGrades,
        ),
      ],
    );
  }
}

class _QuickActionButton extends StatelessWidget {
  const _QuickActionButton({
    required this.label,
    required this.icon,
    required this.color,
    required this.onTap,
  });

  final String label;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppRadius.r12),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: AppPadding.p12),
        decoration: BoxDecoration(
          color: ColorManager.surface,
          borderRadius: BorderRadius.circular(AppRadius.r12),
          border: Border.all(color: ColorManager.divider),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(AppPadding.p8),
              decoration: BoxDecoration(
                color: color.withAlpha(25),
                borderRadius: BorderRadius.circular(AppRadius.r8),
              ),
              child: Icon(icon, color: color, size: AppSize.s20),
            ),
            const SizedBox(width: AppSize.s10),
            Expanded(child: Text(label, style: AppTextStyles.labelLarge)),
          ],
        ),
      ),
    );
  }
}

class _SecretarySessionTile extends StatelessWidget {
  const _SecretarySessionTile({
    required this.session,
    required this.onTap,
    required this.onAttendanceTap,
  });

  final Session session;
  final VoidCallback onTap;
  final VoidCallback onAttendanceTap;

  @override
  Widget build(BuildContext context) {
    final group = CenterlyMockData.groupById(session.groupId);

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppRadius.r12),
      child: TeacherCard(
        padding: const EdgeInsets.all(AppPadding.p14),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '${group.name} - ${group.subjectName}',
                    style: AppTextStyles.titleMedium,
                  ),
                  const SizedBox(height: AppSize.s4),
                  Text(
                    '${CairoTime.clockRange(session.startTime, session.endTime, context.locale.toString())} | ${session.expectedStudentsCount} ${StringsManager.groupsStudentsLabel.tr()}',
                    style: AppTextStyles.labelSmall,
                  ),
                ],
              ),
            ),
            FilledButton.tonal(
              onPressed: onAttendanceTap,
              style: FilledButton.styleFrom(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppPadding.p12,
                  vertical: 0,
                ),
                minimumSize: const Size(0, AppSize.s32),
              ),
              child: Text(StringsManager.secretaryTakeAttendanceBtn.tr()),
            ),
          ],
        ),
      ),
    );
  }
}
