import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import '../../../../core/theme/values_manager.dart';

class AccountCheckView extends StatelessWidget {
  const AccountCheckView({super.key});
  @override
  Widget build(BuildContext context) => Scaffold(
    body: Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const CircularProgressIndicator(),
          const SizedBox(height: AppSize.s16),
          Text('auth_validating'.tr()),
        ],
      ),
    ),
  );
}
