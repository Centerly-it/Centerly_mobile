import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../../../../core/widgets/app_surface_panel.dart';
import '../../../../core/theme/color_manager.dart';
import '../../../../core/theme/style_manager.dart';
import '../../../../core/theme/values_manager.dart';

class GroupDesign {
  static const background = ColorManager.canvas;
  static const stroke = ColorManager.stroke;
}

class GroupAsset extends StatelessWidget {
  const GroupAsset(this.file, {super.key});
  final String file;
  @override
  Widget build(BuildContext context) =>
      SvgPicture.asset('assets/figma/groups/$file');
}

class GroupPanel extends AppSurfacePanel {
  const GroupPanel({required super.child, super.padding = 12, super.key});
}

class GroupIconLabel extends StatelessWidget {
  const GroupIconLabel({required this.asset, required this.label, super.key});
  final String asset, label;
  @override
  Widget build(BuildContext context) => Row(
    mainAxisSize: MainAxisSize.min,
    children: [
      GroupAsset(asset),
      const SizedBox(width: AppSize.s8),
      Flexible(
        child: Text(
          label,
          style: AppTextStyles.bodyMedium.copyWith(height: 24 / 14),
        ),
      ),
    ],
  );
}
