import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import '../../../core/theme/color_manager.dart';
import '../../../core/theme/style_manager.dart';
import '../../../core/theme/values_manager.dart';
import '../presentation/design/group_design.dart';
import '../presentation/design/group_subpage_bar.dart';

class GroupNoteEditor extends StatefulWidget {
  const GroupNoteEditor({super.key});
  @override
  State<GroupNoteEditor> createState() => _GroupNoteEditorState();
}

class _GroupNoteEditorState extends State<GroupNoteEditor> {
  final _text = TextEditingController();
  final _form = GlobalKey<FormState>();
  @override
  void dispose() {
    _text.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    backgroundColor: GroupDesign.background,
    appBar: const GroupSubpageBar(title: 'group_design_add_note'),
    body: SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(AppPadding.p16),
        child: Form(
          key: _form,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                'group_design_note_label'.tr(),
                style: AppTextStyles.bodySemiBold,
              ),
              const SizedBox(height: AppSize.s16),
              TextFormField(
                controller: _text,
                minLines: 4,
                maxLines: 8,
                maxLength: 2000,
                validator: (v) => v == null || v.trim().isEmpty
                    ? 'group_design_note_required'.tr()
                    : null,
                decoration: InputDecoration(
                  hintText: 'group_design_note_hint'.tr(),
                  filled: true,
                  fillColor: ColorManager.grey200,
                  counterText: '',
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(AppRadius.r8),
                    borderSide: const BorderSide(color: GroupDesign.stroke),
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(AppRadius.r8),
                    borderSide: const BorderSide(color: GroupDesign.stroke),
                  ),
                ),
              ),
              const SizedBox(height: 140),
              FilledButton(
                style: FilledButton.styleFrom(
                  minimumSize: const Size.fromHeight(54),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(AppRadius.r12),
                  ),
                ),
                onPressed: () {
                  if (_form.currentState!.validate()) {
                    Navigator.of(context).pop(_text.text.trim());
                  }
                },
                child: Text(
                  'group_design_save_note'.tr(),
                  style: AppTextStyles.headlineSmall.copyWith(
                    color: ColorManager.white,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    ),
  );
}
