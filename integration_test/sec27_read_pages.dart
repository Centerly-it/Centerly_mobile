import 'package:centrally/core/api/teacher_read_client.dart';
import 'package:centrally/core/di/di.dart';
import 'package:centrally/features/academics/presentation/student_academics_page.dart';
import 'package:centrally/features/finances/data/finance_repository.dart';
import 'package:centrally/features/finances/presentation/live_invoice_detail.dart';
import 'package:centrally/features/sessions/presentation/session_detail_page.dart';
import 'package:centrally/features/sessions/presentation/session_detail_header.dart';
import 'package:centrally/features/students/presentation/student_profile_page.dart';
import 'package:centrally/models/centerly_models.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'sec27_runtime.dart';

Future<void> sec27ReadPages(
  WidgetTester tester,
  NavigatorState root,
  Map registry,
) async {
  final ids = registry['ids'] as Map;
  await sec27Open(
    tester,
    root,
    StudentProfilePage(studentId: ids['a1'] as String),
    () => find.text('$sec27Namespace-A1').evaluate().isNotEmpty,
  );
  expect(find.text(sec27Namespace), findsWidgets);
  await sec27Back(tester, root);
  await sec27Open(
    tester,
    root,
    SessionDetailPage(sessionId: ids['future'] as String),
    () => find.byType(SessionDetailHeader).evaluate().isNotEmpty,
  );
  final header = tester.widget<SessionDetailHeader>(
    find.byType(SessionDetailHeader),
  );
  expect(header.detail.session.status, SessionStatus.cancelled);
  expect(header.detail.filteredCount, 2);
  expect(header.detail.rows.length, 2);
  expect(find.textContaining(sec27Namespace), findsWidgets);
  await sec27Back(tester, root);
  await sec27Open(
    tester,
    root,
    StudentAcademicsPage(
      studentId: ids['a1'] as String,
      initialDate: DateTime.parse(registry['before']['date'] as String),
    ),
    () => find.text('$sec27Namespace-ZERO').evaluate().isNotEmpty,
  );
  expect(find.text('$sec27Namespace-MISSING'), findsOneWidget);
  await sec27Back(tester, root);
  await sec27Open(
    tester,
    root,
    LiveInvoiceDetail(
      repository: FinanceRepository(getIt<TeacherReadClient>()),
      id: registry['invoice'] as String,
    ),
    () => find.textContaining('$sec27Namespace-INV-01').evaluate().isNotEmpty,
  );
  expect(find.text('$sec27Namespace-A1'), findsWidgets);
  await sec27Back(tester, root);
}
