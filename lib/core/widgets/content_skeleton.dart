import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:skeletonizer/skeletonizer.dart';
import 'skeleton_layout.dart';

enum LoadingShape { cards, rows, profile, dashboard, calendar, receipt, table }

/// Presentation-only geometry; no placeholder data enters business models.
class ContentSkeleton extends StatefulWidget {
  const ContentSkeleton({
    this.shape = LoadingShape.cards,
    this.count = 3,
    super.key,
  });
  final LoadingShape shape;
  final int count;
  @override
  State<ContentSkeleton> createState() => _ContentSkeletonState();
}

class _ContentSkeletonState extends State<ContentSkeleton>
    with WidgetsBindingObserver {
  bool _active =
      WidgetsBinding.instance.lifecycleState == null ||
      WidgetsBinding.instance.lifecycleState == AppLifecycleState.resumed;
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (mounted) setState(() => _active = state == AppLifecycleState.resumed);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final animate =
        _active &&
        TickerMode.valuesOf(context).enabled &&
        !MediaQuery.disableAnimationsOf(context) &&
        !MediaQuery.accessibleNavigationOf(context) &&
        (ModalRoute.of(context)?.isCurrent ?? true);
    return Semantics(
      label: 'loading_data'.tr(),
      liveRegion: true,
      child: ExcludeSemantics(
        child: IgnorePointer(
          child: Skeletonizer.zone(
            effect: animate
                ? ShimmerEffect(
                    baseColor: colors.onSurface.withValues(alpha: 0.12),
                    highlightColor: colors.onSurface.withValues(alpha: 0.04),
                    duration: const Duration(milliseconds: 1600),
                  )
                : SolidColorEffect(
                    color: colors.onSurface.withValues(alpha: 0.12),
                  ),
            enableSwitchAnimation: false,
            child: SkeletonLayout(shape: widget.shape, count: widget.count),
          ),
        ),
      ),
    );
  }
}

class LoadingPage extends StatelessWidget {
  const LoadingPage({this.shape = LoadingShape.cards, super.key});
  final LoadingShape shape;
  @override
  Widget build(BuildContext context) => SingleChildScrollView(
    padding: const EdgeInsets.all(16),
    child: ContentSkeleton(shape: shape),
  );
}
