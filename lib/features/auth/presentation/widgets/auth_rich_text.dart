import 'package:centrally/core/res/color_manager.dart';
import 'package:centrally/core/res/style_manager.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';

class AuthRichText extends StatelessWidget {
  const AuthRichText({super.key, required this.onTap});
  final Function() onTap;

  @override
  Widget build(BuildContext context) {
    return RichText(
      textAlign: TextAlign.center,
      text: TextSpan(
        text: "${tr("no_account")} ",
        style: StyleManager.bodySemiBold(
          context,
        ).copyWith(color: ColorManager.bodyText),
        children: [
          TextSpan(
            // child: GestureDetector(
            //   onTap: onTap,
            text: tr('register_link'),
            style: StyleManager.bodySemiBold(context),
            recognizer: TapGestureRecognizer()..onTap = onTap,
          ),
        ],
      ),
    );
  }
}
