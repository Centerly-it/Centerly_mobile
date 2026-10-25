import '../../../core/widgets/content_skeleton.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import '../../../core/di/di.dart';
import '../../../core/format/cairo_time.dart';
import '../../../core/widgets/app_error_state.dart';
import '../../../models/centerly_models.dart';
import '../../sessions/data/session_repository.dart';
import '../../sessions/domain/session_record.dart';
import '../../sessions/presentation/design/session_design_card.dart';
import '../../sessions/presentation/session_detail_page.dart';

class LiveGroupUpcoming extends StatefulWidget {
  const LiveGroupUpcoming({required this.groupId, super.key});
  final String groupId;
  @override
  State<LiveGroupUpcoming> createState() => _LiveGroupUpcomingState();
}

class _LiveGroupUpcomingState extends State<LiveGroupUpcoming> {
  late Future<List<SessionRecord>> data = load();
  Future<List<SessionRecord>> load() {
    final today = CairoTime.local(DateTime.now());
    return getIt<SessionRepository>().list(
      from: CairoTime.date(today),
      to: CairoTime.date(DateTime(today.year, today.month, today.day + 31)),
      groupId: widget.groupId,
      refresh: true,
    );
  }

  void reload() => setState(() => data = load());
  @override
  Widget build(BuildContext context) => FutureBuilder<List<SessionRecord>>(
    future: data,
    builder: (context, snapshot) {
      if (snapshot.connectionState != ConnectionState.done) {
        return const ContentSkeleton(count: 1);
      }
      if (snapshot.hasError) return AppErrorState(onRetry: reload);
      final rows = snapshot.requireData
          .where(
            (s) =>
                s.status == SessionStatus.upcoming ||
                s.status == SessionStatus.ongoing,
          )
          .take(3)
          .toList();
      return Column(
        children: [
          if (rows.isEmpty) Text('sessions_no_sessions_title'.tr()),
          for (final row in rows)
            SessionDesignCard(
              data: row.design,
              onTap: () async {
                await SessionDetailPage.open(context, row.id);
                if (mounted) reload();
              },
            ),
          TextButton(onPressed: reload, child: Text('detail_refresh'.tr())),
        ],
      );
    },
  );
}
