import 'package:centrally/core/constants/strings_manager.dart';
import 'package:centrally/core/theme/color_manager.dart';
import 'package:centrally/core/theme/style_manager.dart';
import 'package:centrally/core/theme/values_manager.dart';
import 'package:centrally/mock_data/centerly_mock_data.dart';
import 'package:centrally/models/centerly_models.dart';
import 'package:centrally/screens/teacher/teacher_session_details_screen.dart';
import 'package:centrally/screens/teacher/teacher_shared.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

/// Sessions screen — 3 views: Day / Week / Month
/// Matches Figma exactly for all three views.
class TeacherSessionsScreen extends StatefulWidget {
  const TeacherSessionsScreen({this.role = UserRole.teacher, super.key});

  final UserRole role;

  @override
  State<TeacherSessionsScreen> createState() => _TeacherSessionsScreenState();
}

class _TeacherSessionsScreenState extends State<TeacherSessionsScreen> {
  _View _view = _View.day;
  DateTime _selectedDate = DateTime(2026, 4, 14);

  List<Session> get _selectedDaySessions => CenterlyMockData.sessions
      .where((s) => _sameDay(s.date, _selectedDate))
      .toList();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ColorManager.background,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: ColorManager.background,
        title: Text(
          StringsManager.sessionsTitle.tr(),
          style: AppTextStyles.headlineSmall,
        ),
        actions: const [
          Padding(
            padding: EdgeInsetsDirectional.only(end: AppPadding.p16),
            child: Icon(
              Icons.calendar_today_outlined,
              color: ColorManager.grey500,
              size: AppSize.s20,
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          _ViewSelector(
            current: _view,
            onChanged: (v) => setState(() => _view = v),
          ),
          Expanded(
            child: switch (_view) {
              _View.day => _DayView(
                selectedDate: _selectedDate,
                sessions: _selectedDaySessions,
                onSessionTap: _openDetails,
              ),
              _View.week => _WeekView(
                selectedDate: _selectedDate,
                sessions: _selectedDaySessions,
                onDateChanged: (d) => setState(() => _selectedDate = d),
                onSessionTap: _openDetails,
              ),
              _View.month => _MonthView(
                selectedDate: _selectedDate,
                sessions: _selectedDaySessions,
                onDateChanged: (d) => setState(() => _selectedDate = d),
                onSessionTap: _openDetails,
              ),
            },
          ),
        ],
      ),
    );
  }

  void _openDetails(Session session) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) =>
            TeacherSessionDetailsScreen(session: session, role: widget.role),
      ),
    );
  }
}

enum _View { day, week, month }

// ── Segmented view selector ────────────────────────────────────────────────────

class _ViewSelector extends StatelessWidget {
  const _ViewSelector({required this.current, required this.onChanged});

  final _View current;
  final ValueChanged<_View> onChanged;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppPadding.p16,
        vertical: AppPadding.p8,
      ),
      child: SegmentedButton<_View>(
        style: SegmentedButton.styleFrom(
          selectedBackgroundColor: ColorManager.primary,
          selectedForegroundColor: ColorManager.white,
          foregroundColor: ColorManager.textSecondary,
        ),
        segments: [
          ButtonSegment(
            value: _View.month,
            label: Text(StringsManager.sessionsMonth.tr()),
          ),
          ButtonSegment(
            value: _View.week,
            label: Text(StringsManager.sessionsWeek.tr()),
          ),
          ButtonSegment(
            value: _View.day,
            label: Text(StringsManager.sessionsDay.tr()),
          ),
        ],
        selected: {current},
        onSelectionChanged: (s) => onChanged(s.first),
      ),
    );
  }
}

// ── Day View ──────────────────────────────────────────────────────────────────

class _DayView extends StatelessWidget {
  const _DayView({
    required this.selectedDate,
    required this.sessions,
    required this.onSessionTap,
  });

  final DateTime selectedDate;
  final List<Session> sessions;
  final ValueChanged<Session> onSessionTap;

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.symmetric(horizontal: AppPadding.p16),
      children: [
        const SizedBox(height: AppSize.s8),
        _SummaryStrip(
          expected: 50,
          present: 35,
          count: 5,
          countLabel: StringsManager.sessionsTodayCount.tr(),
        ),
        const SizedBox(height: AppSize.s20),
        Row(
          children: [
            const Icon(
              Icons.menu_book_outlined,
              size: AppSize.s18,
              color: ColorManager.primary,
            ),
            const SizedBox(width: AppSize.s6),
            Text(
              StringsManager.homeTodaySessionsTitle.tr(),
              style: AppTextStyles.titleMedium,
            ),
          ],
        ),
        const SizedBox(height: AppSize.s12),
        if (sessions.isEmpty)
          TeacherEmptyState(
            title: StringsManager.sessionsEmptyTitle.tr(),
            subtitle: StringsManager.sessionsEmptySubtitle.tr(),
            icon: Icons.calendar_month_outlined,
          )
        else
          for (final session in sessions) ...[
            TeacherSessionCard(
              session: session,
              highlight: session.status == SessionStatus.ongoing,
              onTap: () => onSessionTap(session),
            ),
            const SizedBox(height: AppSize.s10),
          ],
      ],
    );
  }
}

// ── Week View ─────────────────────────────────────────────────────────────────

class _WeekView extends StatelessWidget {
  const _WeekView({
    required this.selectedDate,
    required this.sessions,
    required this.onDateChanged,
    required this.onSessionTap,
  });

  final DateTime selectedDate;
  final List<Session> sessions;
  final ValueChanged<DateTime> onDateChanged;
  final ValueChanged<Session> onSessionTap;

  List<(String, int)> _days() => [
    (StringsManager.daySaturday.tr(), 11),
    (StringsManager.daySunday.tr(), 12),
    (StringsManager.dayMonday.tr(), 13),
    (StringsManager.dayTuesday.tr(), 14),
    (StringsManager.dayWednesday.tr(), 15),
    (StringsManager.dayThursday.tr(), 16),
    (StringsManager.dayFriday.tr(), 17),
  ];

  @override
  Widget build(BuildContext context) {
    final days = _days();

    return ListView(
      padding: const EdgeInsets.symmetric(horizontal: AppPadding.p16),
      children: [
        const SizedBox(height: AppSize.s8),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Icon(Icons.chevron_left, color: ColorManager.grey500),
            Text(
              '10-17 ${StringsManager.monthApril.tr()} 2026',
              style: AppTextStyles.titleSmall,
            ),
            const Icon(Icons.chevron_right, color: ColorManager.grey500),
          ],
        ),
        const SizedBox(height: AppSize.s10),
        Row(
          children: [
            for (final day in days)
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: AppSize.s2),
                  child: _DayPill(
                    dayName: day.$1,
                    dayNumber: day.$2,
                    selected: selectedDate.day == day.$2,
                    onTap: () => onDateChanged(DateTime(2026, 4, day.$2)),
                  ),
                ),
              ),
          ],
        ),
        const SizedBox(height: AppSize.s16),
        _SummaryStrip(
          expected: 210,
          present: 168,
          count: 22,
          countLabel: StringsManager.sessionsTotalSessions.tr(),
        ),
        const SizedBox(height: AppSize.s20),
        Text(_dateLabel(selectedDate), style: AppTextStyles.titleMedium),
        const SizedBox(height: AppSize.s12),
        if (sessions.isEmpty)
          TeacherEmptyState(
            title: StringsManager.sessionsNoSessionsTitle.tr(),
            subtitle: StringsManager.sessionsNoSessionsSubtitle.tr(),
            icon: Icons.calendar_month_outlined,
          )
        else
          for (final session in sessions) ...[
            TeacherSessionCard(
              session: session,
              highlight: session.status == SessionStatus.ongoing,
              onTap: () => onSessionTap(session),
            ),
            const SizedBox(height: AppSize.s10),
          ],
      ],
    );
  }
}

class _DayPill extends StatelessWidget {
  const _DayPill({
    required this.dayName,
    required this.dayNumber,
    required this.selected,
    required this.onTap,
  });

  final String dayName;
  final int dayNumber;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.symmetric(vertical: AppPadding.p8),
        decoration: BoxDecoration(
          color: selected ? ColorManager.primary : ColorManager.grey200,
          borderRadius: BorderRadius.circular(AppRadius.r8),
        ),
        child: Column(
          children: [
            Text(
              dayName,
              style: AppTextStyles.labelSmall.copyWith(
                color: selected
                    ? ColorManager.white
                    : ColorManager.textSecondary,
                fontSize: 9,
              ),
            ),
            Text(
              dayNumber.toString(),
              style: AppTextStyles.labelSmall.copyWith(
                color: selected ? ColorManager.white : ColorManager.textPrimary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Month View ────────────────────────────────────────────────────────────────

class _MonthView extends StatelessWidget {
  const _MonthView({
    required this.selectedDate,
    required this.sessions,
    required this.onDateChanged,
    required this.onSessionTap,
  });

  final DateTime selectedDate;
  final List<Session> sessions;
  final ValueChanged<DateTime> onDateChanged;
  final ValueChanged<Session> onSessionTap;

  static const _calendarDays = [
    29,
    30,
    31,
    1,
    2,
    3,
    4,
    5,
    6,
    7,
    8,
    9,
    10,
    11,
    12,
    13,
    14,
    15,
    16,
    17,
    18,
    19,
    20,
    21,
    22,
    23,
    24,
    25,
    26,
    27,
    28,
    29,
    30,
    1,
    2,
  ];
  static const _aprilStart = 3;
  static const _aprilEnd = 32;
  static const _sessionDays = [14, 15, 17];
  static const _cancelledDays = [17];

  @override
  Widget build(BuildContext context) {
    final monthName = StringsManager.monthApril.tr();

    return ListView(
      padding: const EdgeInsets.symmetric(horizontal: AppPadding.p16),
      children: [
        const SizedBox(height: AppSize.s8),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Icon(Icons.chevron_left, color: ColorManager.grey500),
            Text('$monthName 2026', style: AppTextStyles.titleSmall),
            const Icon(Icons.chevron_right, color: ColorManager.grey500),
          ],
        ),
        const SizedBox(height: AppSize.s10),
        Row(
          children: [
            for (final d in [
              StringsManager.daySunday.tr(),
              StringsManager.dayMonday.tr(),
              StringsManager.dayTuesday.tr(),
              StringsManager.dayWednesday.tr(),
              StringsManager.dayThursday.tr(),
              StringsManager.dayFriday.tr(),
              StringsManager.daySaturday.tr(),
            ])
              Expanded(
                child: Text(
                  d,
                  style: AppTextStyles.labelSmall.copyWith(fontSize: 9),
                  textAlign: TextAlign.center,
                ),
              ),
          ],
        ),
        const SizedBox(height: AppSize.s6),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: _calendarDays.length,
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 7,
            mainAxisExtent: 38,
          ),
          itemBuilder: (context, index) {
            final day = _calendarDays[index];
            final inApril = index >= _aprilStart && index <= _aprilEnd;
            final isSelected = inApril && selectedDate.day == day;
            final hasSession = inApril && _sessionDays.contains(day);
            final isCancelled = inApril && _cancelledDays.contains(day);

            return GestureDetector(
              onTap: inApril
                  ? () => onDateChanged(DateTime(2026, 4, day))
                  : null,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 150),
                    width: AppSize.s28,
                    height: AppSize.s28,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: isSelected
                          ? ColorManager.primary
                          : Colors.transparent,
                      shape: BoxShape.circle,
                    ),
                    child: Text(
                      day.toString(),
                      style: AppTextStyles.labelSmall.copyWith(
                        color: !inApril
                            ? ColorManager.textDisabled
                            : isSelected
                            ? ColorManager.white
                            : ColorManager.textPrimary,
                      ),
                    ),
                  ),
                  if (hasSession)
                    Container(
                      width: AppSize.s5,
                      height: AppSize.s5,
                      margin: const EdgeInsets.only(top: AppSize.s2),
                      decoration: BoxDecoration(
                        color: isCancelled
                            ? ColorManager.error
                            : ColorManager.success,
                        shape: BoxShape.circle,
                      ),
                    )
                  else
                    const SizedBox(height: AppSize.s8),
                ],
              ),
            );
          },
        ),
        const SizedBox(height: AppSize.s6),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _LegendDot(
              color: ColorManager.grey500,
              label: StringsManager.sessionsLegendDone.tr(),
            ),
            const SizedBox(width: AppSize.s12),
            _LegendDot(
              color: ColorManager.success,
              label: StringsManager.sessionsLegendAvailable.tr(),
            ),
            const SizedBox(width: AppSize.s12),
            _LegendDot(
              color: ColorManager.error,
              label: StringsManager.sessionsLegendCancelled.tr(),
            ),
          ],
        ),
        const SizedBox(height: AppSize.s16),
        Text(
          StringsManager.sessionsMonthSummary.tr(
            namedArgs: {'month': monthName},
          ),
          style: AppTextStyles.titleMedium,
        ),
        const SizedBox(height: AppSize.s10),
        _SummaryStrip(
          expected: 870,
          present: 700,
          count: 88,
          countLabel: StringsManager.sessionsTotalSessions.tr(),
          cancelled: 6,
        ),
        const SizedBox(height: AppSize.s20),
        Text(_dateLabel(selectedDate), style: AppTextStyles.titleMedium),
        const SizedBox(height: AppSize.s12),
        if (sessions.isEmpty)
          TeacherEmptyState(
            title: StringsManager.sessionsNoSessionsTitle.tr(),
            subtitle: StringsManager.sessionsNoSessionsSubtitle.tr(),
            icon: Icons.calendar_month_outlined,
          )
        else
          for (final session in sessions) ...[
            TeacherSessionCard(
              session: session,
              highlight: session.status == SessionStatus.ongoing,
              onTap: () => onSessionTap(session),
            ),
            const SizedBox(height: AppSize.s10),
          ],
        const SizedBox(height: AppSize.s24),
      ],
    );
  }
}

class _LegendDot extends StatelessWidget {
  const _LegendDot({required this.color, required this.label});

  final Color color;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: AppSize.s6,
          height: AppSize.s6,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: AppSize.s4),
        Text(label, style: AppTextStyles.labelSmall.copyWith(fontSize: 10)),
      ],
    );
  }
}

// ── Summary Strip ─────────────────────────────────────────────────────────────

class _SummaryStrip extends StatelessWidget {
  const _SummaryStrip({
    required this.expected,
    required this.present,
    required this.count,
    required this.countLabel,
    this.cancelled,
  });

  final int expected;
  final int present;
  final int count;
  final String countLabel;
  final int? cancelled;

  @override
  Widget build(BuildContext context) {
    return TeacherCard(
      padding: const EdgeInsets.symmetric(
        vertical: AppPadding.p12,
        horizontal: AppPadding.p8,
      ),
      child: cancelled != null
          ? Row(
              children: [
                Expanded(
                  child: _StatItem(
                    icon: Icons.menu_book_outlined,
                    value: count.toString(),
                    label: countLabel,
                    color: ColorManager.primary,
                  ),
                ),
                const _Divider(),
                Expanded(
                  child: _StatItem(
                    icon: Icons.check_circle_outline,
                    value: present.toString(),
                    label: StringsManager.sessionsTotalPresence.tr(),
                    color: ColorManager.success,
                  ),
                ),
                const _Divider(),
                Expanded(
                  child: _StatItem(
                    icon: Icons.people_outline,
                    value: expected.toString(),
                    label: StringsManager.sessionsExpectedStudents.tr(),
                    color: ColorManager.textPrimary,
                  ),
                ),
                const _Divider(),
                Expanded(
                  child: _StatItem(
                    icon: Icons.cancel_outlined,
                    value: cancelled.toString(),
                    label: StringsManager.sessionsCancelledCount.tr(),
                    color: ColorManager.error,
                  ),
                ),
              ],
            )
          : Row(
              children: [
                Expanded(
                  child: _StatItem(
                    icon: Icons.people_outline,
                    value: expected.toString(),
                    label: StringsManager.sessionsExpectedStudents.tr(),
                    color: ColorManager.textPrimary,
                  ),
                ),
                const _Divider(),
                Expanded(
                  child: _StatItem(
                    icon: Icons.check_circle_outline,
                    value: present.toString(),
                    label: StringsManager.sessionsPresentStudents.tr(),
                    color: ColorManager.success,
                  ),
                ),
                const _Divider(),
                Expanded(
                  child: _StatItem(
                    icon: Icons.menu_book_outlined,
                    value: count.toString(),
                    label: countLabel,
                    color: ColorManager.primary,
                  ),
                ),
              ],
            ),
    );
  }
}

class _StatItem extends StatelessWidget {
  const _StatItem({
    required this.icon,
    required this.value,
    required this.label,
    required this.color,
  });

  final IconData icon;
  final String value;
  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: color, size: AppSize.s14),
            const SizedBox(width: AppSize.s4),
            Text(
              value,
              style: AppTextStyles.titleMedium.copyWith(color: color),
            ),
          ],
        ),
        const SizedBox(height: AppSize.s2),
        Text(
          label,
          style: AppTextStyles.labelSmall.copyWith(fontSize: 9),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}

class _Divider extends StatelessWidget {
  const _Divider();

  @override
  Widget build(BuildContext context) {
    return const SizedBox(
      height: AppSize.s36,
      child: VerticalDivider(width: AppSize.s1),
    );
  }
}

bool _sameDay(DateTime a, DateTime b) =>
    a.year == b.year && a.month == b.month && a.day == b.day;

String _dateLabel(DateTime d) {
  final dayKey = _dayKey(d.weekday);
  final monthKey = _monthKey(d.month);
  return '${dayKey.tr()} ${d.day} ${monthKey.tr()} ${d.year}';
}

String _dayKey(int weekday) => switch (weekday) {
  1 => StringsManager.dayMonday,
  2 => StringsManager.dayTuesday,
  3 => StringsManager.dayWednesday,
  4 => StringsManager.dayThursday,
  5 => StringsManager.dayFriday,
  6 => StringsManager.daySaturday,
  _ => StringsManager.daySunday,
};

String _monthKey(int month) => switch (month) {
  1 => StringsManager.monthJanuary,
  2 => StringsManager.monthFebruary,
  3 => StringsManager.monthMarch,
  4 => StringsManager.monthApril,
  5 => StringsManager.monthMay,
  6 => StringsManager.monthJune,
  7 => StringsManager.monthJuly,
  8 => StringsManager.monthAugust,
  9 => StringsManager.monthSeptember,
  10 => StringsManager.monthOctober,
  11 => StringsManager.monthNovember,
  _ => StringsManager.monthDecember,
};
