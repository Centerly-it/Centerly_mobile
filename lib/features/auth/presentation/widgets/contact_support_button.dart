import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../../core/config/app_config.dart';
import '../../../../core/di/di.dart';

class ContactSupportButton extends StatelessWidget {
  const ContactSupportButton({super.key});
  @override
  Widget build(BuildContext context) => TextButton(
    child: Text('auth_contact_support'.tr()),
    onPressed: () async {
      final uri = getIt<AppConfig>().supportUri;
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
    },
  );
}
