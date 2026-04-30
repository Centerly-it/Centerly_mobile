import 'package:centrally/core/res/assets_manager.dart';
import 'package:centrally/core/res/color_manager.dart';
import 'package:centrally/core/res/strings_manager.dart';
import 'package:centrally/core/res/style_manager.dart';
import 'package:centrally/core/res/values_manager.dart';
import 'package:easy_localization/easy_localization.dart';
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
                const _BrandLogo(),
                const SizedBox(height: AppSize.s32),
                const _WelcomeHeader(),
                const SizedBox(height: AppSize.s32),
                _EmailField(controller: _emailController),
                const SizedBox(height: AppSize.s16),
                _PasswordField(
                  controller: _passwordController,
                  obscure: _obscurePassword,
                  onToggleObscure: () =>
                      setState(() => _obscurePassword = !_obscurePassword),
                ),
                const SizedBox(height: AppSize.s12),
                _RememberForgotRow(
                  rememberMe: _rememberMe,
                  onRememberChanged: (v) =>
                      setState(() => _rememberMe = v ?? false),
                ),
                const SizedBox(height: AppSize.s32),
                _SubmitButton(onPressed: _submit),
                const SizedBox(height: AppSize.s20),
                const _SignUpRow(),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Brand logo
// ---------------------------------------------------------------------------

class _BrandLogo extends StatelessWidget {
  const _BrandLogo();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Image.asset(
        AssetsManager.logoAppIcon,
        width: 120,
        height: 120,
        errorBuilder: (_, __, _) => const SizedBox(width: 120, height: 120),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Welcome header
// ---------------------------------------------------------------------------

class _WelcomeHeader extends StatelessWidget {
  const _WelcomeHeader();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Text(
          StringsManager.loginWelcomeTitle.tr(),
          style: AppTextStyles.headlineMedium,
        ),
        const SizedBox(height: AppSize.s6),
        Text(
          StringsManager.loginWelcomeSubtitle.tr(),
          textAlign: TextAlign.right,
          style: AppTextStyles.bodyMedium.copyWith(
            color: ColorManager.textSecondary,
          ),
        ),
      ],
    );
  }
}

// ---------------------------------------------------------------------------
// Email field
// ---------------------------------------------------------------------------

class _EmailField extends StatelessWidget {
  const _EmailField({required this.controller});

  final TextEditingController controller;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Text(StringsManager.loginEmailLabel.tr(), style: AppTextStyles.titleSmall),
        const SizedBox(height: AppSize.s8),
        TextFormField(
          controller: controller,
          keyboardType: TextInputType.emailAddress,
          textAlign: TextAlign.left,
          decoration: InputDecoration(
            hintText: StringsManager.loginEmailHint.tr(),
            suffixIcon: Container(
              margin: const EdgeInsets.all(AppSize.s10),
              padding: const EdgeInsets.all(AppSize.s8),
              decoration: BoxDecoration(
                color: ColorManager.grey100,
                borderRadius: BorderRadius.circular(AppSize.s8),
              ),
              child: const Icon(
                Icons.email_outlined,
                color: ColorManager.grey500,
                size: AppSize.s18,
              ),
            ),
          ),
          validator: (v) {
            if (v == null || v.trim().isEmpty) {
              return StringsManager.validationEmailRequired.tr();
            }
            final emailRegex = RegExp(r'^[\w-.]+@([\w-]+\.)+[\w-]{2,4}$');
            if (!emailRegex.hasMatch(v.trim())) {
              return StringsManager.validationEmailInvalid.tr();
            }
            return null;
          },
        ),
      ],
    );
  }
}

// ---------------------------------------------------------------------------
// Password field
// ---------------------------------------------------------------------------

class _PasswordField extends StatelessWidget {
  const _PasswordField({
    required this.controller,
    required this.obscure,
    required this.onToggleObscure,
  });

  final TextEditingController controller;
  final bool obscure;
  final VoidCallback onToggleObscure;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Text(StringsManager.loginPasswordLabel.tr(), style: AppTextStyles.titleSmall),
        const SizedBox(height: AppSize.s8),
        TextFormField(
          controller: controller,
          obscureText: obscure,
          textAlign: TextAlign.left,
          decoration: InputDecoration(
            prefixIcon: IconButton(
              icon: Icon(
                obscure
                    ? Icons.visibility_outlined
                    : Icons.visibility_off_outlined,
                color: ColorManager.grey500,
                size: AppSize.s20,
              ),
              onPressed: onToggleObscure,
            ),
            suffixIcon: Container(
              margin: const EdgeInsets.all(AppSize.s10),
              padding: const EdgeInsets.all(AppSize.s8),
              decoration: BoxDecoration(
                color: ColorManager.grey100,
                borderRadius: BorderRadius.circular(AppSize.s8),
              ),
              child: const Icon(
                Icons.lock_outline,
                color: ColorManager.grey500,
                size: AppSize.s18,
              ),
            ),
          ),
          validator: (v) {
            if (v == null || v.isEmpty) {
              return StringsManager.validationPasswordRequired.tr();
            }
            if (v.length < 8) {
              return StringsManager.validationPasswordMin.tr();
            }
            return null;
          },
        ),
      ],
    );
  }
}

// ---------------------------------------------------------------------------
// Remember me + forgot password row
// ---------------------------------------------------------------------------

class _RememberForgotRow extends StatelessWidget {
  const _RememberForgotRow({
    required this.rememberMe,
    required this.onRememberChanged,
  });

  final bool rememberMe;
  final ValueChanged<bool?> onRememberChanged;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        TextButton(
          onPressed: () {},
          style: TextButton.styleFrom(
            padding: EdgeInsets.zero,
            minimumSize: Size.zero,
            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
          ),
          child: Text(
            StringsManager.loginForgotPassword.tr(),
            style: AppTextStyles.labelSmall.copyWith(color: ColorManager.primary),
          ),
        ),
        Row(
          children: [
            Text(StringsManager.loginRememberMe.tr(), style: AppTextStyles.labelSmall),
            const SizedBox(width: AppSize.s8),
            SizedBox(
              width: AppSize.s20,
              height: AppSize.s20,
              child: Checkbox(
                value: rememberMe,
                onChanged: onRememberChanged,
                activeColor: ColorManager.primary,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(AppSize.s5),
                ),
                side: const BorderSide(color: ColorManager.border),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

// ---------------------------------------------------------------------------
// Submit button
// ---------------------------------------------------------------------------

class _SubmitButton extends StatelessWidget {
  const _SubmitButton({required this.onPressed});

  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: AppSize.s54,
      child: FilledButton(
        onPressed: onPressed,
        child: Text(
          StringsManager.loginSubmit.tr(),
          style: AppTextStyles.titleMedium.copyWith(color: ColorManager.white),
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Sign up row
// ---------------------------------------------------------------------------

class _SignUpRow extends StatelessWidget {
  const _SignUpRow();

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        TextButton(
          onPressed: () {},
          style: TextButton.styleFrom(
            padding: EdgeInsets.zero,
            minimumSize: Size.zero,
            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
          ),
          child: Text(
            StringsManager.loginCreateAccount.tr(),
            style: AppTextStyles.labelLarge.copyWith(color: ColorManager.primary),
          ),
        ),
        const SizedBox(width: AppSize.s5),
        Text(
          StringsManager.loginNoAccount.tr(),
          style: AppTextStyles.labelLarge.copyWith(color: ColorManager.textSecondary),
        ),
      ],
    );
  }
}
