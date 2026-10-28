import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart' show appFlavor;
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import '../../../core/config/app_config.dart';
import '../presentation/update_controller.dart';
import 'update_repository.dart';
import 'update_downloader.dart';
import 'update_platform.dart';

Future<UpdateController?> createUpdateController() async {
  if (kIsWeb || !Platform.isAndroid) return null;
  const environment = String.fromEnvironment(
    'APP_ENV',
    defaultValue: 'development',
  );
  if (!AppConfig.matchesFlavor(appFlavor, environment)) return null;
  const platform = AndroidUpdatePlatform();
  final identity = await platform.identity();
  final directory = Directory(
    '${(await getTemporaryDirectory()).path}/centerly_updates',
  );
  final client = http.Client();
  return UpdateController(
    repository: UpdateRepository(
      client,
      directory,
      environment: environment,
      packageId: identity.packageId,
    ),
    downloader: UpdateDownloader(client, directory),
    platform: platform,
    manifestUri: Uri.parse(
      'https://centerly-secretary.pages.dev/updates/android-${environment == 'production' ? 'prod' : 'dev'}.json',
    ),
  );
}
