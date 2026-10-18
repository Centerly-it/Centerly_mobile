import 'package:centrally/core/theme/color_manager.dart';
import 'package:centrally/core/theme/values_manager.dart';
import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

/// Base shimmer container — used to build skeleton shapes.
class AppSkeleton extends StatelessWidget {
  const AppSkeleton({
    required this.width,
    required this.height,
    super.key,
    this.borderRadius = AppRadius.r8,
  });

  final double width;
  final double height;
  final double borderRadius;

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: ColorManager.grey200,
      highlightColor: ColorManager.grey100,
      child: Container(
        width: width,
        height: height,
        decoration: BoxDecoration(
          color: ColorManager.grey200,
          borderRadius: BorderRadius.circular(borderRadius),
        ),
      ),
    );
  }
}

/// A card-shaped skeleton placeholder — mimics a content card.
class AppSkeletonCard extends StatelessWidget {
  const AppSkeletonCard({super.key, this.height = AppSize.s80, this.lines = 2});

  final double height;
  final int lines;

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: ColorManager.grey200,
      highlightColor: ColorManager.grey100,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(AppPadding.p16),
        decoration: BoxDecoration(
          color: ColorManager.surface,
          borderRadius: BorderRadius.circular(AppRadius.r12),
          border: Border.all(color: ColorManager.divider),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              height: AppSize.s14,
              width: double.infinity,
              decoration: BoxDecoration(
                color: ColorManager.grey200,
                borderRadius: BorderRadius.circular(AppRadius.r4),
              ),
            ),
            if (lines > 1) ...[
              const SizedBox(height: AppSize.s10),
              Container(
                height: AppSize.s12,
                width: 180,
                decoration: BoxDecoration(
                  color: ColorManager.grey200,
                  borderRadius: BorderRadius.circular(AppRadius.r4),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

/// A column of [count] skeleton cards, for use while data is loading.
class AppSkeletonList extends StatelessWidget {
  const AppSkeletonList({
    super.key,
    this.count = 4,
    this.spacing = AppSize.s12,
  });

  final int count;
  final double spacing;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        for (int i = 0; i < count; i++) ...[
          const AppSkeletonCard(),
          if (i < count - 1) SizedBox(height: spacing),
        ],
      ],
    );
  }
}

/// A header-style skeleton — two lines with different widths.
class AppSkeletonHeader extends StatelessWidget {
  const AppSkeletonHeader({super.key});

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: ColorManager.grey200,
      highlightColor: ColorManager.grey100,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            height: AppSize.s20,
            width: 200,
            decoration: BoxDecoration(
              color: ColorManager.grey200,
              borderRadius: BorderRadius.circular(AppRadius.r4),
            ),
          ),
          const SizedBox(height: AppSize.s8),
          Container(
            height: AppSize.s14,
            width: 130,
            decoration: BoxDecoration(
              color: ColorManager.grey200,
              borderRadius: BorderRadius.circular(AppRadius.r4),
            ),
          ),
        ],
      ),
    );
  }
}
