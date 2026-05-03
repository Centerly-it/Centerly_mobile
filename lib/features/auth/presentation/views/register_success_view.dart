import 'package:centrally/core/res/color_manager.dart';
import 'package:centrally/features/auth/presentation/widgets/register_success_view_body.dart';
import 'package:flutter/material.dart';

class RegisterSuccessView extends StatelessWidget {
  const RegisterSuccessView({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      backgroundColor: ColorManager.background,

      body: SafeArea(child: RegisterSuccessViewBody()),
    );
  }
}
