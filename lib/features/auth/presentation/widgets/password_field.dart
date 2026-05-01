// ---------------------------------------------------------------------------
// Password field
// ---------------------------------------------------------------------------

import 'package:centrally/core/res/color_manager.dart';
import 'package:centrally/core/res/strings_manager.dart';
import 'package:centrally/core/res/style_manager.dart';
import 'package:centrally/core/res/values_manager.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

class PasswordField extends StatelessWidget {
  const PasswordField({
    required this.controller,
    required this.obscure,
    required this.onToggleObscure,
    super.key,
  });

  final TextEditingController controller;
  final bool obscure;
  final VoidCallback onToggleObscure;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Text(
          StringsManager.loginPasswordLabel.tr(),
          style: AppTextStyles.titleSmall,
        ),
        const SizedBox(height: AppSize.s8),
        TextFormField(
          controller: controller,
          obscureText: obscure,
          textAlign: TextAlign.left,
          decoration: InputDecoration(
            prefixIcon: IconButton(
              icon: Icon(
                obscure
                    ? Icons.visibility_outlined
                    : Icons.visibility_off_outlined,
                color: ColorManager.grey500,
                size: AppSize.s20,
              ),
              onPressed: onToggleObscure,
            ),
            suffixIcon: Container(
              margin: const EdgeInsets.all(AppSize.s10),
              padding: const EdgeInsets.all(AppSize.s8),
              decoration: BoxDecoration(
                color: ColorManager.grey100,
                borderRadius: BorderRadius.circular(AppSize.s8),
              ),
              child: const Icon(
                Icons.lock_outline,
                color: ColorManager.grey500,
                size: AppSize.s18,
              ),
            ),
          ),
          validator: (v) {
            if (v == null || v.isEmpty) {
              return StringsManager.validationPasswordRequired.tr();
            }
            if (v.length < 8) {
              return StringsManager.validationPasswordMin.tr();
            }
            return null;
          },
        ),
      ],
    );
  }
}
