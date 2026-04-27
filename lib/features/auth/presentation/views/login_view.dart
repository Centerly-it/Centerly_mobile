import 'package:centrally/core/res/assets_manager.dart';
import 'package:centrally/core/res/color_manager.dart';
import 'package:centrally/core/res/style_manager.dart';
import 'package:centrally/core/utils/validator.dart';
import 'package:centrally/core/widgets/custom_text_feild.dart';
import 'package:centrally/features/auth/presentation/widgets/auth_rich_text.dart';
import 'package:centrally/features/auth/presentation/widgets/forgot_password_remember_me.dart';
import 'package:centrally/features/auth/presentation/widgets/primary_button.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:flutter_svg/flutter_svg.dart';

class LoginView extends StatefulWidget {
  const LoginView({super.key});

  @override
  State<LoginView> createState() => _LoginViewState();
}

class _LoginViewState extends State<LoginView> {
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool obscure = true;
  bool loading = false;

  @override
  void initState() {
    super.initState();

    FlutterNativeSplash.remove();
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidht = MediaQuery.of(context).size.width;

    return Scaffold(
      backgroundColor: ColorManager.whiteColor,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.symmetric(horizontal: screenWidht * 0.045),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Image.asset(
                  AssetsManager.centerlyLogo,
                  height: screenHeight * 0.35,
                  width: screenWidht * 0.5,
                  fit: BoxFit.contain,
                ),

                Text(
                  tr('welcome_back'),
                  style: StyleManager.head3Bold(context),
                ),
                const SizedBox(height: 12),
                Text(
                  tr('login_subtitle'),
                  style: StyleManager.bodyRegular(context),
                ),
                SizedBox(height: screenHeight * 0.03),
                Text(
                  tr('identifier_label'),
                  style: StyleManager.bodyMeduim(context),
                ),
                SizedBox(height: screenHeight * 0.01),
                CustomTextField(
                  controller: emailController,
                  validator: (value) {
                    final result = AuthValidator.validateIdentifier(
                      value ?? '',
                    );
                    return result != null ? tr(result) : null;
                  },
                  autovalidateMode: AutovalidateMode.onUserInteraction,
                  radius: 8,
                  hintStyle: StyleManager.bodyRegular(
                    context,
                  ).copyWith(color: ColorManager.greyHintColor),
                  hintText: tr('identifier_hint'),
                  prefixIcon: Padding(
                    padding: EdgeInsets.all(screenWidht * 0.04),
                    child: SizedBox(
                      width: 24,
                      height: 24,
                      child: SvgPicture.asset(
                        AssetsManager.emailIcon,
                        fit: BoxFit.contain,
                      ),
                    ),
                  ),
                ),

                SizedBox(height: screenHeight * 0.013),
                Text(tr('password'), style: StyleManager.bodyMeduim(context)),
                SizedBox(height: screenHeight * 0.01),
                CustomTextField(
                  obscureText: obscure,
                  controller: passwordController,
                  validator: (value) {
                    final result = AuthValidator.validatePassword(value ?? '');
                    return result != null ? tr(result) : null;
                  },
                  autovalidateMode: AutovalidateMode.onUserInteraction,
                  radius: 8,
                  hintStyle: StyleManager.bodyRegular(
                    context,
                  ).copyWith(color: ColorManager.greyHintColor),
                  hintText: tr('password_hint'),
                  suffixIcon: IconButton(
                    onPressed: () {
                      setState(() {
                        obscure = !obscure;
                      });
                    },
                    icon: Icon(
                      obscure
                          ? Icons.visibility_off_outlined
                          : Icons.visibility_outlined,
                      color: ColorManager.visibilityColor,
                      size: 30,
                    ),
                  ),
                  prefixIcon: Padding(
                    padding: EdgeInsets.all(screenWidht * 0.04),
                    child: SizedBox(
                      width: 24,
                      height: 24,
                      child: SvgPicture.asset(
                        AssetsManager.lockIcon,
                        fit: BoxFit.contain,
                      ),
                    ),
                  ),
                ),
                SizedBox(height: screenHeight * 0.013),
                ForgotPasswordAndRememberMe(
                  onPressed: () {
                    // TODO: navigate to ForgotPasswordScreen
                  },
                ),
                SizedBox(height: screenHeight * 0.05),
                PrimaryButton(
                  label: tr('login_button'),
                  isLoading: loading,
                  onPressed: () async {
                    if (_formKey.currentState!.validate()) {
                      setState(() => loading = true);

                      // Simulate network call — will replace with real auth use case call
                      await Future.delayed(const Duration(seconds: 2));

                      if (!mounted) return;
                      setState(() => loading = false);
                    }
                  },
                ),
                SizedBox(height: screenHeight * 0.012),
                AuthRichText(
                  onTap: () {
                    //go to sign up screen
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
