import 'package:centrally/core/res/style_manager.dart';
import 'package:centrally/core/res/values_manager.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

class LabeledIcon extends StatelessWidget {
  const LabeledIcon({super.key, required this.icon, required this.label});
  final String icon, label;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Padding(
          padding: const EdgeInsets.all(AppPadding.p10),
          child: SvgPicture.asset(icon),
        ),
        Text(label, style: AppTextStyles.bodyLarge),
      ],
    );
  }
}
