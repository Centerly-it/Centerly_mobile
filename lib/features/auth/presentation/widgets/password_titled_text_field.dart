import 'package:centrally/core/theme/color_manager.dart';
import 'package:centrally/core/constants/icons_manager.dart';
import 'package:centrally/core/constants/strings_manager.dart';
import 'package:centrally/core/theme/style_manager.dart';
import 'package:centrally/core/theme/values_manager.dart';
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

  void _togglePasswordVisibility() {
    setState(() => obscurePassword = !obscurePassword);
  }

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
        Text(widget.title, style: AppTextStyles.titleSmall),
        const SizedBox(height: AppSize.s8),
        TextFormField(
          controller: widget.controller,
          obscureText: obscurePassword,
          textAlign: TextAlign.start,
          style: Theme.of(context).textTheme.bodyMedium,
          decoration: InputDecoration(
            filled: true,
            fillColor: ColorManager.grey100,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: AppPadding.p16,
              vertical: AppPadding.p14,
            ),
            hintText: widget.hint,
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
                widget.icon,
                colorFilter: const ColorFilter.mode(
                  ColorManager.grey500,
                  BlendMode.srcIn,
                ),
              ),
            ),
            suffixIcon: IconButton(
              onPressed: _togglePasswordVisibility,
              icon: SvgPicture.asset(
                obscurePassword
                    ? IconsManager.eyeVisibleIcon
                    : IconsManager.eyeInvisibleIcon,
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
        const SizedBox(height: AppSize.s8),
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
