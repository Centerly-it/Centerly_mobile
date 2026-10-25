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

class TeacherGroupFilter extends StatefulWidget {
  const TeacherGroupFilter({required this.onChanged, super.key});
  final ValueChanged<String?> onChanged;
  @override
  State<TeacherGroupFilter> createState() => _TeacherGroupFilterState();
}

class _TeacherGroupFilterState extends State<TeacherGroupFilter> {
  String? label;
  @override
  Widget build(BuildContext context) => TextButton.icon(
    icon: const Icon(Icons.filter_list),
    label: Text(label ?? 'completion_all_groups'.tr()),
    onPressed: () async {
      final result = await showDialog<({GroupRecord? group})>(
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
                        onPressed: () => Navigator.pop(context, (group: null)),
                        child: Text('completion_all_groups'.tr()),
                      ),
                      Flexible(
                        child: ListView(
                          shrinkWrap: true,
                          children: [
                            for (final g in state.groups)
                              ListTile(
                                title: Text(g.name),
                                subtitle: Text(g.subject),
                                onTap: () => Navigator.pop(context, (group: g)),
                              ),
                            if (state.error != null)
                              AppErrorState(onRetry: cubit.refresh),
                            if (state.loading)
                              const Center(child: CircularProgressIndicator()),
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
      if (result != null && mounted) {
        setState(() => label = result.group?.name);
        widget.onChanged(result.group?.id);
      }
    },
  );
}
