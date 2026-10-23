// Actual Windows Teacher UI + retained hosted records. Zero business mutations.
import 'dart:io';
import 'package:centrally/core/di/di.dart';
import 'package:centrally/features/auth/presentation/view_models/auth_session_cubit.dart';
import 'package:centrally/features/students/presentation/student_directory.dart';
import 'package:centrally/features/students/presentation/student_profile_page.dart';
import 'package:centrally/features/notes/presentation/student_note_page.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:centrally/features/students/presentation/student_browse_cubit.dart';
import 'package:centrally/core/api/teacher_read_client.dart';
import 'package:centrally/features/students/domain/student_record.dart';
import 'sec27_runtime.dart' show sec27Login, sec27Loaded, sec27Open;

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();
  testWidgets('retained archived history navigates to read-only notes', (
    tester,
  ) async {
    final root = await sec27Login(tester);
    try {
      await tester.runAsync(() async {
        final api = getIt<TeacherReadClient>();
        final rows = await api.client
            .from('students')
            .select(
              'id,full_name,created_at,phone,guardian_phone,level_tag,archived_at',
            )
            .eq('teacher_id', api.client.auth.currentUser!.id)
            .not('archived_at', 'is', null)
            .order('id')
            .limit(30);
        expect(rows, isNotEmpty);
        for (final row in rows) {
          StudentRecord.fromJson(row);
        }
      });
      await sec27Open(
        tester,
        root,
        const StudentDirectory(),
        () => find.byType(SwitchListTile).evaluate().isNotEmpty,
      );
      await tester.pumpAndSettle();
      await tester.tap(find.byType(Switch));
      await tester.pump();
      final browse = tester
          .element(find.byType(Switch))
          .read<StudentBrowseCubit>();
      await sec27Loaded(tester, () => !browse.state.loading);
      expect(browse.archived, isTrue);
      expect(browse.state.error, isNull);
      expect(
        browse.state.students.any(
          (s) => s.id == 'ce270000-0000-4000-8000-000000000001',
        ),
        isTrue,
      );
      await sec27Loaded(
        tester,
        () => find.text('SEC27-ACCEPT-20261022-A1').evaluate().isNotEmpty,
      );
      await tester.tap(find.text('SEC27-ACCEPT-20261022-A1'));
      await sec27Loaded(
        tester,
        () =>
            find.byType(StudentProfilePage).evaluate().isNotEmpty &&
            find.text('completion_notes'.tr()).evaluate().isNotEmpty,
      );
      await tester.ensureVisible(find.text('completion_notes'.tr()));
      await tester.tap(find.text('completion_notes'.tr()));
      await sec27Loaded(
        tester,
        () =>
            find.byType(StudentNotePage).evaluate().isNotEmpty &&
            find.byType(TextField).evaluate().isNotEmpty,
      );
      expect(tester.widget<TextField>(find.byType(TextField)).readOnly, isTrue);
      expect(find.byType(FilledButton), findsNothing);
      expect(
        tester.widget<TextField>(find.byType(TextField)).controller!.text,
        isNotEmpty,
      );
      expect(tester.takeException(), isNull);
      await File('.buildlog/pilot28-native-result.json').writeAsString(
        '{"pass":true,"mode":"actual Windows Teacher UI","businessWrites":0,"archivedDirectory":true,"profileNavigation":true,"archivedNotesReadOnly":true}',
      );
    } finally {
      await getIt<AuthSessionCubit>().logout();
    }
  });
}
