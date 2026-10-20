import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../core/theme/color_manager.dart';
import '../../../core/theme/values_manager.dart';
import 'workspace_actions.dart';

class WorkspaceAppBar extends StatelessWidget implements PreferredSizeWidget {
  const WorkspaceAppBar({super.key, required this.isHome});
  final bool isHome;

  @override
  Size get preferredSize =>
      Size.fromHeight(isHome ? AppSize.s80 : kToolbarHeight);

  @override
  Widget build(BuildContext context) => AppBar(
    automaticallyImplyLeading: false,
    toolbarHeight: preferredSize.height,
    titleSpacing: AppPadding.p16,
    centerTitle: false,
    title: Row(
      children: [
        if (isHome) ...[
          const CircleAvatar(
            radius: AppSize.s24,
            backgroundColor: ColorManager.primaryBright,
            foregroundColor: ColorManager.primaryDark,
            child: Icon(Icons.person_rounded, size: AppSize.s32),
          ),
          const SizedBox(width: AppSize.s12),
        ],
        Expanded(
          child: Text(
            'workspace_title'.tr(),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    ),
    backgroundColor: ColorManager.primary,
    foregroundColor: ColorManager.white,
    titleTextStyle: Theme.of(
      context,
    ).textTheme.titleLarge?.copyWith(color: ColorManager.white),
    iconTheme: const IconThemeData(color: ColorManager.white),
    actionsIconTheme: const IconThemeData(color: ColorManager.white),
    systemOverlayStyle: SystemUiOverlayStyle.light,
    actions: const [WorkspaceActions()],
  );
}
