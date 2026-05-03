// ---------------------------------------------------------------------------
// Email field
// ---------------------------------------------------------------------------

import 'package:centrally/core/func/extensions.dart';
import 'package:centrally/core/res/color_manager.dart';
import 'package:centrally/core/res/strings_manager.dart';
import 'package:centrally/core/res/style_manager.dart';
import 'package:centrally/core/res/values_manager.dart';
import 'package:centrally/core/utils/validation.dart';
import 'package:centrally/core/widgets/custom_text_field.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

class EmailField extends StatelessWidget {
  const EmailField({required this.controller, super.key});

  final TextEditingController controller;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          StringsManager.loginEmailLabel.tr(),
          style: AppTextStyles.titleSmall,
        ),
        SizedBox(height: context.screenHeight * 0.01), //AppSize.s8
        CustomTextFormField(
          controller: controller,
          hintText: StringsManager.loginEmailHint.tr(),
          prefixIcon: const Icon(
            Icons.email_outlined,
            color: ColorManager.grey500,
            size: AppSize.s24,
          ),
          validator: (value) => AuthValidator.validateEmail(value),
        ),
      ],
    );
  }
}
