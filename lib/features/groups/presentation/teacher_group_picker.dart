import '../../../core/widgets/content_skeleton.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/di/di.dart';
import '../../../core/widgets/app_error_state.dart';
import '../../../core/widgets/server_search_field.dart';
import '../data/group_repository.dart';
import '../domain/group_record.dart';
import 'group_browse_cubit.dart';
import 'group_browse_state.dart';

Future<({GroupRecord? group, bool archived})?> showTeacherGroupPicker(
  BuildContext context, {
  required bool allowArchived,
  required bool archived,
}) => showDialog<({GroupRecord? group, bool archived})>(
  context: context,
  builder: (_) => BlocProvider(
    create: (_) => GroupBrowseCubit(getIt<GroupRepository>())..search(''),
    child: Dialog(
      child: SafeArea(
        child: BlocBuilder<GroupBrowseCubit, GroupBrowseState>(
          builder: (context, state) {
            final cubit = context.read<GroupBrowseCubit>();
            return Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                ServerSearchField(
                  label: 'groups_search_hint'.tr(),
                  showLabel: false,
                  onSubmitted: cubit.search,
                ),
                TextButton(
                  onPressed: () =>
                      Navigator.pop(context, (group: null, archived: false)),
                  child: Text('completion_all_groups'.tr()),
                ),
                if (allowArchived)
                  ListTile(
                    leading: const Icon(Icons.archive_outlined),
                    title: Text('completion_archived_students'.tr()),
                    selected: archived,
                    onTap: () =>
                        Navigator.pop(context, (group: null, archived: true)),
                  ),
                Flexible(
                  child: ListView(
                    shrinkWrap: true,
                    children: [
                      for (final g in state.groups)
                        ListTile(
                          title: Text(g.name),
                          subtitle: Text(g.subject),
                          onTap: () => Navigator.pop(context, (
                            group: g,
                            archived: false,
                          )),
                        ),
                      if (state.error != null)
                        AppErrorState(onRetry: cubit.refresh),
                      if (state.loading)
                        const ContentSkeleton(
                          shape: LoadingShape.rows,
                          count: 2,
                        ),
                      if (state.cursor != null && !state.loading)
                        TextButton(
                          onPressed: cubit.next,
                          child: Text('live_load_more'.tr()),
                        ),
                    ],
                  ),
                ),
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text('cancel_back'.tr()),
                ),
              ],
            );
          },
        ),
      ),
    ),
  ),
);
