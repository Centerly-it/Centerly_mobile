import '../../finances/presentation/live_finance_dues.dart';
import '../../finances/data/finance_repository.dart';
import '../../../core/api/teacher_read_client.dart';
import '../../../core/di/di.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import '../../../core/theme/values_manager.dart';
import 'dashboard_metrics.dart';
import 'dashboard_attendance_section.dart';
import '../../../core/config/preview_mode.dart';
import '../preview/preview_unpaid_students.dart';
import 'dashboard_payment_progress.dart';
import '../../../core/format/money_egp.dart';
import '../../../screens/teacher/teacher_shared.dart';
import '../../../core/theme/color_manager.dart';
import '../../../core/widgets/data_update_footer.dart';
import 'dashboard_day_section.dart';
import '../domain/dashboard_summary.dart';

class DashboardContent extends StatelessWidget {
  const DashboardContent({
    required this.data,
    required this.onDate,
    this.onChanged,
    super.key,
  });
  final DashboardSummary data;
  final VoidCallback? onChanged;
  final ValueChanged<DateTime> onDate;
  String _money(BuildContext context, String amount) {
    final symbol = context.locale.languageCode == 'ar'
        ? MoneyEgp.arabicCurrencySymbol
        : NumberFormat.simpleCurrency(
            locale: context.locale.toString(),
            name: 'EGP',
          ).currencySymbol;
    return '${MoneyEgp.parse(amount).groupedWholePounds} $symbol';
  }

  @override
  Widget build(BuildContext context) => ListView(
    physics: const AlwaysScrollableScrollPhysics(),
    padding: const EdgeInsets.all(AppPadding.p16),
    children: [
      DashboardDaySection(data: data, onDate: onDate),
      const SizedBox(height: AppSize.s24),
      Text(
        'live_finance_snapshot'.tr(),
        style: Theme.of(context).textTheme.titleLarge,
      ),
      const SizedBox(height: AppSize.s16),
      TeacherStatCard(
        title: 'dashboard_month_invoiced'.tr(),
        value: data.invoicedEgp == null
            ? '—'
            : _money(context, data.invoicedEgp!),
        color: ColorManager.primary,
      ),
      const SizedBox(height: AppSize.s12),
      DashboardMetrics(
        twoColumns: true,
        values: {
          'dashboard_month_collected': _money(context, data.collectedEgp),
          'dashboard_month_outstanding': _money(context, data.outstandingEgp),
        },
      ),
      if (data.invoicedEgp != null) ...[
        const SizedBox(height: AppSize.s12),
        DashboardPaymentProgress(
          invoiced: data.invoicedEgp!,
          outstanding: data.outstandingEgp,
        ),
      ],
      const SizedBox(height: AppSize.s12),
      if (PreviewMode.enabled) ...[
        const PreviewUnpaidStudents(),
        const SizedBox(height: AppSize.s24),
      ],
      if (!PreviewMode.enabled) ...[
        TextButton.icon(
          icon: const Icon(Icons.receipt_long_outlined),
          label: Text('finance_view_dues'.tr()),
          onPressed: () => Navigator.of(context).push(
            MaterialPageRoute<void>(
              builder: (_) => Scaffold(
                appBar: AppBar(title: Text('nav_finance'.tr())),
                body: LiveFinanceDues(
                  repository: FinanceRepository(getIt<TeacherReadClient>()),
                  month: DateTime.parse(data.localDate),
                ),
              ),
            ),
          ),
        ),
        const SizedBox(height: AppSize.s18),
      ],
      DashboardAttendanceSection(data: data),
      if (data.attendanceSyncedAt != null)
        DataUpdateFooter(updatedAt: data.attendanceSyncedAt!),
    ],
  );
}
