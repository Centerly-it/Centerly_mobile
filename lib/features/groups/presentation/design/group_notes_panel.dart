import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import '../../../../core/theme/color_manager.dart';
import '../../../../core/theme/style_manager.dart';
import '../../../../core/theme/values_manager.dart';
import '../../preview/group_preview_data.dart';
import 'group_design.dart';
import 'group_section.dart';

class GroupNotesPanel extends StatelessWidget {
  const GroupNotesPanel({
    required this.notes,
    required this.onAdd,
    this.onViewAll,
    super.key,
  });
  final List<GroupPreviewNote> notes;
  final VoidCallback onAdd;
  final VoidCallback? onViewAll;
  @override
  Widget build(BuildContext context) => GroupSection(
    title: 'group_design_notes',
    asset: 'e90e0.svg',
    onViewAll: notes.isEmpty ? null : onViewAll,
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (notes.isEmpty)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 0),
            child: Text(
              'group_design_no_notes'.tr(),
              textAlign: TextAlign.start,
              style: AppTextStyles.bodyLarge.copyWith(
                color: ColorManager.grey500,
              ),
            ),
          ),
        if (notes.isNotEmpty) GroupNoteTile(note: notes.first),
        const SizedBox(height: AppSize.s12),
        OutlinedButton(
          onPressed: onAdd,
          style: OutlinedButton.styleFrom(
            minimumSize: const Size.fromHeight(44),
            side: const BorderSide(color: ColorManager.primary),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppRadius.r12),
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const GroupAsset('444b3.svg'),
              const SizedBox(width: AppSize.s8),
              Flexible(
                child: Text(
                  'group_design_add_note'.tr(),
                  textAlign: TextAlign.center,
                ),
              ),
            ],
          ),
        ),
      ],
    ),
  );
}

class GroupNoteTile extends StatelessWidget {
  const GroupNoteTile({required this.note, super.key});
  final GroupPreviewNote note;
  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(AppPadding.p12),
    decoration: BoxDecoration(
      color: ColorManager.grey200,
      borderRadius: BorderRadius.circular(AppRadius.r8),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          DateFormat.yMMMMd(context.locale.toString()).format(note.createdAt),
          style: AppTextStyles.caption.copyWith(
            color: ColorManager.primaryDark,
          ),
        ),
        const SizedBox(height: AppSize.s12),
        Text(
          note.text,
          style: AppTextStyles.bodyMedium.copyWith(height: 24 / 14),
        ),
      ],
    ),
  );
}
