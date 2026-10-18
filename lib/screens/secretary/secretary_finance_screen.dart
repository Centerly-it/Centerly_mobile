import 'package:centrally/core/constants/strings_manager.dart';
import 'package:centrally/core/theme/color_manager.dart';
import 'package:centrally/core/theme/style_manager.dart';
import 'package:centrally/core/theme/values_manager.dart';
import 'package:centrally/mock_data/centerly_mock_data.dart';
import 'package:centrally/models/centerly_models.dart';
import 'package:centrally/screens/secretary/data_management/create_invoice_payment_screen.dart';
import 'package:centrally/screens/teacher/teacher_shared.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

class SecretaryFinanceScreen extends StatefulWidget {
  const SecretaryFinanceScreen({super.key});

  @override
  State<SecretaryFinanceScreen> createState() => _SecretaryFinanceScreenState();
}

class _SecretaryFinanceScreenState extends State<SecretaryFinanceScreen> {
  InvoiceStatus? _filter;
  String _query = '';

  void _openCreateInvoice() {
    Navigator.of(context)
        .push(
          MaterialPageRoute<void>(
            builder: (_) => const CreateInvoicePaymentScreen(
              initialMode: InvoicePaymentMode.createInvoice,
            ),
          ),
        )
        .then((_) => setState(() {}));
  }

  void _openRecordPayment({String? preselectedStudentId}) {
    Navigator.of(context)
        .push(
          MaterialPageRoute<void>(
            builder: (_) => CreateInvoicePaymentScreen(
              initialMode: InvoicePaymentMode.recordPayment,
              preselectedStudentId: preselectedStudentId,
            ),
          ),
        )
        .then((_) => setState(() {}));
  }

  @override
  Widget build(BuildContext context) {
    final allInvoices = CenterlyMockData.invoices;
    final totalExpected = allInvoices.fold<double>(
      0,
      (sum, inv) => sum + inv.amount,
    );
    final totalCollected = allInvoices.fold<double>(
      0,
      (sum, inv) => sum + inv.paidAmount,
    );
    final totalDue = totalExpected - totalCollected;

    final filtered = allInvoices.where((inv) {
      final student = CenterlyMockData.studentById(inv.studentId);
      final matchesFilter = _filter == null || inv.status == _filter;
      final matchesQuery =
          _query.isEmpty ||
          student.name.contains(_query.trim()) ||
          inv.invoiceNumber.contains(_query.trim());
      return matchesFilter && matchesQuery;
    }).toList();

    return Scaffold(
      backgroundColor: ColorManager.background,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: ColorManager.surface,
        title: Text(
          StringsManager.financeTitle.tr(),
          style: AppTextStyles.headlineSmall,
        ),
        centerTitle: true,
        elevation: 0,
      ),
      body: Column(
        children: [
          // Finance Summary Strip
          Container(
            color: ColorManager.surface,
            padding: const EdgeInsets.fromLTRB(
              AppPadding.p16,
              AppPadding.p4,
              AppPadding.p16,
              AppPadding.p16,
            ),
            child: Column(
              children: [
                Row(
                  children: [
                    Expanded(
                      child: _MoneyTile(
                        title: StringsManager.homeFinanceExpected.tr(),
                        value: totalExpected,
                        color: ColorManager.textPrimary,
                      ),
                    ),
                    Expanded(
                      child: _MoneyTile(
                        title: StringsManager.homeFinanceCollected.tr(),
                        value: totalCollected,
                        color: ColorManager.success,
                      ),
                    ),
                    Expanded(
                      child: _MoneyTile(
                        title: StringsManager.homeFinanceRemaining.tr(),
                        value: totalDue,
                        color: ColorManager.warning,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppSize.s14),
                // Action buttons
                Row(
                  children: [
                    Expanded(
                      child: FilledButton.icon(
                        onPressed: _openCreateInvoice,
                        icon: const Icon(
                          Icons.add_card_outlined,
                          size: AppSize.s18,
                        ),
                        label: Text(
                          StringsManager.financeCreateInvoiceBtn.tr(),
                        ),
                      ),
                    ),
                    const SizedBox(width: AppSize.s10),
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () => _openRecordPayment(),
                        icon: const Icon(
                          Icons.payments_outlined,
                          size: AppSize.s18,
                        ),
                        label: Text(
                          StringsManager.financeRecordPaymentBtn.tr(),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const Divider(height: 1, color: ColorManager.divider),
          Padding(
            padding: const EdgeInsets.fromLTRB(
              AppPadding.p16,
              AppPadding.p12,
              AppPadding.p16,
              AppPadding.p8,
            ),
            child: TeacherSearchField(
              hint: 'ابحث برقم الفاتورة أو اسم الطالب',
              onChanged: (v) => setState(() => _query = v),
            ),
          ),
          // Filter Chips
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppPadding.p16),
            child: Row(
              children: [
                _FilterChip(
                  label: StringsManager.financeFilterAll.tr(),
                  selected: _filter == null,
                  onTap: () => setState(() => _filter = null),
                ),
                const SizedBox(width: AppSize.s8),
                _FilterChip(
                  label: StringsManager.financeFilterPaid.tr(),
                  selected: _filter == InvoiceStatus.paid,
                  onTap: () => setState(() => _filter = InvoiceStatus.paid),
                ),
                const SizedBox(width: AppSize.s8),
                _FilterChip(
                  label: StringsManager.financeFilterDue.tr(),
                  selected: _filter == InvoiceStatus.due,
                  onTap: () => setState(() => _filter = InvoiceStatus.due),
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSize.s10),
          Expanded(
            child: filtered.isEmpty
                ? const TeacherEmptyState(
                    title: 'لا توجد فواتير',
                    subtitle: 'لم يتم العثور على أي فواتير مطابقة لبحثك.',
                    icon: Icons.receipt_long_outlined,
                  )
                : ListView.separated(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppPadding.p16,
                      vertical: AppPadding.p8,
                    ),
                    itemCount: filtered.length,
                    separatorBuilder: (_, _) =>
                        const SizedBox(height: AppSize.s10),
                    itemBuilder: (context, index) {
                      final invoice = filtered[index];
                      final student = CenterlyMockData.studentById(
                        invoice.studentId,
                      );
                      final isPaid = invoice.status == InvoiceStatus.paid;

                      return Container(
                        padding: const EdgeInsets.all(AppPadding.p14),
                        decoration: BoxDecoration(
                          color: ColorManager.surface,
                          borderRadius: BorderRadius.circular(AppRadius.r12),
                          border: Border.all(color: ColorManager.divider),
                        ),
                        child: Row(
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Text(
                                        invoice.invoiceNumber,
                                        style: AppTextStyles.titleSmall,
                                      ),
                                      const SizedBox(width: AppSize.s8),
                                      _StatusBadge(status: invoice.status),
                                    ],
                                  ),
                                  const SizedBox(height: AppSize.s4),
                                  Text(
                                    student.name,
                                    style: AppTextStyles.bodyMedium,
                                  ),
                                  const SizedBox(height: AppSize.s2),
                                  Text(
                                    'استحقاق: ${invoice.dueDate.day}/${invoice.dueDate.month}/${invoice.dueDate.year}',
                                    style: AppTextStyles.labelSmall,
                                  ),
                                ],
                              ),
                            ),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Text(
                                  '${invoice.amount.toStringAsFixed(0)} ${StringsManager.profileCurrency.tr()}',
                                  style: AppTextStyles.titleMedium.copyWith(
                                    color: isPaid
                                        ? ColorManager.success
                                        : ColorManager.warning,
                                  ),
                                ),
                                if (!isPaid) ...[
                                  const SizedBox(height: AppSize.s6),
                                  FilledButton.tonal(
                                    onPressed: () => _openRecordPayment(
                                      preselectedStudentId: student.id,
                                    ),
                                    style: FilledButton.styleFrom(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: AppPadding.p12,
                                        vertical: 0,
                                      ),
                                      minimumSize: const Size(0, AppSize.s28),
                                    ),
                                    child: const Text('تحصيل'),
                                  ),
                                ],
                              ],
                            ),
                          ],
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}

class _MoneyTile extends StatelessWidget {
  const _MoneyTile({
    required this.title,
    required this.value,
    required this.color,
  });

  final String title;
  final double value;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(title, style: AppTextStyles.labelSmall),
        const SizedBox(height: AppSize.s4),
        Text(
          '${value.toStringAsFixed(0)} ${StringsManager.profileCurrency.tr()}',
          style: AppTextStyles.titleMedium.copyWith(color: color),
        ),
      ],
    );
  }
}

class _StatusBadge extends StatelessWidget {
  const _StatusBadge({required this.status});

  final InvoiceStatus status;

  @override
  Widget build(BuildContext context) {
    final isPaid = status == InvoiceStatus.paid;
    final color = isPaid ? ColorManager.success : ColorManager.warning;
    final label = isPaid
        ? StringsManager.invoicePaid.tr()
        : StringsManager.invoiceDue.tr();

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppPadding.p8,
        vertical: AppPadding.p4,
      ),
      decoration: BoxDecoration(
        color: color.withAlpha(25),
        borderRadius: BorderRadius.circular(AppRadius.circular),
      ),
      child: Text(
        label,
        style: AppTextStyles.labelSmall.copyWith(color: color, fontSize: 10),
      ),
    );
  }
}

class _FilterChip extends StatelessWidget {
  const _FilterChip({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.symmetric(
          horizontal: AppPadding.p14,
          vertical: AppPadding.p4,
        ),
        decoration: BoxDecoration(
          color: selected ? ColorManager.primary : ColorManager.grey200,
          borderRadius: BorderRadius.circular(AppRadius.circular),
        ),
        child: Text(
          label,
          style: AppTextStyles.labelSmall.copyWith(
            color: selected ? ColorManager.white : ColorManager.textPrimary,
          ),
        ),
      ),
    );
  }
}
