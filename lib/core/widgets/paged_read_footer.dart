import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import '../presentation/paged_read_state.dart';
import 'app_empty_state.dart';
import 'app_error_state.dart';
import 'data_update_footer.dart';

class PagedReadFooter<T, S> extends StatelessWidget {
  const PagedReadFooter({
    required this.state,
    required this.refresh,
    required this.next,
    super.key,
  });
  final PagedReadState<T, S> state;
  final VoidCallback refresh, next;
  @override
  Widget build(BuildContext context) => Column(
    children: [
      if (state.loadingMore)
        Padding(
          padding: const EdgeInsets.all(12),
          child: CircularProgressIndicator(semanticsLabel: 'loading_data'.tr()),
        ),
      if (state.error) AppErrorState(onRetry: state.retryMore ? next : refresh),
      if (!state.loading && !state.error && state.rows.isEmpty)
        AppEmptyState(
          title: 'completion_empty'.tr(),
          subtitle: 'completion_empty_hint'.tr(),
        ),
      if (state.cursor != null && !state.loading && !state.error)
        TextButton(onPressed: next, child: Text('live_load_more'.tr())),
      if (state.page != null) DataUpdateFooter(updatedAt: state.page!.syncedAt),
    ],
  );
}
