// Real hosted reads through production navigation, using synthetic teacher only.
import 'package:centrally/core/di/di.dart';
import 'package:centrally/features/auth/presentation/view_models/auth_session_cubit.dart';
import 'package:centrally/features/students/presentation/student_directory.dart';
import 'package:centrally/features/students/presentation/student_profile_page.dart';
import 'package:centrally/features/notes/presentation/student_note_page.dart';
import 'package:centrally/features/secretaries/presentation/teacher_secretaries_page.dart';
import 'package:centrally/features/notifications/presentation/teacher_notifications_page.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'helpers/teacher_login.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();
  testWidgets(
    'hosted Teacher MVP core destinations load without placeholders',
    (tester) async {
      await teacherLogin(tester);
      try {
        for (final icon in [
          Icons.calendar_month_outlined,
          Icons.groups_2_outlined,
          Icons.account_balance_wallet_outlined,
        ]) {
          await tester.tap(
            find.descendant(
              of: find.byType(NavigationBar),
              matching: find.byIcon(icon),
            ),
          );
          await settleLive(tester);
          expect(find.text('workspace_pending'.tr()), findsNothing);
        }
        await tester.tap(find.byIcon(Icons.school_outlined));
        await settleLive(tester);
        expect(find.byType(StudentDirectory), findsOneWidget);
        await tester.tap(find.text('completion_profile'.tr()).first);
        await settleLive(tester);
        expect(find.byType(StudentProfilePage), findsOneWidget);
        for (final label in [
          'completion_academics',
          'completion_attendance',
          'nav_finance',
          'completion_notes',
        ]) {
          final link = find.widgetWithText(TextButton, label.tr());
          await tester.ensureVisible(link);
          await tester.tap(link);
          await settleLive(tester);
          if (label == 'completion_notes') {
            expect(find.byType(StudentNotePage), findsOneWidget);
          }
          await tester.tap(find.byType(BackButton));
          await settleLive(tester);
        }
        await tester.tap(find.byType(BackButton));
        await settleLive(tester);
        await tester.tap(find.byType(BackButton));
        await settleLive(tester);
        for (final label in [
          'completion_secretaries',
          'completion_notifications',
        ]) {
          await tester.tap(find.byType(PopupMenuButton<String>));
          await tester.pumpAndSettle();
          await tester.tap(find.text(label.tr()));
          await settleLive(tester);
          expect(
            find.byType(
              label == 'completion_secretaries'
                  ? TeacherSecretariesPage
                  : TeacherNotificationsPage,
            ),
            findsOneWidget,
          );
          await tester.tap(find.byType(BackButton));
          await settleLive(tester);
        }
      } finally {
        await getIt<AuthSessionCubit>().logout();
        await tester.pumpAndSettle();
      }
    },
  );
}
