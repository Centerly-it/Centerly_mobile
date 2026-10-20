import 'package:centrally/features/students/preview/figma_students_preview.dart';
import 'package:centrally/features/students/preview/student_preview_data.dart';
import 'package:centrally/core/format/money_egp.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'helpers/load_test_fonts.dart';
import 'helpers/pump_session_design.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  setUpAll(() async {
    SharedPreferences.setMockInitialValues({});
    await EasyLocalization.ensureInitialized();
    await loadTestFonts();
  });
  test(
    'preview attendance and full ledger summary are internally consistent',
    () {
      final data = StudentPreviewData.fixtures().first;
      expect(data.attendancePercent, data.present * 100 ~/ data.totalSessions);
      expect(data.present + data.absent, data.totalSessions);
      expect(
        MoneyEgp.parse(data.expectedEgp).minorUnits,
        MoneyEgp.parse(data.collectedEgp).minorUnits +
            MoneyEgp.parse(data.remainingEgp).minorUnits,
      );
    },
  );
  test(
    'student payment badge, invoice history and totals always reconcile',
    () {
      for (final data in StudentPreviewData.fixtures()) {
        final expected = MoneyEgp.parse(data.expectedEgp).minorUnits;
        final settled = MoneyEgp.parse(data.collectedEgp).minorUnits;
        final remaining = MoneyEgp.parse(data.remainingEgp).minorUnits;
        expect(data.paid, remaining == BigInt.zero);
        expect(expected, settled + remaining);
        expect(
          expected,
          data.invoices.fold(
            BigInt.zero,
            (sum, i) => sum + MoneyEgp.parse(i.amountEgp).minorUnits,
          ),
        );
        expect(
          settled,
          data.invoices.fold(
            BigInt.zero,
            (sum, i) => sum + MoneyEgp.parse(i.paidEgp).minorUnits,
          ),
        );
      }
    },
  );
  testWidgets('teacher directory exposes no student-creation action', (
    tester,
  ) async {
    final students = StudentPreviewData.fixtures();
    await pumpSessionDesign(
      tester,
      () => Scaffold(body: FigmaStudentsPreview(students: students)),
    );
    expect(find.byType(FilledButton), findsNothing);
    expect(find.byType(TextFormField), findsNothing);
    expect(students.length, 6);
    expect(tester.takeException(), isNull);
  });
}
