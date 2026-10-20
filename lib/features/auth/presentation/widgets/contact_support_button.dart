import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../../core/config/app_config.dart';
import '../../../../core/di/di.dart';
import '../../../../core/widgets/app_button.dart';

class ContactSupportButton extends StatelessWidget {
  const ContactSupportButton({super.key, this.outlined = false});
  final bool outlined;
  @override
  Widget build(BuildContext context) {
    Future<void> contact() async {
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
      } catch (_) {
        /* Show a localized failure below. */
      }
      if (!opened && context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('auth_support_unavailable'.tr())),
        );
      }
    }

    return outlined
        ? AppButton(
            text: 'auth_contact_support'.tr(),
            onPressed: contact,
            outlined: true,
          )
        : TextButton(
            onPressed: contact,
            child: Text('auth_contact_support'.tr()),
          );
  }
}
