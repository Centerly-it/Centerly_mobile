import 'package:flutter/material.dart';
import 'package:centrally/core/res/color_manager.dart';
import 'package:centrally/core/res/values_manager.dart';

class _IllustrationCard extends StatelessWidget {
  const _IllustrationCard({required this.asset});

  final String asset;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(AppSize.s24),
      child: Container(
        color: ColorManager.background,
        padding: const EdgeInsets.all(AppPadding.p24),
        child: Image.asset(
          asset,
          fit: BoxFit.contain,
          errorBuilder: (_, __, _) => const _IllustrationPlaceholder(),
        ),
      ),
    );
  }
}

class _IllustrationPlaceholder extends StatelessWidget {
  const _IllustrationPlaceholder();

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Icon(
        Icons.image_outlined,
        size: AppSize.s100,
        color: ColorManager.grey300,
      ),
    );
  }
}
