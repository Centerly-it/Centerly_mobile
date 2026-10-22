import 'finance_overview_details.dart';
import '../../../core/format/cairo_time.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import '../../../core/theme/values_manager.dart';
import '../../../core/widgets/app_error_state.dart';
import '../data/finance_repository.dart';
import '../domain/finance_overview_data.dart';
import 'design/finance_cash_hero.dart';
import 'design/finance_cohort_summary.dart';
import 'design/finance_debt_breakdown.dart';
import 'design/finance_methods_summary.dart';
import 'live_finance.dart';

class LiveFinanceOverview extends StatefulWidget {
  const LiveFinanceOverview({
    required this.repository,
    required this.month,
    required this.onDues,
    required this.onActor,
    super.key,
  });
  final FinanceRepository repository;
  final DateTime month;
  final ValueChanged<String> onDues, onActor;
  @override
  State<LiveFinanceOverview> createState() => _LiveFinanceOverviewState();
}

class _LiveFinanceOverviewState extends State<LiveFinanceOverview> {
  late Future<FinanceOverviewData> data = widget.repository.overview(
    financeDates(widget.month),
  );
  Future<void> reload() async {
    setState(
      () => data = widget.repository.overview(financeDates(widget.month)),
    );
    try {
      await data;
    } catch (_) {}
  }

  @override
  Widget build(BuildContext context) => FutureBuilder<FinanceOverviewData>(
    future: data,
    builder: (context, snapshot) {
      final value = snapshot.connectionState == ConnectionState.done
          ? snapshot.data
          : null;
      return RefreshIndicator(
        onRefresh: reload,
        child: ListView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(AppPadding.p16),
          children: [
            if (snapshot.connectionState != ConnectionState.done)
              const Center(child: CircularProgressIndicator())
            else if (snapshot.hasError)
              AppErrorState(onRetry: reload)
            else if (value != null) ...[
              FinanceCashHero(month: widget.month, summary: value),
              const SizedBox(height: AppSize.s16),
              FinanceCohortSummary(month: widget.month, summary: value),
              const SizedBox(height: AppSize.s16),
              FinanceDebtBreakdown(
                month: widget.month,
                now: value.syncedAt,
                summary: value,
                onLate: () => widget.onDues('overdue'),
                onRemaining: () => widget.onDues('not_late'),
              ),
              const SizedBox(height: AppSize.s16),
              FinanceOverviewActors(
                value: value,
                month: widget.month,
                onActor: widget.onActor,
              ),
              const SizedBox(height: AppSize.s16),
              FinanceMethodsSummary(month: widget.month, summary: value),
              FinanceCalculatorLink(value: value, month: widget.month),
              Text(
                'detail_synced'.tr(
                  args: [
                    DateFormat.yMd(
                      context.locale.toString(),
                    ).add_Hm().format(CairoTime.local(value.syncedAt)),
                  ],
                ),
              ),
            ],
          ],
        ),
      );
    },
  );
}
