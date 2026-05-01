// ---------------------------------------------------------------------------
// Email field
// ---------------------------------------------------------------------------

import 'package:centrally/core/res/color_manager.dart';
import 'package:centrally/core/res/strings_manager.dart';
import 'package:centrally/core/res/style_manager.dart';
import 'package:centrally/core/res/values_manager.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

class EmailField extends StatelessWidget {
  const EmailField({required this.controller, super.key});

  final TextEditingController controller;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Text(
          StringsManager.loginEmailLabel.tr(),
          style: AppTextStyles.titleSmall,
        ),
        const SizedBox(height: AppSize.s8),
        TextFormField(
          controller: controller,
          keyboardType: TextInputType.emailAddress,
          textAlign: TextAlign.left,
          decoration: InputDecoration(
            hintText: StringsManager.loginEmailHint.tr(),
            suffixIcon: Container(
              margin: const EdgeInsets.all(AppSize.s10),
              padding: const EdgeInsets.all(AppSize.s8),
              decoration: BoxDecoration(
                color: ColorManager.grey100,
                borderRadius: BorderRadius.circular(AppSize.s8),
              ),
              child: const Icon(
                Icons.email_outlined,
                color: ColorManager.grey500,
                size: AppSize.s18,
              ),
            ),
          ),
          validator: (v) {
            if (v == null || v.trim().isEmpty) {
              return StringsManager.validationEmailRequired.tr();
            }
            final emailRegex = RegExp(r'^[\w-.]+@([\w-]+\.)+[\w-]{2,4}$');
            if (!emailRegex.hasMatch(v.trim())) {
              return StringsManager.validationEmailInvalid.tr();
            }
            return null;
          },
        ),
      ],
    );
  }
}
