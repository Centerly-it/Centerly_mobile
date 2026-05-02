import 'package:centrally/core/res/color_manager.dart';
import 'package:flutter/material.dart';

class CustomTextFormField extends StatelessWidget {
  final TextEditingController controller;
  final String hintText;
  final String? labelText;

  final bool obscureText;
  final TextInputType keyboardType;
  final TextInputAction textInputAction;

  final FocusNode? focusNode;
  final FocusNode? nextFocusNode;

  final Widget? prefixIcon;
  final Widget? suffixIcon;

  final String? Function(String?)? validator;
  final void Function(String)? onChanged;

  const CustomTextFormField({
    super.key,
    required this.controller,
    required this.hintText,
    this.labelText,
    this.obscureText = false,
    this.keyboardType = TextInputType.text,
    this.textInputAction = TextInputAction.next,
    this.focusNode,
    this.nextFocusNode,
    this.prefixIcon,
    this.suffixIcon,
    this.validator,
    this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return TextFormField(
      controller: controller,
      obscureText: obscureText,
      keyboardType: keyboardType,
      textInputAction: textInputAction,
      focusNode: focusNode,
      validator: validator,
      onChanged: onChanged,
      textAlign: TextAlign.start,
      style: theme.textTheme.bodyMedium,

      onFieldSubmitted: (_) {
        if (nextFocusNode != null) {
          FocusScope.of(context).requestFocus(nextFocusNode);
        } else {
          FocusScope.of(context).unfocus();
        }
      },

      decoration: InputDecoration(
        labelText: labelText,
        hintText: hintText,

        prefixIcon: prefixIcon,
        suffixIcon: suffixIcon,

        filled: true,
        fillColor: ColorManager.grey100,

        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 14,
        ),

        border: _border(),
        enabledBorder: _border(),
        focusedBorder: _border(color: ColorManager.primary, width: 2),

        errorBorder: _border(color: Colors.red),
        focusedErrorBorder: _border(color: Colors.red, width: 2),
      ),
    );
  }

  OutlineInputBorder _border({Color? color, double width = 1}) {
    return OutlineInputBorder(
      borderRadius: BorderRadius.circular(10),
      borderSide: BorderSide(color: color ?? ColorManager.border, width: width),
    );
  }
}
