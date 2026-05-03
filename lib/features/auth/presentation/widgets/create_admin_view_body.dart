import 'package:centrally/core/res/color_manager.dart';
import 'package:centrally/core/res/icons_manager.dart';
import 'package:centrally/core/res/style_manager.dart';
import 'package:centrally/core/res/values_manager.dart';
import 'package:centrally/features/auth/presentation/widgets/info_notice_card.dart';
import 'package:centrally/features/auth/presentation/widgets/main_title.dart';
import 'package:centrally/features/auth/presentation/widgets/password_titled_text_field.dart';
import 'package:centrally/features/auth/presentation/widgets/primary_button.dart';
import 'package:centrally/features/auth/presentation/widgets/step_indicator.dart';
import 'package:centrally/features/auth/presentation/widgets/sub_title.dart';
import 'package:centrally/features/auth/presentation/widgets/titled_text_field.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:centrally/core/res/strings_manager.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:centrally/core/res/routes_manager.dart';

class CreateAdminViewBody extends StatefulWidget {
  const CreateAdminViewBody({super.key});

  @override
  State<CreateAdminViewBody> createState() => _CreateAdminViewBodyState();
}

class _CreateAdminViewBodyState extends State<CreateAdminViewBody> {
  final adminNameController = TextEditingController();

  final adminEmailController = TextEditingController();

  final passwordController = TextEditingController();

  final confirmPasswordController = TextEditingController();
  final formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    adminNameController.dispose();
    adminEmailController.dispose();
    passwordController.dispose();
    confirmPasswordController.dispose();
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
              //StepIndicator
              const Center(
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 64),
                  child: StepIndicator(currentStep: 2),
                ),
              ),
              //Main Title
              MainTitle(title: StringsManager.createAdminTitle.tr()),
              //Sub Title
              SubTitle(title: StringsManager.createAdminSubtitle.tr()),
              const SizedBox(height: 24),
              //Admin Name Text Field
              TitledTextField(
                controller: adminNameController,
                title: StringsManager.adminNameLabel.tr(),
                hint: StringsManager.adminNameHint.tr(),
                icon: IconsManager.userIcon,
                keyboardType: TextInputType.name,
              ),
              //Admin Email Text Field
              TitledTextField(
                controller: adminEmailController,
                title: StringsManager.adminEmailLabel.tr(),
                hint: StringsManager.adminEmailHint.tr(),
                icon: IconsManager.mailIcon,
                keyboardType: TextInputType.emailAddress,
              ),
              //Password Text Field
              PasswordTitledTextField(
                controller: passwordController,
                title: StringsManager.adminPasswordLabel.tr(),
                hint: StringsManager.adminPasswordHint.tr(),
                icon: IconsManager.lockIcon,
                isPassword: true,
                showValidationChecks: true,
              ),
              const SizedBox(height: 16),
              //Confirm Password Text Field
              PasswordTitledTextField(
                controller: confirmPasswordController,
                title: StringsManager.adminConfirmPasswordLabel.tr(),
                hint: StringsManager.adminPasswordHint.tr(),
                icon: IconsManager.lockIcon,
                isConfirmPassword: true,
                matchController: passwordController,
              ),
              const SizedBox(height: 8),
              //Blue Notice Card
              const InfoNoticeCard(),
              const SizedBox(height: 32),
              //Navigation Button
              PrimaryButton(
                onPressed: () {
                  if (formKey.currentState!.validate()) {
                    context.goNamed(RoutesManager.registerSuccessName);
                  }
                },
                buttonLabel: StringsManager.createAccountButton.tr(),
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    StringsManager.haveAccount.tr(),
                    style: AppTextStyles.bodySemiBold,
                  ),
                  GestureDetector(
                    onTap: () {
                      context.pushNamed(RoutesManager.loginName);
                    },
                    child: Text(
                      StringsManager.loginAction.tr(),
                      style: AppTextStyles.bodySemiBold.copyWith(
                        color: ColorManager.primary,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Center(
                child: Text.rich(
                  textAlign: TextAlign.center,
                  TextSpan(
                    text: StringsManager.termsAgreement.tr(),
                    style: AppTextStyles.labelSmall,
                    children: [
                      TextSpan(
                        text: StringsManager.privacyPolicy.tr(),
                        style: AppTextStyles.labelSmall.copyWith(
                          color: ColorManager.primary,
                          decoration: TextDecoration.underline,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }
}
