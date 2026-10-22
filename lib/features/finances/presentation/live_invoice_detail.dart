import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/presentation/paged_read_cubit.dart';
import '../../../core/widgets/paged_read_body.dart';
import '../../../core/widgets/app_surface_section.dart';
import '../data/finance_repository.dart';
import '../domain/finance_due.dart';
import 'design/finance_design.dart';
import 'live_receipt_card.dart';

class LiveInvoiceDetail extends StatelessWidget {
  const LiveInvoiceDetail({
    required this.repository,
    required this.id,
    super.key,
  });
  final FinanceRepository repository;
  final String id;
  @override
  Widget build(BuildContext context) => BlocProvider(
    create: (_) => PagedReadCubit<Map<String, dynamic>, FinanceDue>(
      (_, cursor) => repository.invoice(id, cursor),
      (r) => r['id'] as String,
    )..refresh(),
    child: Scaffold(
      appBar: AppBar(title: Text('completion_invoices'.tr())),
      body: SafeArea(
        child: PagedReadBody<Map<String, dynamic>, FinanceDue>(
          header: (_, p) => AppSurfaceSection(
            icon: const Icon(Icons.receipt_long_outlined),
            title: 'finance_invoice_title'.tr(args: [p.summary.number]),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(p.summary.student),
                Text(p.summary.group),
                Text('completion_invoice_${p.summary.status}'.tr()),
                Text(
                  'completion_due'.tr(
                    args: [p.summary.due.toIso8601String().substring(0, 10)],
                  ),
                ),
                Text(
                  'finance_created_by'.tr(
                    args: [p.summary.creator ?? 'completion_missing'.tr()],
                  ),
                ),
                FinanceMoney(p.summary.amount),
                Text(
                  'completion_paid_value'.tr(
                    args: [financeMoney(p.summary.paid)],
                  ),
                ),
                Text(
                  'completion_outstanding_value'.tr(
                    args: [financeMoney(p.summary.outstanding)],
                  ),
                ),
              ],
            ),
          ),
          item: (_, r) => LiveReceiptCard(row: r),
        ),
      ),
    ),
  );
}
