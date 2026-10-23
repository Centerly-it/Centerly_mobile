import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../../core/utils/contact_launcher.dart';
import '../../../../core/theme/color_manager.dart';
import 'student_design.dart';

class StudentContactAction extends StatelessWidget {
  const StudentContactAction({
    required this.phone,
    required this.whatsapp,
    required this.preview,
    required this.label,
    super.key,
  });
  final String? phone;
  final bool whatsapp, preview;
  final String label;
  Future<void> _preview(BuildContext context) => showDialog<void>(
    context: context,
    builder: (context) => AlertDialog(
      title: Text(label),
      content: const SelectableText('0123456789'),
      actions: [
        TextButton(
          onPressed: () {
            Clipboard.setData(const ClipboardData(text: '0123456789'));
            Navigator.of(context).pop();
          },
          child: Text('student_design_copy_phone'.tr()),
        ),
      ],
    ),
  );
  @override
  Widget build(BuildContext context) => IconButton(
    style: IconButton.styleFrom(
      padding: EdgeInsets.zero,
      fixedSize: const Size(44, 44),
      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
      side: whatsapp
          ? const BorderSide(color: ColorManager.successBorder)
          : null,
      shape: const CircleBorder(),
    ),
    tooltip: (whatsapp ? 'student_design_whatsapp' : 'student_design_call')
        .tr(),
    onPressed: preview
        ? () => _preview(context)
        : contactUri(phone ?? '', whatsapp: whatsapp) == null
        ? null
        : () => openContact(context, phone!, whatsapp: whatsapp),
    icon: StudentAsset(whatsapp ? 'f921f.svg' : '853f1.svg'),
  );
}
