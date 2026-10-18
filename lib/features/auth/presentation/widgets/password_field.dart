// ---------------------------------------------------------------------------
// Password field
// ---------------------------------------------------------------------------

import 'package:centrally/core/theme/color_manager.dart';
import 'package:centrally/core/constants/strings_manager.dart';
import 'package:centrally/core/theme/style_manager.dart';
import 'package:centrally/core/theme/values_manager.dart';
import 'package:centrally/core/utils/validation.dart';
import 'package:centrally/core/widgets/custom_text_field.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

class PasswordField extends StatelessWidget {
  const PasswordField({
    required this.controller,
    required this.obscure,
    required this.onToggleObscure,
    super.key,
    this.onChanged,
    this.loginOnly = false,
  });

  final TextEditingController controller;
  final bool obscure;
  final VoidCallback onToggleObscure;
  final Function(String)? onChanged;
  final bool loginOnly;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          StringsManager.loginPasswordLabel.tr(),
          style: AppTextStyles.titleSmall,
        ),

        const SizedBox(height: AppSize.s8),
        CustomTextFormField(
          controller: controller,
          hintText: StringsManager.loginPasswordLabel.tr(),
          obscureText: obscure,
          onChanged: onChanged,
          prefixIcon: const Icon(
            Icons.lock_outline,
            color: ColorManager.grey500,
            size: AppSize.s24,
          ),
          suffixIcon: IconButton(
            onPressed: onToggleObscure,
            icon: Icon(
              obscure
                  ? Icons.visibility_off_outlined
                  : Icons.visibility_outlined,
              color: ColorManager.grey500,
              size: AppSize.s24,
            ),
          ),
          autofillHints: const [AutofillHints.password],
          validator: (value) => loginOnly
              ? ((value == null || value.isEmpty)
                    ? StringsManager.validationPasswordRequired.tr()
                    : null)
              : AuthValidator.validatePassword(value),
        ),
      ],
    );
  }
}
