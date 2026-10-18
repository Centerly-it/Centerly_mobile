import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/di/di.dart';
import '../../../../core/theme/color_manager.dart';
import '../../../../core/theme/values_manager.dart';
import '../../../../core/widgets/brand_logo.dart';
import '../view_models/auth_session_cubit.dart';
import '../view_models/auth_session_state.dart';
import '../widgets/auth_error_text.dart';
import '../widgets/contact_support_button.dart';
import '../widgets/email_field.dart';
import '../widgets/password_field.dart';
import '../widgets/submit_button.dart';
import '../widgets/welcome_header.dart';

class LoginView extends StatefulWidget {
  const LoginView({super.key});
  @override
  State<LoginView> createState() => _LoginViewState();
}

class _LoginViewState extends State<LoginView> {
  final _formKey = GlobalKey<FormState>();
  final _email = TextEditingController();
  final _password = TextEditingController();
  bool _obscure = true;
  @override
  void dispose() {
    _email.dispose();
    _password.dispose();
    super.dispose();
  }

  void _submit() {
    if (_formKey.currentState?.validate() ?? false) {
      getIt<AuthSessionCubit>().login(_email.text, _password.text);
    }
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    backgroundColor: ColorManager.background,
    body: SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: AppPadding.p24),
        child: BlocBuilder<AuthSessionCubit, AuthSessionState>(
          bloc: getIt<AuthSessionCubit>(),
          builder: (context, state) => AutofillGroup(
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const SizedBox(height: AppSize.s40),
                  const BrandLogo(),
                  const SizedBox(height: AppSize.s32),
                  const WelcomeHeader(),
                  const SizedBox(height: AppSize.s24),
                  Text('auth_teacher_only'.tr()),
                  const SizedBox(height: AppSize.s16),
                  EmailField(controller: _email),
                  const SizedBox(height: AppSize.s16),
                  PasswordField(
                    controller: _password,
                    obscure: _obscure,
                    loginOnly: true,
                    onToggleObscure: () => setState(() => _obscure = !_obscure),
                  ),
                  const SizedBox(height: AppSize.s16),
                  if (state.errorCode != null) AuthErrorText(state.errorCode!),
                  const SizedBox(height: AppSize.s16),
                  SubmitButton(
                    onPressed: _submit,
                    isLoading: state.status == AuthSessionStatus.checking,
                  ),
                  const SizedBox(height: AppSize.s12),
                  const ContactSupportButton(),
                ],
              ),
            ),
          ),
        ),
      ),
    ),
  );
}
