import 'package:flutter/foundation.dart';

class PreviewMode {
  PreviewMode._();
  static const enabled =
      kDebugMode &&
      bool.fromEnvironment('CENTERLY_UI_PREVIEW', defaultValue: false);
}
