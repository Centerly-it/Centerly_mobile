import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';

String? contactDigits(String phone) {
  const arabic = '٠١٢٣٤٥٦٧٨٩', persian = '۰۱۲۳۴۵۶۷۸۹';
  var normalized = phone;
  for (var i = 0; i < 10; i++) {
    normalized = normalized
        .replaceAll(arabic[i], '$i')
        .replaceAll(persian[i], '$i');
  }
  var digits = normalized.replaceAll(RegExp(r'[\s()+-]'), '');
  if (digits.startsWith('00')) digits = digits.substring(2);
  if (!RegExp(r'^\d{7,15}$').hasMatch(digits)) return null;
  if (digits.length == 11 && digits.startsWith('01')) digits = '2$digits';
  return digits;
}

Uri? contactUri(String phone, {required bool whatsapp}) {
  final digits = contactDigits(phone);
  if (digits == null) return null;
  return whatsapp
      ? Uri(
          scheme: 'whatsapp',
          host: 'send',
          queryParameters: {'phone': digits},
        )
      : Uri(scheme: 'tel', path: '+$digits');
}

Future<bool> _launchContact(Uri uri) async {
  try {
    return await launchUrl(uri, mode: LaunchMode.externalApplication);
  } catch (_) {
    return false;
  }
}

Future<void> openContact(
  BuildContext context,
  String phone, {
  required bool whatsapp,
}) async {
  final uri = contactUri(phone, whatsapp: whatsapp);
  var opened = false;
  if (uri != null) {
    opened = await _launchContact(uri);
    if (!opened && whatsapp) {
      final digits = contactDigits(phone)!;
      opened = await _launchContact(Uri.https('wa.me', '/$digits'));
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
