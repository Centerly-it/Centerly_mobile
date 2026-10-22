import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import '../../../core/di/di.dart';
import '../../../core/format/cairo_time.dart';
import '../../../core/theme/values_manager.dart';
import '../../../core/widgets/app_empty_state.dart';
import '../../../core/widgets/app_error_state.dart';
import '../../dashboard/data/dashboard_repository.dart';
import '../data/session_repository.dart';
import '../domain/session_record.dart';
import 'design/session_design_card.dart';
import 'design/session_design_controls.dart';
import 'design/session_calendar.dart';
import 'session_detail_page.dart';
import '../../../models/centerly_models.dart';
import 'session_date_controls.dart';

class LiveSessions extends StatefulWidget {
  const LiveSessions({this.groupId, super.key});
  final String? groupId;
  @override
  State<LiveSessions> createState() => _LiveSessionsState();
}

class _LiveSessionsState extends State<LiveSessions> {
  DateTime? _date;
  SessionPeriod _period = SessionPeriod.day;
  late Future<List<SessionRecord>> _data = _load();
  Future<List<SessionRecord>> _load() async {
    _date ??= DateTime.parse(
      (await getIt<DashboardRepository>().load()).localDate,
    );
    final (from, to) = sessionRange(_date!, _period);
    return getIt<SessionRepository>().list(
      from: CairoTime.date(from),
      to: CairoTime.date(to),
      refresh: true,
      groupId: widget.groupId,
    );
  }

  void _reload() => setState(() {
    _data = _load();
  });
  @override
  Widget build(BuildContext context) => FutureBuilder<List<SessionRecord>>(
    future: _data,
    builder: (context, snapshot) {
      if (snapshot.hasError) {
        return SingleChildScrollView(child: AppErrorState(onRetry: _reload));
      }
      if (snapshot.connectionState != ConnectionState.done) {
        return Center(
          child: CircularProgressIndicator(semanticsLabel: 'loading_data'.tr()),
        );
      }
      final sessions = snapshot.requireData;
      return RefreshIndicator(
        onRefresh: () async {
          _reload();
          try {
            await _data;
          } catch (_) {}
        },
        child: ListView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(AppPadding.p16),
          children: [
            SessionDesignControls(
              date: _date!,
              period: _period,
              onDate: (value) {
                _date = value;
                _reload();
              },
              onPeriod: (value) {
                _period = value;
                _reload();
              },
            ),
            if (_period != SessionPeriod.day)
              SessionCalendar(
                date: _date!,
                month: _period == SessionPeriod.month,
                onDate: (v) {
                  _date = v;
                  _reload();
                },
                hasSessions: (d) => sessions.any(
                  (s) =>
                      s.localDate == CairoTime.date(d) &&
                      s.status != SessionStatus.cancelled,
                ),
                hasCancelledSessions: (d) => sessions.any(
                  (s) =>
                      s.localDate == CairoTime.date(d) &&
                      s.status == SessionStatus.cancelled,
                ),
              ),
            if (sessions.isEmpty)
              AppEmptyState(
                title: 'sessions_no_sessions_title'.tr(),
                subtitle: 'sessions_no_sessions_subtitle'.tr(),
              ),
            for (final session in sessions)
              SessionDesignCard(
                data: session.design,
                onTap: () async {
                  await SessionDetailPage.open(context, session.id);
                  if (mounted) _reload();
                },
              ),
          ],
        ),
      );
    },
  );
}
