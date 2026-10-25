import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../data/read_page.dart';
import '../presentation/paged_read_cubit.dart';
import '../presentation/paged_read_state.dart';
import '../theme/values_manager.dart';
import 'app_empty_state.dart';
import 'app_error_state.dart';
import 'data_update_footer.dart';

class PagedReadBody<T, S> extends StatelessWidget {
  const PagedReadBody({required this.item, this.header, this.items, super.key});
  final Widget Function(BuildContext, T) item;
  final Widget Function(BuildContext, List<T>)? items;
  final Widget Function(BuildContext, ReadPage<T, S>)? header;
  @override
  Widget build(BuildContext context) =>
      BlocBuilder<PagedReadCubit<T, S>, PagedReadState<T, S>>(
        builder: (context, state) {
          final cubit = context.read<PagedReadCubit<T, S>>();
          return RefreshIndicator(
            onRefresh: cubit.refresh,
            child: ListView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.all(AppPadding.p16),
              children: [
                if (state.page != null) ...[
                  if (header != null) header!(context, state.page!),
                ],
                if (items != null && state.rows.isNotEmpty)
                  items!(context, state.rows),
                for (final row in items == null ? state.rows : <T>[])
                  Padding(
                    padding: const EdgeInsets.only(bottom: AppPadding.p12),
                    child: item(context, row),
                  ),
                if (state.loading)
                  Center(
                    child: CircularProgressIndicator(
                      semanticsLabel: 'loading_data'.tr(),
                    ),
                  ),
                if (state.error)
                  AppErrorState(
                    onRetry: state.rows.isEmpty ? cubit.refresh : cubit.next,
                  ),
                if (!state.loading && !state.error && state.rows.isEmpty)
                  AppEmptyState(
                    title: 'completion_empty'.tr(),
                    subtitle: 'completion_empty_hint'.tr(),
                  ),
                if (state.cursor != null && !state.loading && !state.error)
                  TextButton(
                    onPressed: cubit.next,
                    child: Text('live_load_more'.tr()),
                  ),
                if (state.page != null)
                  DataUpdateFooter(updatedAt: state.page!.syncedAt),
              ],
            ),
          );
        },
      );
}
