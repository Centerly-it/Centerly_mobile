import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/di/di.dart';
import '../../../../core/auth/remembered_login.dart';
import '../../../../core/config/app_config.dart';
import '../../../../core/config/preview_mode.dart';
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
  late final _remembered = RememberedLogin(AppConfig.fromEnvironment().url);
  @override
  void initState() {
    super.initState();
    _restoreLogin();
  }

  Future<void> _restoreLogin() async {
    if (PreviewMode.enabled) return;
    final saved = await _remembered.read();
    if (!mounted ||
        saved == null ||
        _email.text.isNotEmpty ||
        _password.text.isNotEmpty) {
      return;
    }
    _email.text = saved.email;
    _password.text = saved.password;
  }

  @override
  void dispose() {
    _email.dispose();
    _password.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (_formKey.currentState?.validate() ?? false) {
      final email = _email.text, password = _password.text;
      final session = getIt<AuthSessionCubit>();
      await session.login(email, password);
      if (session.state.isAuthenticated && !PreviewMode.enabled) {
        await _remembered.save(email, password);
      }
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
                  const SizedBox(height: AppSize.s64),
                  BrandLogo(
                    showTagline: false,
                    size: (MediaQuery.sizeOf(context).width * 0.56).clamp(
                      AppSize.s120,
                      AppSize.s240,
                    ),
                  ),
                  const SizedBox(height: AppSize.s64),
                  const WelcomeHeader(),
                  const SizedBox(height: AppSize.s24),
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
