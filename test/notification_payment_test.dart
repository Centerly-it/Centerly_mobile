import 'dart:async';
import 'package:centrally/core/api/teacher_read_client.dart';
import 'package:centrally/core/errors/backend_failure.dart';
import 'package:centrally/features/notifications/data/notification_payment_repository.dart';
import 'package:centrally/features/notifications/domain/notification_record.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'helpers/read_client_fixture.dart';
import 'helpers/scoped_read_fixture.dart';
import 'helpers/sdk_auth_fixture.dart';

void main() {
  const payment = '60000000-0000-4000-8000-000000000001';
  test(
    'payment notification resolves exact tenant-scoped invoice and actual collector',
    () async {
      final client = scopedReadFixture((request) async {
        expect(request.url.queryParameters['teacher_id'], 'eq.$testTeacherId');
        return jsonResponse(
          request,
          request.url.path.endsWith('/payments')
              ? {'invoice_id': 'invoice', 'collected_by': 'collector'}
              : {'name': 'Recorded collector'},
        );
      });
      await client.auth.signInWithPassword(
        email: 'fixture@example.test',
        password: 'fixture',
      );
      final result = await NotificationPaymentRepository(
        TeacherReadClient(client),
      ).load(payment);
      expect(result.invoiceId, 'invoice');
      expect(result.actor, 'Recorded collector');
      await client.dispose();
    },
  );
  test('missing foreign notification payment fails closed', () async {
    final client = scopedReadFixture(
      (request) async => jsonResponse(request, null),
    );
    await client.auth.signInWithPassword(
      email: 'fixture@example.test',
      password: 'fixture',
    );
    await expectLater(
      NotificationPaymentRepository(TeacherReadClient(client)).load(payment),
      throwsA(isA<BackendFailure>()),
    );
    await client.dispose();
  });
  test('late receipt result is rejected after logout', () async {
    final pending = Completer<http.Response>();
    late http.Request request;
    final client = scopedReadFixture((r) {
      request = r;
      return pending.future;
    });
    await client.auth.signInWithPassword(
      email: 'fixture@example.test',
      password: 'fixture',
    );
    final load = NotificationPaymentRepository(
      TeacherReadClient(client),
    ).load(payment);
    final checked = expectLater(load, throwsA(isA<BackendFailure>()));
    await Future<void>.delayed(Duration.zero);
    await client.auth.signOut();
    pending.complete(
      jsonResponse(request, {
        'invoice_id': 'invoice',
        'collected_by': 'collector',
      }),
    );
    await checked;
    await client.dispose();
  });
  test(
    'notification preserves validated payment ID and rejects arbitrary payload IDs',
    () {
      Map<String, dynamic> data(Object value) => {
        'id': 'notice',
        'type': 'payment_collected',
        'created_at': '2026-10-22T12:00:00Z',
        'payload': {'payment_id': value},
      };
      expect(NotificationRecord.fromJson(data(payment)).paymentId, payment);
      expect(
        NotificationRecord.fromJson(data('javascript:alert(1)')).paymentId,
        isNull,
      );
    },
  );
}
