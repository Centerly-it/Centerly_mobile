import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import '../../../../core/theme/color_manager.dart';

class AuthErrorText extends StatelessWidget {
  const AuthErrorText(this.code, {super.key});
  final String code;
  @override
  Widget build(BuildContext context) => Semantics(
    liveRegion: true,
    child: Text(
      'auth_error_$code'.tr(),
      style: Theme.of(
        context,
      ).textTheme.bodyMedium?.copyWith(color: ColorManager.error),
    ),
  );
}
