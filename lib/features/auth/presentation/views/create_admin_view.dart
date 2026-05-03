import 'package:centrally/core/res/color_manager.dart';
import 'package:centrally/features/auth/presentation/widgets/create_admin_view_body.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class CreateAdminView extends StatelessWidget {
  const CreateAdminView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ColorManager.background,
      appBar: AppBar(
        backgroundColor: ColorManager.background,
        leading: IconButton(
          onPressed: () {
            context.pop();
          },
          icon: const Icon(
            Icons.arrow_back_ios_new_rounded,
            color: ColorManager.primary,
          ),
        ),
      ),
      body: const SafeArea(child: CreateAdminViewBody()),
    );
  }
}
