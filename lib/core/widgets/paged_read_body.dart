import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../data/read_page.dart';
import '../presentation/paged_read_cubit.dart';
import '../presentation/paged_read_state.dart';
import '../theme/values_manager.dart';
import 'content_skeleton.dart';
import 'paged_read_footer.dart';

class PagedReadBody<T, S> extends StatelessWidget {
  const PagedReadBody({
    required this.item,
    this.header,
    this.items,
    this.leading,
    this.loadingShape = LoadingShape.cards,
    super.key,
  });
  final Widget? leading;
  final LoadingShape loadingShape;
  final Widget Function(BuildContext, T) item;
  final Widget Function(BuildContext, List<T>)? items;
  final Widget Function(BuildContext, ReadPage<T, S>)? header;
  @override
  Widget build(BuildContext context) =>
      BlocBuilder<PagedReadCubit<T, S>, PagedReadState<T, S>>(
        builder: (context, state) {
          final cubit = context.read<PagedReadCubit<T, S>>();
          final count = items == null
              ? state.rows.length
              : (state.rows.isEmpty ? 0 : 1);
          return RefreshIndicator(
            onRefresh: cubit.refresh,
            child: ListView.builder(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.all(AppPadding.p16),
              itemCount: count + 2,
              itemBuilder: (context, index) {
                if (index == 0) {
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      ?leading,
                      if (state.refreshing)
                        const LinearProgressIndicator(minHeight: 2),
                      if (state.initialLoading)
                        ContentSkeleton(shape: loadingShape),
                      if (state.page != null && header != null)
                        header!(context, state.page!),
                    ],
                  );
                }
                if (index == count + 1) {
                  return PagedReadFooter(
                    state: state,
                    refresh: cubit.refresh,
                    next: cubit.next,
                  );
                }
                if (items != null) return items!(context, state.rows);
                final row = state.rows[index - 1];
                return Padding(
                  key: ValueKey(cubit.identity(row)),
                  padding: const EdgeInsets.only(bottom: AppPadding.p12),
                  child: item(context, row),
                );
              },
            ),
          );
        },
      );
}
