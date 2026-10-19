import 'package:flutter/material.dart';
import '../../../core/di/di.dart';
import '../../../core/widgets/app_error_state.dart';
import '../../dashboard/data/dashboard_repository.dart';
import '../../dashboard/domain/dashboard_summary.dart';
import 'teacher_finance_page.dart';

class LiveFinance extends StatefulWidget {
  const LiveFinance({super.key});
  @override
  State<LiveFinance> createState() => _LiveFinanceState();
}

class _LiveFinanceState extends State<LiveFinance> {
  late Future<DashboardSummary> data = getIt<DashboardRepository>().load(
    refresh: true,
  );
  @override
  Widget build(BuildContext context) => FutureBuilder<DashboardSummary>(
    future: data,
    builder: (context, snapshot) {
      if (snapshot.hasError) {
        return SingleChildScrollView(
          child: AppErrorState(
            onRetry: () => setState(
              () => data = getIt<DashboardRepository>().load(refresh: true),
            ),
          ),
        );
      }
      if (!snapshot.hasData) {
        return const Center(child: CircularProgressIndicator());
      }
      return TeacherFinancePage(
        initialDate: DateTime.parse(snapshot.requireData.localDate),
      );
    },
  );
}
