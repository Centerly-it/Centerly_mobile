import 'package:flutter/services.dart';

class UpdateIdentity {
  const UpdateIdentity(
    this.packageId,
    this.build,
    this.sdk,
    this.availableBytes,
  );
  final String packageId;
  final int build, sdk, availableBytes;
}

abstract class UpdatePlatform {
  Future<UpdateIdentity> identity();
  Future<bool> canInstall();
  Future<void> openSettings();
  Future<void> install(String path, int build, int size, String hash);
}

class AndroidUpdatePlatform implements UpdatePlatform {
  const AndroidUpdatePlatform();
  static const _channel = MethodChannel('centerly/app_updates');
  @override
  Future<UpdateIdentity> identity() async {
    final m = (await _channel.invokeMapMethod<String, dynamic>('identity'))!;
    return UpdateIdentity(
      m['package_id'] as String,
      m['build'] as int,
      m['sdk'] as int,
      m['available_bytes'] as int,
    );
  }

  @override
  Future<bool> canInstall() async =>
      await _channel.invokeMethod<bool>('canInstall') ?? false;
  @override
  Future<void> openSettings() => _channel.invokeMethod<void>('openSettings');
  @override
  Future<void> install(String path, int build, int size, String hash) =>
      _channel.invokeMethod<void>('install', {
        'path': path,
        'build': build,
        'size': size,
        'sha256': hash,
      });
}
