import 'package:centrally/core/res/color_manager.dart';
import 'package:centrally/core/res/font_manager.dart';
import 'package:centrally/core/res/strings_manager.dart';
import 'package:centrally/core/res/values_manager.dart';
import 'package:centrally/core/utils/validation.dart';
import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';

class PasswordRequirements extends StatelessWidget {
  final PasswordValidationState state;

  const PasswordRequirements({super.key, required this.state});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _item(context, StringsManager.passwordMin, state.hasMinLength),
        _item(context, StringsManager.passwordUpperCase, state.hasUppercase),
        _item(context, StringsManager.paswordLowerCase, state.hasLowercase),
        _item(context, StringsManager.passwordNumber, state.hasNumber),
        _item(context, StringsManager.passwordSpecial, state.hasSpecial),
      ],
    );
  }

  Widget _item(BuildContext context, String key, bool valid) {
    final color = valid
        ? Theme.of(context).colorScheme.primary
        : ColorManager.grey300;

    return Row(
      children: [
        Icon(
          valid ? Icons.check_circle : Icons.cancel,
          size: AppSize.s18,
          color: color,
        ),
        const SizedBox(width: AppSize.s6),
        Text(
          key.tr(),
          style: TextStyle(color: color, fontSize: FontSize.s12),
        ),
      ],
    );
  }
}
