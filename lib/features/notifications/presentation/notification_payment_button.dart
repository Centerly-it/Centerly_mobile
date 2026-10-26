import '../../../core/widgets/content_skeleton.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import '../../../core/api/teacher_read_client.dart';
import '../../../core/di/di.dart';
import '../../../core/widgets/app_error_state.dart';
import '../../../core/widgets/app_info_row.dart';
import '../../../core/theme/values_manager.dart';
import '../../../core/widgets/app_surface_section.dart';
import '../../finances/data/finance_repository.dart';
import '../../finances/presentation/live_invoice_detail.dart';
import '../data/notification_payment_repository.dart';

class NotificationPaymentButton extends StatelessWidget {
  const NotificationPaymentButton({
    required this.paymentId,
    this.reversed = false,
    super.key,
  });
  final String paymentId;
  final bool reversed;
  @override
  Widget build(BuildContext context) => TextButton(
    onPressed: () {
      final api = getIt<TeacherReadClient>();
      final future = NotificationPaymentRepository(api).load(paymentId);
      showModalBottomSheet<void>(
        context: context,
        builder: (sheet) => SafeArea(
          child: FutureBuilder<NotificationPayment>(
            future: future,
            builder: (_, state) {
              if (state.hasError) return const AppErrorState();
              if (!state.hasData) {
                return const LoadingPage(shape: LoadingShape.receipt);
              }
              final data = state.data!;
              return SingleChildScrollView(
                padding: const EdgeInsets.all(AppPadding.p16),
                child: AppSurfaceSection(
                  title: 'finance_collection_detail'.tr(),
                  icon: const Icon(Icons.receipt_long_outlined),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      AppInfoRow(
                        label: 'finance_actor'.tr(),
                        value: data.actor ?? 'live_missing_value'.tr(),
                      ),
                      TextButton(
                        onPressed: () {
                          Navigator.pop(sheet);
                          Navigator.of(context).push(
                            MaterialPageRoute<void>(
                              builder: (_) => LiveInvoiceDetail(
                                repository: FinanceRepository(api),
                                id: data.invoiceId,
                              ),
                            ),
                          );
                        },
                        child: Text('completion_invoices'.tr()),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      );
    },
    child: Text('finance_collection_detail'.tr()),
  );
}
