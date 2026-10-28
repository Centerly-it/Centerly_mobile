import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import '../../../core/api/teacher_read_client.dart';
import '../../../core/di/di.dart';
import '../../../core/format/money_egp.dart';
import '../../../core/theme/values_manager.dart';
import '../../../core/widgets/app_error_state.dart';
import '../../../core/widgets/app_info_row.dart';
import '../../../core/widgets/app_surface_section.dart';

class SessionBillingPanel extends StatefulWidget {
  const SessionBillingPanel({required this.sessionId, super.key});
  final String sessionId;
  static const enabled = bool.fromEnvironment('CENTERLY_SESSION_BILLING');
  @override
  State<SessionBillingPanel> createState() => _SessionBillingPanelState();
}

class _SessionBillingPanelState extends State<SessionBillingPanel> {
  late Future<Object?> data = load();
  Future<Object?> load() => getIt<TeacherReadClient>().read(
    TeacherRead.sessionBilling,
    params: {'p_session_id': widget.sessionId},
    refresh: true,
  );
  @override
  Widget build(BuildContext context) {
    if (!SessionBillingPanel.enabled) return const SizedBox.shrink();
    return FutureBuilder<Object?>(
      future: data,
      builder: (context, state) {
        if (state.hasError) {
          return AppErrorState(
            onRetry: () => setState(() {
              data = load();
            }),
          );
        }
        if (!state.hasData) return const SizedBox.shrink();
        try {
          final value = Map<String, dynamic>.from(state.data! as Map);
          if (value['billing_mode'] != 'per_session') {
            return const SizedBox.shrink();
          }
          final summary = Map<String, dynamic>.from(value['summary'] as Map);
          final charged = MoneyEgp.parse(summary['charged_egp']);
          final paid = MoneyEgp.parse(summary['paid_egp']);
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: AppPadding.p12),
            child: AppSurfaceSection(
              title: 'billing_session_summary'.tr(),
              icon: const Icon(Icons.payments_outlined),
              child: Column(
                children: [
                  AppInfoRow(
                    label: 'billing_charged'.tr(),
                    value: charged.decimal,
                  ),
                  AppInfoRow(label: 'billing_paid'.tr(), value: paid.decimal),
                  if ((summary['settlement_count'] as int) > 0)
                    Text('billing_settlement_required'.tr()),
                ],
              ),
            ),
          );
        } catch (_) {
          return const AppErrorState();
        }
      },
    );
  }
}
