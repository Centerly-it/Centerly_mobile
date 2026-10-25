import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import '../theme/values_manager.dart';
import 'app_empty_state.dart';
import 'app_error_state.dart';
import 'content_skeleton.dart';

class ReadDirectoryList extends StatelessWidget {
  const ReadDirectoryList({
    required this.count,
    required this.item,
    required this.loading,
    required this.error,
    required this.hasMore,
    this.retryMore = false,
    required this.refresh,
    required this.next,
    required this.emptyTitle,
    required this.emptyHint,
    this.shape = LoadingShape.rows,
    super.key,
  });
  final int count;
  final IndexedWidgetBuilder item;
  final bool loading, error, hasMore, retryMore;
  final Future<void> Function() refresh;
  final VoidCallback next;
  final String emptyTitle, emptyHint;
  final LoadingShape shape;
  @override
  Widget build(BuildContext context) => RefreshIndicator(
    onRefresh: refresh,
    child: ListView.builder(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.all(AppPadding.p16),
      itemCount: count + 1,
      itemBuilder: (context, i) {
        if (i < count) return item(context, i);
        return Column(
          children: [
            if (loading && count == 0) ContentSkeleton(shape: shape),
            if (loading && count != 0) const LinearProgressIndicator(),
            if (error) AppErrorState(onRetry: retryMore ? next : refresh),
            if (!loading && !error && count == 0)
              AppEmptyState(title: emptyTitle.tr(), subtitle: emptyHint.tr()),
            if (hasMore && !error && !loading)
              TextButton(onPressed: next, child: Text('live_load_more'.tr())),
          ],
        );
      },
    ),
  );
}
