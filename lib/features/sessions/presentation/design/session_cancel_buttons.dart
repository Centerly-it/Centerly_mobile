import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import '../../../../core/theme/values_manager.dart';
import 'session_design.dart';

class SessionCancelButtons extends StatelessWidget {
  const SessionCancelButtons({required this.onConfirm, super.key});
  final VoidCallback onConfirm;
  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.stretch,
    children: [
      FilledButton(
        style: FilledButton.styleFrom(
          backgroundColor: SessionDesign.red,
          minimumSize: const Size.fromHeight(44),
        ),
        onPressed: onConfirm,
        child: Text('cancel_submit'.tr()),
      ),
      const SizedBox(height: AppSize.s12),
      OutlinedButton(
        style: OutlinedButton.styleFrom(
          side: const BorderSide(color: SessionDesign.stroke),
          foregroundColor: SessionDesign.muted,
        ),
        onPressed: () => Navigator.of(context).pop(),
        child: Text('cancel_back'.tr()),
      ),
    ],
  );
}
