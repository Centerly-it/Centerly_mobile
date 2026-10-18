import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import '../../../core/di/di.dart';
import '../data/dashboard_repository.dart';
import '../../../core/theme/values_manager.dart';
import '../../../core/widgets/app_error_state.dart';
import '../../../screens/teacher/teacher_shared.dart';

/// Initial live read surface. Full dashboard composition remains T-020.
class LiveDashboard extends StatefulWidget {
  const LiveDashboard({super.key});
  @override
  State<LiveDashboard> createState() => _LiveDashboardState();
}

class _LiveDashboardState extends State<LiveDashboard> {
  late Future<Map<String, dynamic>> _data;
  @override
  void initState() {
    super.initState();
    _data = _load();
  }

  Future<Map<String, dynamic>> _load() async {
    return getIt<DashboardRepository>().load();
  }

  @override
  Widget build(BuildContext context) => FutureBuilder<Map<String, dynamic>>(
    future: _data,
    builder: (context, snapshot) {
      if (snapshot.hasError) {
        return AppErrorState(onRetry: () => setState(() => _data = _load()));
      }
      if (!snapshot.hasData) {
        return const Center(child: CircularProgressIndicator());
      }
      final data = snapshot.data!;
      return RefreshIndicator(
        onRefresh: () async {
          setState(() => _data = _load());
          await _data;
        },
        child: ListView(
          padding: const EdgeInsets.all(AppPadding.p16),
          children: [
            for (final entry in {
              'live_total_students': 'total_students',
              'live_total_groups': 'total_groups',
              'live_collected': 'collected_egp',
              'live_outstanding': 'outstanding_egp',
            }.entries)
              Padding(
                padding: const EdgeInsets.only(bottom: AppPadding.p16),
                child: TeacherStatCard(
                  title: entry.key.tr(),
                  value: '${data[entry.value] ?? '—'}',
                  icon: Icons.analytics_outlined,
                  color: Theme.of(context).colorScheme.primary,
                ),
              ),
          ],
        ),
      );
    },
  );
}
