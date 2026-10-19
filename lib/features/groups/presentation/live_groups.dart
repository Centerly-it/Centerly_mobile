import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/di/di.dart';
import '../../../core/theme/values_manager.dart';
import '../../../core/widgets/app_empty_state.dart';
import '../../../core/widgets/app_error_state.dart';
import '../data/group_repository.dart';
import 'group_browse_cubit.dart';
import 'group_browse_state.dart';
import 'group_search_bar.dart';
import 'live_group_card.dart';

class LiveGroups extends StatelessWidget {
  const LiveGroups({super.key});
  @override
  Widget build(BuildContext context) => BlocProvider(
    create: (_) => GroupBrowseCubit(getIt<GroupRepository>())..search(''),
    child: const _GroupsBody(),
  );
}

class _GroupsBody extends StatelessWidget {
  const _GroupsBody();
  @override
  Widget build(BuildContext context) =>
      BlocBuilder<GroupBrowseCubit, GroupBrowseState>(
        builder: (context, state) {
          final cubit = context.read<GroupBrowseCubit>();
          return Column(
            children: [
              const GroupSearchBar(),
              if (state.gradeId != null)
                TextButton.icon(
                  onPressed: () => cubit.search(state.search),
                  icon: const Icon(Icons.filter_alt_off_outlined),
                  label: Text('live_clear_grade'.tr()),
                ),
              Expanded(
                child: state.loading && state.groups.isEmpty
                    ? Center(
                        child: CircularProgressIndicator(
                          semanticsLabel: 'loading_data'.tr(),
                        ),
                      )
                    : RefreshIndicator(
                        onRefresh: cubit.refresh,
                        child: ListView(
                          physics: const AlwaysScrollableScrollPhysics(),
                          padding: const EdgeInsets.all(AppPadding.p16),
                          children: [
                            for (final group in state.groups)
                              LiveGroupCard(
                                group: group,
                                onGrade: () => cubit.search(
                                  state.search,
                                  gradeId: group.gradeId,
                                ),
                              ),
                            if (state.error != null)
                              AppErrorState(
                                onRetry: state.groups.isEmpty
                                    ? cubit.refresh
                                    : cubit.next,
                              ),
                            if (state.groups.isEmpty && state.error == null)
                              AppEmptyState(
                                title: 'groups_empty_title'.tr(),
                                subtitle: 'groups_empty_subtitle'.tr(),
                              ),
                            if (state.cursor != null && state.error == null)
                              TextButton(
                                onPressed: state.loading ? null : cubit.next,
                                child: Text(
                                  (state.loading
                                          ? 'loading_data'
                                          : 'live_load_more')
                                      .tr(),
                                ),
                              ),
                          ],
                        ),
                      ),
              ),
            ],
          );
        },
      );
}
