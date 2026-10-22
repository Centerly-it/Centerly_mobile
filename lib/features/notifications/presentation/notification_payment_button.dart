import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import '../../../core/api/teacher_read_client.dart';
import '../../../core/di/di.dart';
import '../../../core/widgets/app_error_state.dart';
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
                return const Center(child: CircularProgressIndicator());
              }
              final data = state.data!;
              return Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'detail_actor'.tr(
                      args: [data.actor ?? 'live_missing_value'.tr()],
                    ),
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
              );
            },
          ),
        ),
      );
    },
    child: Text(
      (reversed ? 'finance_correction_detail' : 'finance_collection_detail')
          .tr(),
    ),
  );
}
