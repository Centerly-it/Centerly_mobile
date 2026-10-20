import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import '../../../../core/theme/color_manager.dart';
import '../../../../core/theme/style_manager.dart';
import '../../../../core/theme/values_manager.dart';
import 'session_design.dart';

class SessionCancelReason extends StatelessWidget {
  const SessionCancelReason({
    required this.index,
    required this.selected,
    required this.onTap,
    this.child,
    super.key,
  });
  final int index;
  final bool selected;
  final VoidCallback onTap;
  final Widget? child;
  static const keys = [
    'design_low_students',
    'design_technical_issue',
    'design_other_reason',
  ];
  static const _icons = ['1e49f.svg', '967bf.svg', 'df6bc.svg'];
  @override
  Widget build(BuildContext context) => Semantics(
    selected: selected,
    button: true,
    child: SessionPanel(
      padding: AppPadding.p8,
      child: Column(
        children: [
          InkWell(
            onTap: onTap,
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: AppPadding.p4),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: AppSize.s16,
                    backgroundColor: index == 0
                        ? ColorManager.warningLight
                        : index == 1
                        ? ColorManager.errorLight
                        : ColorManager.primaryBright,
                    child: SessionAsset(_icons[index]),
                  ),
                  const SizedBox(width: AppSize.s8),
                  Expanded(
                    child: Text(
                      keys[index].tr(),
                      style: AppTextStyles.titleSmall,
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(AppPadding.p4),
                    child: SessionAsset(selected ? '76d75.svg' : '3af43.svg'),
                  ),
                ],
              ),
            ),
          ),
          ?child,
        ],
      ),
    ),
  );
}
