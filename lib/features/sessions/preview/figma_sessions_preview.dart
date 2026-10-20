import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import '../../../core/format/cairo_time.dart';
import '../../../core/theme/style_manager.dart';
import '../../../core/theme/values_manager.dart';
import '../presentation/design/session_calendar.dart';
import '../presentation/design/session_design.dart';
import '../presentation/design/session_design_empty.dart';
import '../presentation/design/session_design_card.dart';
import '../presentation/design/session_design_controls.dart';
import '../presentation/design/session_section_title.dart';
import '../presentation/design/session_summary_strip.dart';
import '../presentation/session_date_controls.dart';
import 'session_design_fixture.dart';
import 'session_design_detail.dart';

class FigmaSessionsPreview extends StatefulWidget {
  const FigmaSessionsPreview({this.initialDate, super.key});
  final DateTime? initialDate;
  @override
  State<FigmaSessionsPreview> createState() => _FigmaSessionsPreviewState();
}

class _FigmaSessionsPreviewState extends State<FigmaSessionsPreview> {
  final _fixture = SessionDesignFixture();
  late DateTime _date = widget.initialDate ?? CairoTime.local(DateTime.now());
  SessionPeriod _period = SessionPeriod.day;
  @override
  Widget build(BuildContext context) {
    final (from, to) = sessionRange(_date, _period);
    final range = _fixture.range(from, to), day = _fixture.day(_date);
    return ColoredBox(
      color: SessionDesign.background,
      child: ListView(
        padding: const EdgeInsets.all(AppPadding.p16),
        children: [
          SessionDesignControls(
            date: _date,
            period: _period,
            onDate: (v) => setState(() => _date = v),
            onPeriod: (v) => setState(() => _period = v),
          ),
          if (_period != SessionPeriod.day)
            SessionCalendar(
              date: _date,
              month: _period == SessionPeriod.month,
              hasSessions: (d) => _fixture.day(d).isNotEmpty,
              onDate: (v) => setState(() => _date = v),
            ),
          if (_period == SessionPeriod.month)
            Text(
              'design_month_summary'.tr(
                args: [
                  DateFormat.MMMM(context.locale.toString()).format(_date),
                ],
              ),
              style: AppTextStyles.titleSmall,
            ),
          const SizedBox(height: AppSize.s12),
          SessionSummaryStrip(
            items: sessionSummaryItems(
              range.length,
              daily: _period == SessionPeriod.day,
              range.fold(0, (n, s) => n + s.present),
              range.fold(0, (n, s) => n + s.expected),
              cancelled: _period == SessionPeriod.month
                  ? range.where((s) => s.cancellationReason != null).length
                  : null,
            ),
          ),
          const SizedBox(height: AppSize.s16),
          SessionSectionTitle(
            title: _period == SessionPeriod.day
                ? 'home_today_sessions_title'.tr()
                : DateFormat.yMMMMEEEEd(
                    context.locale.toString(),
                  ).format(_date),
          ),
          const SizedBox(height: AppSize.s8),
          if (day.isEmpty) const SessionDesignEmpty(),
          for (final data in day)
            SessionDesignCard(
              data: data,
              onTap: () async {
                await Navigator.of(context).push(
                  MaterialPageRoute<void>(
                    builder: (_) => SessionDesignDetail(data: data),
                  ),
                );
                if (mounted) setState(() {});
              },
            ),
        ],
      ),
    );
  }
}
