import '../../core/di/di.dart';
import '../../core/utils/cached_data_shared_preferences.dart';
import '../../features/auth/presentation/view_models/auth_session_cubit.dart';

class WorkspaceSelection {
  static String? get _key {
    if (!getIt.isRegistered<AuthSessionCubit>()) return null;
    final p = getIt<AuthSessionCubit>().state.profile;
    return p == null ? null : 'workspace-tab:${p.id}:${p.teacherId}';
  }

  static int restore() {
    try {
      final key = _key;
      final value = key == null ? null : CacheService.getData(key: key);
      return value is int && value >= 0 && value < 5 ? value : 0;
    } catch (_) {
      return 0;
    }
  }

  static Future<void> save(int value) async {
    try {
      final key = _key;
      if (key != null) await CacheService.setData(key: key, value: value);
    } catch (_) {
      /* Tab persistence must never interrupt navigation. */
    }
  }
}
