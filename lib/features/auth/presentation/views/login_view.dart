import 'package:centrally/core/res/color_manager.dart';
import 'package:centrally/core/res/values_manager.dart';
import 'package:centrally/features/auth/presentation/widgets/brand_logo.dart';
import 'package:centrally/features/auth/presentation/widgets/email_feild.dart';
import 'package:centrally/features/auth/presentation/widgets/password_field.dart';
import 'package:centrally/features/auth/presentation/widgets/remember_forgor_row.dart';
import 'package:centrally/features/auth/presentation/widgets/sign_up_row.dart';
import 'package:centrally/features/auth/presentation/widgets/submit_button.dart';
import 'package:centrally/features/auth/presentation/widgets/welcome_header.dart';
import 'package:flutter/material.dart';

class LoginView extends StatefulWidget {
  const LoginView({super.key});

  @override
  State<LoginView> createState() => _LoginViewState();
}

class _LoginViewState extends State<LoginView> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _rememberMe = false;
  bool _obscurePassword = true;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _submit() {
    if (_formKey.currentState?.validate() ?? false) {
      // TODO: dispatch login cubit event
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ColorManager.background,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: AppPadding.p24),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: AppSize.s40),
                const BrandLogo(),
                const SizedBox(height: AppSize.s32),
                const WelcomeHeader(),
                const SizedBox(height: AppSize.s32),
                EmailField(controller: _emailController),
                const SizedBox(height: AppSize.s16),
                PasswordField(
                  controller: _passwordController,
                  obscure: _obscurePassword,
                  onToggleObscure: () =>
                      setState(() => _obscurePassword = !_obscurePassword),
                ),
                const SizedBox(height: AppSize.s12),
                RememberForgotRow(
                  rememberMe: _rememberMe,
                  onRememberChanged: (v) =>
                      setState(() => _rememberMe = v ?? false),
                ),
                const SizedBox(height: AppSize.s32),
                SubmitButton(onPressed: _submit),
                const SizedBox(height: AppSize.s20),
                const SignUpRow(),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
