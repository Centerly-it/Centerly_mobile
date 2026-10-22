import 'package:flutter/foundation.dart';

class PreviewMode {
  PreviewMode._();
  static const enabled =
      kDebugMode &&
      String.fromEnvironment('APP_ENV', defaultValue: 'development') !=
          'production' &&
      bool.fromEnvironment('CENTERLY_UI_PREVIEW', defaultValue: false);
}
