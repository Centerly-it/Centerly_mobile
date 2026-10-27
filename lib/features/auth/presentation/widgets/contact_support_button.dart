import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../../core/config/app_config.dart';
import '../../../../core/di/di.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/diagnostics/app_diagnostics.dart';

class ContactSupportButton extends StatelessWidget {
  const ContactSupportButton({super.key, this.outlined = false});
  final bool outlined;
  static Future<void> contact(BuildContext context) async {
    var uri = getIt<AppConfig>().supportUri;
    if (uri?.host == 'wa.me' && !uri!.queryParameters.containsKey('text')) {
      uri = uri.replace(
        queryParameters: {
          ...uri.queryParameters,
          'text': 'auth_support_message'.tr(),
        },
      );
    }
    bool opened = false;
    try {
      if (uri != null) {
        opened = await launchUrl(uri, mode: LaunchMode.externalApplication);
      }
    } catch (error, stack) {
      AppDiagnostics.current.failure(
        'support.contact',
        'SUPPORT_UNAVAILABLE',
        stack,
        error,
      );
      /* Show a localized failure below. */
    }
    if (!opened && context.mounted) {
      AppDiagnostics.current.failure(
        'support.contact',
        uri == null ? 'CONFIG_INVALID' : 'SUPPORT_UNAVAILABLE',
      );
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('auth_support_unavailable'.tr())));
    }
  }

  @override
  Widget build(BuildContext context) {
    return outlined
        ? AppButton(
            text: 'auth_contact_support'.tr(),
            onPressed: () => contact(context),
            outlined: true,
          )
        : TextButton(
            onPressed: () => contact(context),
            child: Text('auth_contact_support'.tr()),
          );
  }
}
