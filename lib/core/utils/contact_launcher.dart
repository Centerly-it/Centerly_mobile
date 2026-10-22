import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';

String? contactDigits(String phone) {
  var digits = phone.replaceAll(RegExp(r'[\s()+-]'), '');
  if (!RegExp(r'^\d{7,15}$').hasMatch(digits)) return null;
  if (digits.startsWith('00')) digits = digits.substring(2);
  if (digits.length == 11 && digits.startsWith('01')) digits = '2$digits';
  return digits;
}

Future<void> openContact(
  BuildContext context,
  String phone, {
  required bool whatsapp,
}) async {
  final digits = contactDigits(phone);
  var opened = false;
  if (digits != null) {
    try {
      opened = await launchUrl(
        whatsapp
            ? Uri.https('wa.me', '/$digits')
            : Uri(scheme: 'tel', path: '+$digits'),
        mode: LaunchMode.externalApplication,
      );
    } catch (_) {
      /* Offer a copy action without logging contact data. */
    }
  }
  if (!opened && context.mounted) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('contact_unavailable'.tr()),
        action: SnackBarAction(
          label: 'student_design_copy_phone'.tr(),
          onPressed: () => Clipboard.setData(ClipboardData(text: phone)),
        ),
      ),
    );
  }
}
