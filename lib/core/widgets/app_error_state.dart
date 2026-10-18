import 'package:centrally/core/constants/strings_manager.dart';
import 'package:centrally/core/theme/color_manager.dart';
import 'package:centrally/core/theme/style_manager.dart';
import 'package:centrally/core/theme/values_manager.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

/// Generic error state widget — displayed when a screen fails to load data.
/// Provides a retry button for the future backend integration phase.
class AppErrorState extends StatelessWidget {
  const AppErrorState({super.key, this.title, this.subtitle, this.onRetry});

  final String? title;
  final String? subtitle;
  final VoidCallback? onRetry;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(AppPadding.p32),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const CircleAvatar(
            radius: AppSize.s40,
            backgroundColor: ColorManager.errorLight,
            child: Icon(
              Icons.wifi_off_outlined,
              color: ColorManager.error,
              size: AppSize.s40,
            ),
          ),
          const SizedBox(height: AppSize.s20),
          Text(
            title ?? StringsManager.errorTitle.tr(),
            style: AppTextStyles.headlineSmall,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: AppSize.s8),
          Text(
            subtitle ?? StringsManager.errorSubtitle.tr(),
            style: AppTextStyles.bodySmall,
            textAlign: TextAlign.center,
          ),
          if (onRetry != null) ...[
            const SizedBox(height: AppSize.s20),
            FilledButton.icon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh),
              label: Text(StringsManager.retryButton.tr()),
            ),
          ],
        ],
      ),
    );
  }
}
