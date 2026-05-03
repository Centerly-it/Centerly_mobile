import 'package:centrally/core/res/color_manager.dart';
import 'package:centrally/core/res/strings_manager.dart';
import 'package:centrally/core/res/style_manager.dart';
import 'package:centrally/core/res/values_manager.dart';
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

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        //Title
        Text(title, style: AppTextStyles.titleSmall),
        //TextField
        Padding(
          padding: const EdgeInsets.symmetric(vertical: AppPadding.p16),
          child: TextFormField(
            controller: controller,
            keyboardType: keyboardType,
            textAlign: TextAlign.start,
            decoration: InputDecoration(
              fillColor: ColorManager.grey200,
              contentPadding: const EdgeInsets.all(AppPadding.p20),
              hintText: hint,
              hintStyle: AppTextStyles.bodyLarge.copyWith(
                color: ColorManager.grey500,
              ),
              enabledBorder: OutlineInputBorder(
                borderSide: const BorderSide(
                  color: ColorManager.grey300,
                  width: 1,
                ),
                borderRadius: BorderRadius.circular(12),
              ),
              prefixIcon: Padding(
                padding: const EdgeInsets.all(AppPadding.p10),
                child: SvgPicture.asset(icon),
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
        ),
      ],
    );
  }
}
