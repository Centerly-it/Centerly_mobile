import 'package:centrally/features/secretaries/presentation/teacher_secretaries_page.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'sec27_runtime.dart';

Future<void> sec27RemovalRequest(
  WidgetTester tester,
  NavigatorState root,
  Map registry,
) async {
  await sec27Open(
    tester,
    root,
    const TeacherSecretariesPage(),
    () =>
        find.text('completion_request_removal'.tr()).evaluate().isNotEmpty ||
        find.text('completion_removal_pending'.tr()).evaluate().isNotEmpty,
  );
  if (find.text('completion_request_removal'.tr()).evaluate().isNotEmpty) {
    await tester.tap(find.text('completion_request_removal'.tr()));
    await tester.pumpAndSettle();
    await tester.tap(
      find.widgetWithText(FilledButton, 'completion_confirm'.tr()),
    );
    await sec27Loaded(
      tester,
      () => find.text('completion_removal_pending'.tr()).evaluate().isNotEmpty,
    );
  }
  final client = Supabase.instance.client;
  final secretary = await client
      .from('secretaries')
      .select('id,status,teacher_id')
      .eq('id', registry['ids']['sa'])
      .single();
  expect(secretary['status'], 'active');
  expect(secretary['teacher_id'], registry['ids']['ta']);
  final request = await client
      .from('secretary_removal_requests')
      .select('id,status')
      .eq('secretary_id', registry['ids']['sa'])
      .eq('status', 'pending')
      .single();
  await sec27Signal('removal-ui-result', {
    'pass': true,
    'request': request,
    'secretaryActive': true,
  });
  await sec27Back(tester, root);
}
