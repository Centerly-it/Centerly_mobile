import 'package:centrally/core/extensions/context_extensions.dart';
import 'package:centrally/core/constants/assets_manager.dart';
import 'package:centrally/core/theme/values_manager.dart';
import 'package:flutter/material.dart';

class BrandLogo extends StatelessWidget {
  const BrandLogo({super.key, this.size, this.showTagline = true});

  final double? size;
  final bool showTagline;

  @override
  Widget build(BuildContext context) {
    final logoSize =
        size ?? (context.screenWidth * 0.35).clamp(AppSize.s100, AppSize.s200);
    final image = Image.asset(
      AssetsManager.logoAppIcon,
      width: logoSize,
      height: logoSize,
      fit: BoxFit.contain,
      errorBuilder: (_, _, _) => SizedBox(width: logoSize, height: logoSize),
    );
    return Center(
      child: showTagline
          ? image
          : ClipRect(
              child: Align(
                alignment: Alignment.topCenter,
                // The tagline is baked into the source PNG below the brand wordmark.
                heightFactor: 0.74,
                child: image,
              ),
            ),
    );
  }
}
