import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../theme/color_manager.dart';
import '../theme/values_manager.dart';

/// Shared branded header; account-specific content is supplied by the caller.
class AppHeader extends StatelessWidget implements PreferredSizeWidget {
  const AppHeader({required this.title, this.avatar, this.actions, super.key});
  final String title;
  final Widget? avatar;
  final List<Widget>? actions;

  static const height = AppSize.s80;
  @override
  Size get preferredSize => const Size.fromHeight(height);

  @override
  Widget build(BuildContext context) => AppBar(
    automaticallyImplyLeading: false,
    toolbarHeight: height,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(
        bottom: Radius.circular(AppRadius.r16),
      ),
    ),
    titleSpacing: AppPadding.p16,
    centerTitle: false,
    title: Row(
      children: [
        if (avatar != null) ...[avatar!, const SizedBox(width: AppSize.s12)],
        Expanded(
          child: Text(title, maxLines: 1, overflow: TextOverflow.ellipsis),
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
    actions: actions,
  );
}
