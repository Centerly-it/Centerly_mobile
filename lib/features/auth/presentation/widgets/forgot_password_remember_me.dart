import 'package:centrally/core/res/color_manager.dart';
import 'package:centrally/core/res/style_manager.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

class ForgotPasswordAndRememberMe extends StatefulWidget {
  const ForgotPasswordAndRememberMe({super.key, required this.onPressed});
  final void Function() onPressed;

  @override
  State<ForgotPasswordAndRememberMe> createState() =>
      _ForgotPasswordAndRememberMeState();
}

class _ForgotPasswordAndRememberMeState
    extends State<ForgotPasswordAndRememberMe> {
  bool _rememberMe = false;
  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            SizedBox(
              height: 24,
              width: 24,
              child: Checkbox(
                value: _rememberMe,
                checkColor: ColorManager.primaryBlue,
                fillColor: const WidgetStatePropertyAll(
                  ColorManager.whiteColor,
                ),
                side: WidgetStateBorderSide.resolveWith((states) {
                  if (states.contains(WidgetState.selected)) {
                    return const BorderSide(color: ColorManager.primaryBlue);
                  }
                  return const BorderSide(color: ColorManager.darkText);
                }),
                hoverColor: ColorManager.primaryBlue,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(4),
                ),
                onChanged: (value) =>
                    setState(() => _rememberMe = value ?? false),
              ),
            ),
            const SizedBox(width: 8),
            Text(
              tr('remember_me'),
              style: StyleManager.bodySemiBold(
                context,
              ).copyWith(color: ColorManager.greyHintColor),
            ),
          ],
        ),
        TextButton(
          onPressed: widget.onPressed,
          style: TextButton.styleFrom(
            minimumSize: Size.zero,
            padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
          ),
          child: Text(
            tr('forgot_password'),
            style: StyleManager.bodySemiBold(context),
          ),
        ),
      ],
    );
  }
}
