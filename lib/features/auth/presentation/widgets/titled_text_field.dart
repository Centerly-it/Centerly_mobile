import 'package:centrally/core/theme/color_manager.dart';
import 'package:centrally/core/constants/strings_manager.dart';
import 'package:centrally/core/theme/style_manager.dart';
import 'package:centrally/core/theme/values_manager.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

class TitledTextField extends StatelessWidget {
  const TitledTextField({
    super.key,
    required this.controller,
    required this.title,
    required this.hint,
    required this.icon,
    required this.keyboardType,
  });
  final TextEditingController controller;
  final String title, hint, icon;
  final TextInputType keyboardType;

  OutlineInputBorder _border({Color? color, double width = 1}) {
    return OutlineInputBorder(
      borderRadius: BorderRadius.circular(AppRadius.r12),
      borderSide: BorderSide(color: color ?? ColorManager.border, width: width),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: AppTextStyles.titleSmall),
        const SizedBox(height: AppSize.s8),
        TextFormField(
          controller: controller,
          keyboardType: keyboardType,
          textAlign: TextAlign.start,
          style: Theme.of(context).textTheme.bodyMedium,
          decoration: InputDecoration(
            filled: true,
            fillColor: ColorManager.grey100,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: AppPadding.p16,
              vertical: AppPadding.p14,
            ),
            hintText: hint,
            hintStyle: AppTextStyles.bodyMedium.copyWith(
              color: ColorManager.grey500,
            ),
            border: _border(),
            enabledBorder: _border(),
            focusedBorder: _border(color: ColorManager.primary, width: 1.5),
            errorBorder: _border(color: ColorManager.error),
            focusedErrorBorder: _border(color: ColorManager.error, width: 1.5),
            prefixIcon: Padding(
              padding: const EdgeInsets.all(AppPadding.p12),
              child: SvgPicture.asset(
                icon,
                colorFilter: const ColorFilter.mode(
                  ColorManager.grey500,
                  BlendMode.srcIn,
                ),
              ),
            ),
          ),
          validator: (v) {
            if (v == null || v.trim().isEmpty) {
              return StringsManager.validationRequired.tr();
            }
            if (keyboardType == TextInputType.emailAddress) {
              if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(v)) {
                return StringsManager.validationEmailInvalid.tr();
              }
            } else if (keyboardType == TextInputType.number) {
              if (!RegExp(r'^[0-9]+$').hasMatch(v)) {
                return StringsManager.validationNumbersOnly.tr();
              }
            }
            return null;
          },
        ),
        const SizedBox(height: AppSize.s20),
      ],
    );
  }
}
