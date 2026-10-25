import 'package:flutter/material.dart';
import 'package:skeletonizer/skeletonizer.dart';
import '../theme/values_manager.dart';
import 'content_skeleton.dart';

class SkeletonLayout extends StatelessWidget {
  const SkeletonLayout({required this.shape, required this.count, super.key});
  final LoadingShape shape;
  final int count;
  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.stretch,
    children: [
      if (shape == LoadingShape.profile || shape == LoadingShape.dashboard) ...[
        const ListTile(
          leading: Bone.circle(size: 56),
          title: Bone.text(words: 2),
          subtitle: Bone.text(words: 3),
        ),
        const SizedBox(height: AppSize.s16),
      ],
      if (shape == LoadingShape.calendar) ...[
        const Bone(height: 48),
        const SizedBox(height: AppSize.s16),
        const Bone(height: 180),
        const SizedBox(height: AppSize.s16),
      ],
      for (var i = 0; i < count; i++)
        Padding(
          padding: const EdgeInsets.only(bottom: AppPadding.p12),
          child: shape == LoadingShape.rows
              ? const ListTile(
                  leading: Bone.circle(size: 32),
                  title: Bone.text(words: 2),
                  subtitle: Bone.text(words: 2),
                  trailing: Bone.icon(),
                )
              : shape == LoadingShape.table
              ? const Padding(
                  padding: EdgeInsets.symmetric(vertical: AppPadding.p12),
                  child: Row(
                    children: [
                      Expanded(child: Bone.text(words: 2)),
                      SizedBox(width: AppSize.s12),
                      Bone(width: 64, height: 16),
                      SizedBox(width: AppSize.s12),
                      Bone(width: 40, height: 16),
                    ],
                  ),
                )
              : Card(
                  child: Padding(
                    padding: const EdgeInsets.all(AppPadding.p16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        const Row(
                          children: [
                            Bone.circle(size: 32),
                            SizedBox(width: AppSize.s12),
                            Expanded(child: Bone.text(words: 3)),
                            SizedBox(width: AppSize.s12),
                            Bone(width: 48, height: 20),
                          ],
                        ),
                        const SizedBox(height: AppSize.s16),
                        const Bone.text(words: 4),
                        if (shape != LoadingShape.dashboard) ...[
                          const SizedBox(height: AppSize.s12),
                          const Bone.text(words: 3),
                        ],
                        if (shape == LoadingShape.receipt) ...[
                          const SizedBox(height: AppSize.s12),
                          const Bone.text(words: 4),
                        ],
                      ],
                    ),
                  ),
                ),
        ),
    ],
  );
}
