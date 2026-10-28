part of 'update_controller.dart';

extension on UpdateController {
  Future<void> _performAction() async {
    if (_busy || _dead || !visible || phase == UpdatePhase.incompatible) return;
    _busy = true;
    error = null;
    _emit();
    try {
      if (phase == UpdatePhase.permission) {
        await platform.openSettings();
        return;
      }
      final m = manifest!;
      identity = await platform.identity();
      if (!m.availableFor(identity!.build)) {
        manifest = null;
        phase = UpdatePhase.idle;
        return;
      }
      if (identity!.sdk < m.minSdk) {
        phase = UpdatePhase.incompatible;
        return;
      }
      if (_verified == null) {
        final remaining = await downloader.remaining(m);
        identity = await platform.identity();
        if (identity!.availableBytes < remaining + 10 * 1024 * 1024) {
          throw const FileSystemException('UPDATE_SPACE');
        }
        phase = UpdatePhase.downloading;
        received = m.size - remaining;
        total = m.size;
        _emit();
        _verified = await downloader.download(m, (done, size) {
          if (_dead) return;
          final changed = done * 100 ~/ size != received * 100 ~/ size;
          received = done;
          total = size;
          if (changed) _emit();
        });
      }
      if (_dead) return;
      if (!await platform.canInstall()) {
        phase = UpdatePhase.permission;
        return;
      }
      await platform.install(_verified!.path, m.latestBuild, m.size, m.sha256);
      // Launching Android's installer is not proof of successful installation.
      phase = UpdatePhase.ready;
    } catch (e, stack) {
      if (_dead) return;
      const codes = {
        'UPDATE_SPACE',
        'UPDATE_CHECKSUM',
        'UPDATE_SIGNATURE',
        'UPDATE_INCOMPATIBLE',
        'UPDATE_PERMISSION',
      };
      final code = e is PlatformException
          ? e.code
          : e is FormatException
          ? e.message
          : e is FileSystemException
          ? e.message
          : '';
      error = e is FileSystemException && e.osError?.errorCode == 28
          ? 'UPDATE_SPACE'
          : codes.contains(code)
          ? code
          : 'UPDATE_NETWORK';
      if (code == 'UPDATE_INVALID' ||
          error == 'UPDATE_CHECKSUM' ||
          error == 'UPDATE_SIGNATURE') {
        _verified = null;
      }
      phase = UpdatePhase.error;
      AppDiagnostics.current.failure('app.update', error!, stack, e);
    } finally {
      _busy = false;
      _emit();
    }
  }
}
