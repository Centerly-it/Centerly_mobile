// ---------------------------------------------------------------------------
// Brand logo
// ---------------------------------------------------------------------------

import 'package:centrally/core/func/extensions.dart';
import 'package:centrally/core/res/assets_manager.dart';
import 'package:centrally/core/res/values_manager.dart';
import 'package:flutter/material.dart';

class BrandLogo extends StatelessWidget {
  const BrandLogo({super.key});

  @override
  Widget build(BuildContext context) {
    final logoWidth = context.screenWidth * 0.35;
    final logoHeight = logoWidth;
    return Center(
      child: Image.asset(
        AssetsManager.logoAppIcon,
        width: logoWidth,
        height: logoHeight,
        errorBuilder: (_, __, _) =>
            const SizedBox(width: AppSize.s120, height: AppSize.s120),
      ),
    );
  }
}
