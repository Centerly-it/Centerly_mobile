import '../../../core/widgets/content_skeleton.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/presentation/paged_read_cubit.dart';
import '../../../core/widgets/paged_read_body.dart';
import '../data/finance_repository.dart';
import '../domain/finance_due.dart';
import '../../../core/theme/values_manager.dart';
import 'live_invoice_summary.dart';
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
          loadingShape: LoadingShape.receipt,
          header: (_, p) => Padding(
            padding: const EdgeInsets.only(bottom: AppPadding.p16),
            child: LiveInvoiceSummary(invoice: p.summary),
          ),
          item: (_, r) => LiveReceiptCard(row: r),
        ),
      ),
    ),
  );
}
