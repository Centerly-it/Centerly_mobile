import '../../core/di/di.dart';
import '../../features/auth/presentation/view_models/auth_session_cubit.dart';

class WorkspaceSelection {
  // Retain navigation only in this running app, never across a cold launch.
  static final _tabs = <String, int>{};

  static void startAppSession() => _tabs.clear();
  static String? get _key {
    if (!getIt.isRegistered<AuthSessionCubit>()) return null;
    final p = getIt<AuthSessionCubit>().state.profile;
    return p == null ? null : 'workspace-tab:${p.id}:${p.teacherId}';
  }

  static int restore() {
    try {
      final key = _key;
      final value = key == null ? null : _tabs[key];
      return value is int && value >= 0 && value < 5 ? value : 0;
    } catch (_) {
      return 0;
    }
  }

  static Future<void> save(int value) async {
    try {
      final key = _key;
      if (key != null && value >= 0 && value < 5) _tabs[key] = value;
    } catch (_) {
      /* Session navigation must never interrupt the UI. */
    }
  }
}
