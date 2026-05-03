import 'package:centrally/core/res/icons_manager.dart';
import 'package:centrally/core/res/routes_manager.dart';
import 'package:centrally/core/res/values_manager.dart';
import 'package:centrally/features/auth/presentation/widgets/info_notice_card.dart';
import 'package:centrally/features/auth/presentation/widgets/main_title.dart';
import 'package:centrally/features/auth/presentation/widgets/primary_button.dart';
import 'package:centrally/features/auth/presentation/widgets/step_indicator.dart';
import 'package:centrally/features/auth/presentation/widgets/sub_title.dart';
import 'package:centrally/features/auth/presentation/widgets/titled_text_field.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:centrally/core/res/strings_manager.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class CreateCenterViewBody extends StatefulWidget {
  const CreateCenterViewBody({super.key});

  @override
  State<CreateCenterViewBody> createState() => _CreateCenterViewBodyState();
}

class _CreateCenterViewBodyState extends State<CreateCenterViewBody> {
  final nameController = TextEditingController();

  final addressController = TextEditingController();

  final phoneController = TextEditingController();
  final formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    nameController.dispose();
    addressController.dispose();
    phoneController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Form(
        key: formKey,
        child: Padding(
          padding: const EdgeInsets.all(AppPadding.p16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Center(
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: AppPadding.p72),
                  child: StepIndicator(currentStep: 1),
                ),
              ),

              MainTitle(title: StringsManager.createCenterTitle.tr()),
              SubTitle(title: StringsManager.createCenterSubtitle.tr()),
              const SizedBox(height: 24),
              TitledTextField(
                controller: nameController,
                title: StringsManager.centerNameLabel.tr(),
                hint: StringsManager.centerNameHint.tr(),
                icon: IconsManager.userIcon,
                keyboardType: TextInputType.name,
              ),
              TitledTextField(
                controller: addressController,
                title: StringsManager.centerAddressLabel.tr(),
                hint: StringsManager.centerAddressHint.tr(),
                icon: IconsManager.locationIcon,
                keyboardType: TextInputType.streetAddress,
              ),
              TitledTextField(
                controller: phoneController,
                title: StringsManager.centerPhoneLabel.tr(),
                hint: StringsManager.centerPhoneHint.tr(),
                icon: IconsManager.callIcon,
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 8),
              const InfoNoticeCard(),
              const SizedBox(height: 86),
              PrimaryButton(
                onPressed: () {
                  if (formKey.currentState!.validate()) {
                    context.pushNamed(RoutesManager.createAdminName);
                  }
                },
                buttonLabel: StringsManager.nextButton.tr(),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
