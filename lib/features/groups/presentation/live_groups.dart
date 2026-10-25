import '../../../core/widgets/read_directory_list.dart';
import '../../../core/widgets/content_skeleton.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/di/di.dart';
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
                child: ReadDirectoryList(
                  count: state.groups.length,
                  loading: state.loading,
                  error: state.error != null,
                  hasMore: state.cursor != null,
                  retryMore: state.retryMore,
                  refresh: cubit.refresh,
                  next: cubit.next,
                  shape: LoadingShape.cards,
                  emptyTitle: 'groups_empty_title',
                  emptyHint: 'groups_empty_subtitle',
                  item: (context, index) {
                    final group = state.groups[index];
                    return LiveGroupCard(
                      key: ValueKey(group.id),
                      group: group,
                      onGrade: () =>
                          cubit.search(state.search, gradeId: group.gradeId),
                    );
                  },
                ),
              ),
            ],
          );
        },
      );
}
