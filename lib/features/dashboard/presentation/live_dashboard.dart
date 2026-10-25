import '../../../core/widgets/content_skeleton.dart';
import 'package:flutter/material.dart';
import '../../../core/di/di.dart';
import '../data/dashboard_repository.dart';
import '../domain/dashboard_summary.dart';
import '../../../core/format/cairo_time.dart';
import 'dashboard_content.dart';
import '../../../core/widgets/app_error_state.dart';

/// Initial live read surface. Full dashboard composition remains T-020.
class LiveDashboard extends StatefulWidget {
  const LiveDashboard({super.key});
  @override
  State<LiveDashboard> createState() => _LiveDashboardState();
}

class _LiveDashboardState extends State<LiveDashboard> {
  late Future<DashboardSummary> _data;
  String? _date;
  @override
  void initState() {
    super.initState();
    _data = _load();
  }

  Future<DashboardSummary> _load({bool refresh = false}) async {
    return getIt<DashboardRepository>().load(refresh: refresh, date: _date);
  }

  @override
  Widget build(BuildContext context) => FutureBuilder<DashboardSummary>(
    future: _data,
    builder: (context, snapshot) {
      if (snapshot.hasError) {
        return SingleChildScrollView(
          child: AppErrorState(
            onRetry: () => setState(() {
              _data = _load(refresh: true);
            }),
          ),
        );
      }
      if (!snapshot.hasData) {
        return const LoadingPage(shape: LoadingShape.dashboard);
      }
      final data = snapshot.data!;
      return RefreshIndicator(
        onRefresh: () async {
          setState(() {
            _data = _load(refresh: true);
          });
          try {
            await _data;
          } catch (_) {
            // FutureBuilder presents the localized retry state.
          }
        },
        child: DashboardContent(
          data: data,
          onChanged: () => setState(() {
            _data = _load(refresh: true);
          }),
          onDate: (date) => setState(() {
            _date = CairoTime.date(date);
            _data = _load(refresh: true);
          }),
        ),
      );
    },
  );
}
