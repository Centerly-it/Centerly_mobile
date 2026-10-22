import 'package:centrally/core/di/di.dart';
import 'package:centrally/features/auth/presentation/view_models/auth_session_cubit.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'sec27_runtime.dart';
import 'sec27_read_pages.dart';
import 'sec27_note_conflict.dart';
import 'sec27_removal.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();
  testWidgets(
    'SEC27 actual hosted Teacher reconciliation, note conflict and request-only removal',
    (tester) async {
      final registry = await sec27Registry();
      expect(registry['namespace'], sec27Namespace);
      if (registry['complete'] == true) {
        throw StateError(
          'Completed SEC27 run is read-only; never repeat this mutation-phase test',
        );
      }
      try {
        final root = await sec27Login(tester);
        await sec27ReadPages(tester, root, registry);
        await sec27NoteConflict(tester, root, registry);
        await sec27RemovalRequest(tester, root, registry);
        await sec27Signal('native-result', {
          'pass': true,
          'profile': true,
          'cancelledAttendance': true,
          'academics': true,
          'invoice': true,
          'noteConflict': true,
          'removalRequest': true,
        });
      } finally {
        await getIt<AuthSessionCubit>().logout();
      }
    },
  );
}
