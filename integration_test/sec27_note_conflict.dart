import 'dart:convert';
import 'dart:io';
import 'package:centrally/features/notes/presentation/student_note_page.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'sec27_runtime.dart';

Future<void> sec27NoteConflict(
  WidgetTester tester,
  NavigatorState root,
  Map registry,
) async {
  final student = registry['ids']['a1'] as String;
  await sec27Open(
    tester,
    root,
    StudentNotePage(studentId: student),
    () => find.byType(TextField).evaluate().isNotEmpty,
  );
  final field = find.byType(TextField);
  final previous = File(
    '${Platform.environment['CENTERLY_SEC27_SIGNAL_DIR']}/note-ui-result.json',
  );
  if (await previous.exists()) {
    final proof = jsonDecode(await previous.readAsString()) as Map;
    expect(proof['pass'], isTrue);
    final winner = registry['noteWinner']['content'] as String;
    expect(tester.widget<TextField>(field).controller!.text, winner);
    await tester.enterText(
      field,
      winner.endsWith('A')
          ? '$sec27Namespace NOTE-WINNER-B'
          : '$sec27Namespace NOTE-WINNER-A',
    );
    await tester.tap(find.byType(BackButton));
    await tester.pumpAndSettle();
    await tester.tap(
      find.widgetWithText(FilledButton, 'completion_discard'.tr()),
    );
    await tester.pumpAndSettle();
    return;
  }
  expect(
    tester.widget<TextField>(field).controller!.text,
    '$sec27Namespace NOTE-INITIAL',
  );
  await tester.enterText(field, '$sec27Namespace NOTE-WINNER-A');
  await sec27Signal('note-ready', {
    'ready': true,
    'version': registry['noteInitialVersion'],
  });
  final path =
      '${Platform.environment['CENTERLY_SEC27_SIGNAL_DIR']}/note-race.json';
  Map? race;
  for (var i = 0; i < 480; i++) {
    await tester.runAsync(() async {
      if (await File(path).exists()) {
        race = jsonDecode(await File(path).readAsString()) as Map;
      }
      await Future<void>.delayed(const Duration(milliseconds: 250));
    });
    await tester.pump(const Duration(milliseconds: 50));
    if (race != null) break;
  }
  expect(race, isNotNull);
  final winning = race!['content'] as String;
  final draft = winning.endsWith('A')
      ? '$sec27Namespace NOTE-WINNER-B'
      : '$sec27Namespace NOTE-WINNER-A';
  await tester.enterText(field, draft);
  await tester.tap(find.widgetWithText(FilledButton, 'completion_save'.tr()));
  await sec27Loaded(
    tester,
    () => find.text('completion_note_reconcile'.tr()).evaluate().isNotEmpty,
  );
  expect(tester.widget<TextField>(field).controller!.text, draft);
  expect(find.text('live_error_CONFLICT'.tr()), findsOneWidget);
  await sec27Signal('note-ui-result', {
    'pass': true,
    'draftPreserved': true,
    'staleSaveRejected': true,
  });
  await tester.tap(find.byType(BackButton));
  await tester.pumpAndSettle();
  await tester.tap(
    find.widgetWithText(FilledButton, 'completion_discard'.tr()),
  );
  await tester.pumpAndSettle();
  await sec27Open(
    tester,
    root,
    StudentNotePage(studentId: student),
    () => find.byType(TextField).evaluate().isNotEmpty,
  );
  expect(
    tester.widget<TextField>(find.byType(TextField)).controller!.text,
    winning,
  );
}
