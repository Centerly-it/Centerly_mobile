import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import '../../../../core/theme/style_manager.dart';
import '../../../../core/theme/values_manager.dart';
import 'group_design.dart';
import 'package:flutter_svg/flutter_svg.dart';

class GroupSubpageBar extends StatelessWidget implements PreferredSizeWidget {
  const GroupSubpageBar({required this.title, super.key});
  final String title;
  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
  @override
  Widget build(BuildContext context) => AppBar(
    backgroundColor: GroupDesign.background,
    centerTitle: false,
    titleSpacing: AppPadding.p12,
    title: Text(
      title.tr(),
      style: AppTextStyles.headlineSmall.copyWith(fontWeight: FontWeight.bold),
    ),
    leading: IconButton(
      tooltip: MaterialLocalizations.of(context).backButtonTooltip,
      onPressed: () => Navigator.of(context).pop(),
      icon: RotatedBox(
        quarterTurns: context.locale.languageCode == 'ar' ? 0 : 2,
        child: SvgPicture.asset('assets/figma/sessions/ea117.svg'),
      ),
    ),
  );
}
