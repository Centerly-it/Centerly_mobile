import 'package:centrally/core/res/color_manager.dart';
import 'package:centrally/core/res/icons_manager.dart';
import 'package:centrally/core/res/strings_manager.dart';
import 'package:centrally/core/res/style_manager.dart';
import 'package:centrally/core/res/values_manager.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:centrally/features/auth/presentation/widgets/validation_check.dart';

class PasswordTitledTextField extends StatefulWidget {
  const PasswordTitledTextField({
    super.key,
    required this.controller,
    required this.title,
    required this.hint,
    required this.icon,
    this.isPassword = false,
    this.isConfirmPassword = false,
    this.showValidationChecks = false,
    this.matchController,
  });
  final TextEditingController controller;
  final TextEditingController? matchController;
  final String title, hint, icon;

  final bool isPassword, isConfirmPassword, showValidationChecks;
  @override
  State<PasswordTitledTextField> createState() =>
      _PasswordTitledTextFieldState();
}

class _PasswordTitledTextFieldState extends State<PasswordTitledTextField> {
  bool obscurePassword = true;
  bool hasMinLength = false;
  bool hasNumber = false;
  bool hasUppercase = false;
  void togglePasswordVisibility() {
    setState(() {
      obscurePassword = !obscurePassword;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        //Title
        Text(widget.title, style: AppTextStyles.titleSmall),
        //TextField
        Padding(
          padding: const EdgeInsets.symmetric(vertical: AppPadding.p16),
          child: TextFormField(
            controller: widget.controller,
            obscureText: obscurePassword,
            textAlign: TextAlign.start,
            decoration: InputDecoration(
              fillColor: ColorManager.grey200,
              contentPadding: const EdgeInsets.all(AppPadding.p20),
              hintText: widget.hint,
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
                child: SvgPicture.asset(widget.icon),
              ),
              suffixIcon: GestureDetector(
                onTap: togglePasswordVisibility,
                child: Padding(
                  padding: const EdgeInsets.all(AppPadding.p10),
                  child: SvgPicture.asset(
                    obscurePassword
                        ? IconsManager.eyeVisibleIcon
                        : IconsManager.eyeInvisibleIcon,
                  ),
                ),
              ),
            ),
            validator: (v) {
              if (v == null || v.trim().isEmpty) {
                return StringsManager.validationRequired.tr();
              }
              if (widget.isPassword) {
                final hasMinLength = v.length >= 8;
                final hasNumber = v.contains(RegExp(r'[0-9]'));
                final hasUppercase = v.contains(RegExp(r'[A-Z]'));
                if (!hasMinLength || !hasNumber || !hasUppercase) {
                  return StringsManager.validationPasswordConditions.tr();
                }
              }
              if (widget.isConfirmPassword &&
                  widget.matchController != null &&
                  v != widget.matchController!.text) {
                return StringsManager.validationPasswordMismatch.tr();
              }
              return null;
            },
          ),
        ),

        if (widget.showValidationChecks)
          ValueListenableBuilder<TextEditingValue>(
            valueListenable: widget.controller,
            builder: (context, value, child) {
              final text = value.text;
              final hasMinLength = text.length >= 8;
              final hasNumber = text.contains(RegExp(r'[0-9]'));
              final hasUppercase = text.contains(RegExp(r'[A-Z]'));
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ValidationCheck(
                    validTitle: StringsManager.passwordMinLength.tr(),
                    isValid: hasMinLength,
                  ),
                  const SizedBox(height: AppPadding.p8),
                  ValidationCheck(
                    validTitle: StringsManager.passwordNumber.tr(),
                    isValid: hasNumber,
                  ),
                  const SizedBox(height: AppPadding.p8),
                  ValidationCheck(
                    validTitle: StringsManager.passwordUppercase.tr(),
                    isValid: hasUppercase,
                  ),
                ],
              );
            },
          ),
      ],
    );
  }
}
