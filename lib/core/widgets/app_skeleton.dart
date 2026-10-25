// Compatibility exports for the original shared loading API.
import 'package:flutter/material.dart';
import 'package:skeletonizer/skeletonizer.dart';
import 'content_skeleton.dart';
export 'content_skeleton.dart';

class AppSkeleton extends StatelessWidget {
  const AppSkeleton({
    required this.width,
    required this.height,
    this.borderRadius = 8,
    super.key,
  });
  final double width, height, borderRadius;
  @override
  Widget build(BuildContext context) => Skeletonizer.zone(
    effect: SolidColorEffect(
      color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.12),
    ),
    child: Bone(
      width: width,
      height: height,
      borderRadius: BorderRadius.circular(borderRadius),
    ),
  );
}

class AppSkeletonCard extends StatelessWidget {
  const AppSkeletonCard({this.height = 80, this.lines = 2, super.key});
  final double height;
  final int lines;
  @override
  Widget build(BuildContext context) => const ContentSkeleton(count: 1);
}

class AppSkeletonList extends StatelessWidget {
  const AppSkeletonList({this.count = 4, this.spacing = 12, super.key});
  final int count;
  final double spacing;
  @override
  Widget build(BuildContext context) => ContentSkeleton(count: count);
}

class AppSkeletonHeader extends StatelessWidget {
  const AppSkeletonHeader({super.key});
  @override
  Widget build(BuildContext context) =>
      const ContentSkeleton(shape: LoadingShape.rows, count: 1);
}
