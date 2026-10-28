import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import '../../../core/theme/color_manager.dart';
import '../../../core/theme/values_manager.dart';
import '../../../core/theme/style_manager.dart';
import '../../auth/presentation/widgets/contact_support_button.dart';
import 'update_controller.dart';

class UpdateDialog extends StatelessWidget {
  const UpdateDialog({required this.controller, super.key});
  final UpdateController controller;
  @override
  Widget build(BuildContext context) {
    final c = controller;
    final phase = c.phase;
    final label = phase == UpdatePhase.permission
        ? 'update_allow_install'
        : phase == UpdatePhase.ready
        ? 'update_install'
        : phase == UpdatePhase.error
        ? 'update_retry'
        : 'update_download';
    return AlertDialog(
      icon: const Icon(
        Icons.system_update_rounded,
        color: ColorManager.primary,
        size: AppSize.s32,
      ),
      title: Text('update_title'.tr()),
      content: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 360),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text((c.mandatory ? 'update_required' : 'update_optional').tr()),
            const SizedBox(height: AppSize.s12),
            Text(
              'update_version'.tr(
                args: [
                  c.manifest!.version,
                  (c.manifest!.size / 1048576).toStringAsFixed(1),
                ],
              ),
            ),
            if (phase == UpdatePhase.downloading) ...[
              const SizedBox(height: AppSize.s16),
              LinearProgressIndicator(
                value: c.total == 0 ? null : c.received / c.total,
              ),
              const SizedBox(height: AppSize.s8),
              Text('${c.total == 0 ? 0 : c.received * 100 ~/ c.total}%'),
            ],
            if (phase == UpdatePhase.permission) ...[
              const SizedBox(height: AppSize.s12),
              Text('update_permission_help'.tr()),
            ],
            if (phase == UpdatePhase.ready) ...[
              const SizedBox(height: AppSize.s12),
              Text('update_installer_help'.tr()),
            ],
            if (phase == UpdatePhase.incompatible || c.error != null) ...[
              const SizedBox(height: AppSize.s12),
              Text(
                'update_error_${phase == UpdatePhase.incompatible ? 'UPDATE_INCOMPATIBLE' : c.error}'
                    .tr(),
                style: const TextStyle(color: ColorManager.error),
              ),
            ],
            const SizedBox(height: AppSize.s20),
            if (phase != UpdatePhase.incompatible)
              FilledButton(
                onPressed: c.busy ? null : () => c.action(),
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: AppPadding.p12),
                  child: Text(
                    (c.busy ? 'update_working' : label).tr(),
                    textAlign: TextAlign.center,
                    style: AppTextStyles.titleMedium.copyWith(
                      color: ColorManager.white,
                    ),
                  ),
                ),
              ),
            if (!c.mandatory)
              TextButton(
                onPressed: c.busy ? null : c.dismiss,
                child: Text('update_later'.tr()),
              ),
            TextButton(
              onPressed: () => ContactSupportButton.contact(context),
              child: Text('auth_contact_support'.tr()),
            ),
          ],
        ),
      ),
    );
  }
}
