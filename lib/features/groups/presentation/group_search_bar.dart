import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/widgets/server_search_field.dart';
import 'group_browse_cubit.dart';

class GroupSearchBar extends StatelessWidget {
  const GroupSearchBar({super.key});
  @override
  Widget build(BuildContext context) => ServerSearchField(
    label: 'groups_search_hint'.tr(),
    onSubmitted: (value) {
      final cubit = context.read<GroupBrowseCubit>();
      cubit.search(value, gradeId: cubit.state.gradeId);
    },
  );
}
