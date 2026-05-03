// // ---------------------------------------------------------------------------
// // Submit button
// // ---------------------------------------------------------------------------

// import 'package:centrally/core/res/color_manager.dart';
// import 'package:centrally/core/res/strings_manager.dart';
// import 'package:centrally/core/res/style_manager.dart';
// import 'package:centrally/core/res/values_manager.dart';
// import 'package:easy_localization/easy_localization.dart';
// import 'package:flutter/material.dart';

// class SubmitButton extends StatelessWidget {
//   const SubmitButton({required this.onPressed, super.key});

//   final VoidCallback onPressed;

//   @override
//   Widget build(BuildContext context) {
//     return SizedBox(
//       height: AppSize.s54,
//       child: FilledButton(
//         onPressed: onPressed,
//         child: Text(
//           StringsManager.loginSubmit.tr(),
//           style: AppTextStyles.titleMedium.copyWith(color: ColorManager.white),
//         ),
//       ),
//     );
//   }
// }

import 'package:centrally/core/res/color_manager.dart';
import 'package:centrally/core/res/strings_manager.dart';
import 'package:centrally/core/res/style_manager.dart';
import 'package:centrally/core/res/values_manager.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

class SubmitButton extends StatelessWidget {
  const SubmitButton({
    required this.onPressed,
    required this.isLoading,
    super.key,
  });

  final VoidCallback? onPressed;
  final bool isLoading;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: AppSize.s54,
      child: FilledButton(
        onPressed: () {
          if (isLoading) return;
          onPressed?.call();
        },
        child: AnimatedSwitcher(
          duration: const Duration(milliseconds: 300),
          child: isLoading
              ? const SizedBox(
                  key: ValueKey(StringsManager.loader),
                  width: AppSize.s20,
                  height: AppSize.s20,
                  child: CircularProgressIndicator(
                    strokeWidth: AppSize.s2,
                    color: Colors.white,
                  ),
                )
              : Text(
                  StringsManager.loginSubmit.tr(),
                  key: const ValueKey('text'),
                  style: AppTextStyles.titleMedium.copyWith(
                    color: ColorManager.white,
                  ),
                ),
        ),
      ),
    );
  }
}
