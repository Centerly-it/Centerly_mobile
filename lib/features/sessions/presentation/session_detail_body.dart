part of 'session_detail_page.dart';

class _SessionDetailBody extends StatelessWidget {
  const _SessionDetailBody({required this.state, required this.sessionId});
  final SessionDetailState state;
  final String sessionId;
  @override
  Widget build(BuildContext context) {
    final cubit = context.read<SessionDetailCubit>();
    if (state.detail == null) {
      if (state.error) {
        return SingleChildScrollView(
          child: AppErrorState(onRetry: cubit.refresh),
        );
      }
      return const LoadingPage(shape: LoadingShape.profile);
    }
    return RefreshIndicator(
      onRefresh: cubit.refresh,
      child: ListView.builder(
        key: PageStorageKey<String>('session-detail-$sessionId'),
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(AppPadding.p16),
        itemCount: state.rows.length + 3,
        itemBuilder: (context, i) {
          if (i == 0) {
            return SessionDetailHeader(
              detail: state.detail!,
              onChanged: cubit.refresh,
            );
          }
          if (i == 1) {
            return SessionAttendanceList(
              state: state,
              onFilter: (status) => cubit.load(status: status),
              onMore: () => cubit.load(more: true),
            );
          }
          if (i < state.rows.length + 2) {
            return SessionAttendanceRow(
              key: ValueKey(state.rows[i - 2].id),
              row: state.rows[i - 2],
            );
          }
          return Column(
            children: [
              if (state.error)
                AppErrorState(
                  onRetry: state.retryMore
                      ? () => cubit.load(more: true)
                      : cubit.refresh,
                ),
              if (state.nextCursor != null && !state.loading && !state.error)
                TextButton(
                  onPressed: () => cubit.load(more: true),
                  child: Text('detail_more'.tr()),
                ),
              DataUpdateFooter(updatedAt: state.detail!.syncedAt),
            ],
          );
        },
      ),
    );
  }
}
