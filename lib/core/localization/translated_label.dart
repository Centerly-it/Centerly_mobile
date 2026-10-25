import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/widgets.dart';
import 'codegen_loader.g.dart';

/// A refreshed label must never expose its key when hot reload retains an older
/// EasyLocalization dictionary. Normal translations remain the first choice.
String translatedLabel(BuildContext context, String key) {
  final translated = key.tr(context: context);
  if (translated != key) return translated;
  final labels =
      CodegenLoader.mapLocales[context.locale.toString()] ??
      CodegenLoader.mapLocales[context.locale.languageCode];
  return labels?[key] as String? ?? 'live_missing_value'.tr(context: context);
}
