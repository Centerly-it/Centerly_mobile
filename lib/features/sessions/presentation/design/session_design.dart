import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../../../../core/theme/color_manager.dart';
import '../../../../core/theme/values_manager.dart';

/// Tokens and original exported assets for the approved Figma sessions section.
class SessionDesign {
  SessionDesign._();
  static const background = Color(0xFFFBFCFC);
  static const stroke = Color(0xFFE3E6EB);
  static const text = Color(0xFF1F1F1F);
  static const muted = Color(0xFF6D6F74);
  static const green = Color(0xFF0E874E);
  static const greenBg = Color(0xFFE7F3ED);
  static const red = Color(0xFFDF3035);
  static const assets = 'assets/figma/sessions/';
}

class SessionAsset extends StatelessWidget {
  const SessionAsset(this.file, {super.key});
  final String file;
  @override
  Widget build(BuildContext context) =>
      SvgPicture.asset('${SessionDesign.assets}$file');
}

class SessionPanel extends StatelessWidget {
  const SessionPanel({
    required this.child,
    this.padding = AppPadding.p12,
    this.selected = false,
    this.minHeight = 0,
    super.key,
  });
  final Widget child;
  final double padding;
  final bool selected;
  final double minHeight;
  @override
  Widget build(BuildContext context) => Container(
    constraints: BoxConstraints(minHeight: minHeight),
    decoration: BoxDecoration(
      color: ColorManager.white,
      borderRadius: BorderRadius.circular(AppRadius.r12),
      border: Border.all(
        color: selected ? ColorManager.primary : SessionDesign.stroke,
      ),
    ),
    clipBehavior: Clip.antiAlias,
    child: Material(
      type: MaterialType.transparency,
      child: Padding(padding: EdgeInsets.all(padding), child: child),
    ),
  );
}
