part of 'update_controller.dart';

extension on UpdateController {
  Future<void> _checkPolicy({required bool force}) async {
    if (_dead || _checking || _busy) return;
    if (!force &&
        _checkedAt != null &&
        DateTime.now().difference(_checkedAt!) < const Duration(minutes: 15)) {
      return;
    }
    _checking = true;
    try {
      identity = await platform.identity();
      if (_dead) return;
      if (!_cacheLoaded) {
        manifest = await repository.cached();
        _cacheLoaded = true;
        _emit();
      }
      _checkedAt = DateTime.now();
      final fresh = await repository.fetch(manifestUri);
      if (_dead) return;
      if (fresh?.sha256 != manifest?.sha256) {
        _verified = null;
        phase = UpdatePhase.idle;
        error = null;
      }
      manifest = fresh;
      if (manifest != null && identity!.sdk < manifest!.minSdk) {
        phase = UpdatePhase.incompatible;
      }
      _emit();
    } catch (error, stack) {
      // Keep a known required policy while offline. An unavailable policy service
      // alone must never lock out an otherwise compatible installation.
      AppDiagnostics.current.failure(
        'app.update',
        'UPDATE_CHECK_FAILED',
        stack,
        error,
      );
      _emit();
    } finally {
      _checking = false;
    }
  }
}
