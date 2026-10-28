import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import '../../../core/diagnostics/app_diagnostics.dart';
import '../data/update_downloader.dart';
import '../data/update_platform.dart';
import '../data/update_repository.dart';
import '../domain/update_manifest.dart';
part 'update_checks.dart';
part 'update_actions.dart';

enum UpdatePhase { idle, downloading, ready, permission, incompatible, error }

class UpdateController extends ChangeNotifier {
  UpdateController({
    required this.repository,
    required this.downloader,
    required this.platform,
    required this.manifestUri,
  });
  final UpdateRepository repository;
  final UpdateDownloader downloader;
  final UpdatePlatform platform;
  final Uri manifestUri;
  UpdateManifest? manifest;
  UpdateIdentity? identity;
  UpdatePhase phase = UpdatePhase.idle;
  String? error;
  int received = 0, total = 0;
  bool _checking = false, _busy = false, _dead = false, _cacheLoaded = false;
  int? _dismissed;
  File? _verified;
  DateTime? _checkedAt;
  bool get mandatory =>
      identity != null && manifest?.requiredFor(identity!.build) == true;
  bool get visible =>
      manifest != null &&
      identity != null &&
      manifest!.availableFor(identity!.build) &&
      (mandatory || _dismissed != manifest!.latestBuild);
  bool get busy => _busy;
  void _emit() {
    if (!_dead) notifyListeners();
  }

  Future<void> check({bool force = false}) => _checkPolicy(force: force);
  Future<void> action() => _performAction();
  void dismiss() {
    if (!mandatory && !_busy) {
      _dismissed = manifest?.latestBuild;
      _emit();
    }
  }

  Future<void> resumed() async {
    if (_busy || _dead) return;
    if (phase == UpdatePhase.permission && await platform.canInstall()) {
      if (_dead) return;
      phase = UpdatePhase.ready;
      _emit();
    }
    await check();
  }

  @override
  void dispose() {
    _dead = true;
    repository.client.close();
    super.dispose();
  }
}
