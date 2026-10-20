import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import '../../../core/theme/color_manager.dart';
import '../../../core/theme/values_manager.dart';

class TeacherAvatarMenu extends StatelessWidget {
  const TeacherAvatarMenu({
    required this.child,
    required this.onChange,
    required this.enabled,
    required this.hasPhoto,
    super.key,
  });
  final Widget child;
  final ValueChanged<bool> onChange;
  final bool enabled, hasPhoto;
  @override
  Widget build(BuildContext context) => PopupMenuButton<bool>(
    enabled: enabled,
    tooltip: 'teacher_change_photo'.tr(),
    onSelected: onChange,
    itemBuilder: (_) => [
      PopupMenuItem(
        value: false,
        child: Row(
          children: [
            const Icon(
              Icons.photo_library_outlined,
              color: ColorManager.primary,
            ),
            const SizedBox(width: AppSize.s12),
            Text('teacher_change_photo'.tr()),
          ],
        ),
      ),
      PopupMenuItem(
        value: true,
        enabled: hasPhoto,
        child: Row(
          children: [
            const Icon(Icons.delete_outline, color: ColorManager.error),
            const SizedBox(width: AppSize.s12),
            Text('teacher_remove_photo'.tr()),
          ],
        ),
      ),
    ],
    child: SizedBox(width: AppSize.s48, height: AppSize.s48, child: child),
  );
}
