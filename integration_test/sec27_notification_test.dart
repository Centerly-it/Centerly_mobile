import 'package:centrally/core/di/di.dart';
import 'package:centrally/features/auth/presentation/view_models/auth_session_cubit.dart';
import 'package:centrally/features/notifications/presentation/teacher_notifications_page.dart';
import 'package:centrally/features/notifications/presentation/notification_payment_button.dart';
import 'package:centrally/features/finances/presentation/live_invoice_detail.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'sec27_runtime.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();
  testWidgets(
    'SEC27 actual Teacher notification receipt resolves collector and retained invoice',
    (tester) async {
      final registry = await sec27Registry();
      try {
        final root = await sec27Login(tester);
        await sec27Open(
          tester,
          root,
          const TeacherNotificationsPage(),
          () => find.byType(NotificationPaymentButton).evaluate().isNotEmpty,
        );
        final target = find.byWidgetPredicate(
          (w) =>
              w is NotificationPaymentButton &&
              w.paymentId == registry['payment1'],
        );
        for (var i = 0; i < 80 && target.evaluate().isEmpty; i++) {
          final more = find.text('live_load_more'.tr()).hitTestable();
          if (more.evaluate().isNotEmpty) {
            await tester.tap(more);
          } else {
            await tester.drag(
              find.byType(ListView).first,
              const Offset(0, -500),
            );
          }
          await tester.pump();
          await tester.runAsync(
            () => Future<void>.delayed(const Duration(seconds: 1)),
          );
          await tester.pump();
        }
        expect(target, findsOneWidget);
        await tester.ensureVisible(target);
        await tester.pumpAndSettle();
        for (
          var i = 0;
          i < 10 && target.hitTestable().evaluate().isEmpty;
          i++
        ) {
          await tester.drag(find.byType(ListView).first, const Offset(0, -150));
          await tester.pumpAndSettle();
        }
        await tester.tap(target.hitTestable());
        await sec27Loaded(
          tester,
          () => find.text('completion_invoices'.tr()).evaluate().isNotEmpty,
        );
        // The actor is resolved from the actual immutable receipt, not an event title guess.
        final texts = tester
            .widgetList<Text>(find.byType(Text))
            .map((w) => w.data ?? '')
            .toList();
        final collector = await Supabase.instance.client
            .from('secretaries')
            .select('name')
            .eq('id', registry['ids']['sa'])
            .single();
        expect(
          texts.contains(
            'detail_actor'.tr(args: [collector['name'] as String]),
          ),
          isTrue,
        );
        await tester.tap(find.text('completion_invoices'.tr()));
        await sec27Loaded(
          tester,
          () =>
              find.byType(LiveInvoiceDetail).evaluate().isNotEmpty &&
              find
                  .textContaining('$sec27Namespace-INV-01')
                  .evaluate()
                  .isNotEmpty,
        );
        await sec27Signal('notification-ui-result', {
          'pass': true,
          'realReceiptActor': true,
          'invoiceDrilldown': true,
        });
      } finally {
        await getIt<AuthSessionCubit>().logout();
      }
    },
  );
}
