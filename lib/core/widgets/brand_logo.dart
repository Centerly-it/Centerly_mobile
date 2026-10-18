import 'package:centrally/core/extensions/context_extensions.dart';
import 'package:centrally/core/constants/assets_manager.dart';
import 'package:centrally/core/theme/values_manager.dart';
import 'package:flutter/material.dart';

class BrandLogo extends StatelessWidget {
  const BrandLogo({super.key, this.size});

  final double? size;

  @override
  Widget build(BuildContext context) {
    final logoSize =
        size ?? (context.screenWidth * 0.35).clamp(AppSize.s100, AppSize.s200);
    return Center(
      child: Image.asset(
        AssetsManager.logoAppIcon,
        width: logoSize,
        height: logoSize,
        errorBuilder: (_, _, _) => SizedBox(width: logoSize, height: logoSize),
      ),
    );
  }
}
