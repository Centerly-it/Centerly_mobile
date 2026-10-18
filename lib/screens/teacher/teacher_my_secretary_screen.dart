import 'package:centrally/core/constants/strings_manager.dart';
import 'package:centrally/core/theme/color_manager.dart';
import 'package:centrally/core/theme/style_manager.dart';
import 'package:centrally/core/theme/values_manager.dart';
import 'package:centrally/mock_data/centerly_mock_data.dart';
import 'package:centrally/models/centerly_models.dart';
import 'package:centrally/screens/teacher/teacher_shared.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

class TeacherMySecretaryScreen extends StatefulWidget {
  const TeacherMySecretaryScreen({super.key});

  @override
  State<TeacherMySecretaryScreen> createState() =>
      _TeacherMySecretaryScreenState();
}

class _TeacherMySecretaryScreenState extends State<TeacherMySecretaryScreen> {
  String _query = '';

  @override
  Widget build(BuildContext context) {
    final filteredSecretaries = CenterlyMockData.secretaries.where((s) {
      final text = '${s.name} ${s.phone}'.toLowerCase();
      return text.contains(_query.trim().toLowerCase());
    }).toList();

    return Scaffold(
      backgroundColor: ColorManager.background,
      appBar: AppBar(
        backgroundColor: ColorManager.background,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(
            Icons.chevron_right,
            color: ColorManager.textPrimary,
          ),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          StringsManager.secretaryTitle.tr(),
          style: AppTextStyles.headlineSmall.copyWith(
            color: ColorManager.textPrimary,
          ),
        ),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(AppPadding.p16),
            child: TeacherSearchField(
              hint: StringsManager.secretarySearchHint.tr(),
              onChanged: (value) => setState(() => _query = value),
            ),
          ),
          Expanded(
            child: filteredSecretaries.isEmpty
                ? TeacherEmptyState(
                    title: StringsManager.secretaryEmptyTitle.tr(),
                    subtitle: StringsManager.secretaryEmptySubtitle.tr(),
                    icon: Icons.person_off_outlined,
                  )
                : ListView.builder(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppPadding.p16,
                      vertical: AppPadding.p8,
                    ),
                    itemCount: filteredSecretaries.length,
                    itemBuilder: (context, index) {
                      final secretary = filteredSecretaries[index];
                      return _SecretaryCard(
                        secretary: secretary,
                        onRemoveRequested: () => _requestRemoval(secretary),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }

  void _requestRemoval(SecretaryProfile secretary) {
    setState(() {
      CenterlyMockData.secretaryRemovalRequests.add(
        SecretaryRemovalRequest(
          id: 'req_${DateTime.now().millisecondsSinceEpoch}',
          teacherId: secretary.teacherId,
          secretaryId: secretary.id,
          status: RemovalRequestStatus.pending,
          requestedAt: DateTime.now(),
        ),
      );
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(StringsManager.secretaryRemovalSuccess.tr())),
    );
  }
}

class _SecretaryCard extends StatelessWidget {
  const _SecretaryCard({
    required this.secretary,
    required this.onRemoveRequested,
  });

  final SecretaryProfile secretary;
  final VoidCallback onRemoveRequested;

  @override
  Widget build(BuildContext context) {
    final pendingRequest = CenterlyMockData.secretaryRemovalRequests.any(
      (r) =>
          r.secretaryId == secretary.id &&
          r.status == RemovalRequestStatus.pending,
    );

    return TeacherCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: AppSize.s48,
                height: AppSize.s48,
                decoration: const BoxDecoration(
                  color: ColorManager.primary,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.person_outline,
                  color: ColorManager.white,
                ),
              ),
              const SizedBox(width: AppSize.s12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(secretary.name, style: AppTextStyles.titleMedium),
                    const SizedBox(height: AppSize.s4),
                    Text(secretary.phone, style: AppTextStyles.labelSmall),
                  ],
                ),
              ),
              _StatusBadge(status: secretary.status),
            ],
          ),
          const SizedBox(height: AppSize.s16),
          Row(
            children: [
              const Icon(
                Icons.email_outlined,
                size: AppSize.s16,
                color: ColorManager.grey500,
              ),
              const SizedBox(width: AppSize.s8),
              Text(secretary.email, style: AppTextStyles.bodySmall),
            ],
          ),
          const SizedBox(height: AppSize.s16),
          if (pendingRequest)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(
                horizontal: AppPadding.p12,
                vertical: AppPadding.p10,
              ),
              decoration: BoxDecoration(
                color: ColorManager.warningLight,
                borderRadius: BorderRadius.circular(AppRadius.r8),
              ),
              child: Row(
                children: [
                  const Icon(
                    Icons.access_time_outlined,
                    size: AppSize.s16,
                    color: ColorManager.warning,
                  ),
                  const SizedBox(width: AppSize.s8),
                  Expanded(
                    child: Text(
                      StringsManager.secretaryRemovalPending.tr(),
                      style: AppTextStyles.labelSmall.copyWith(
                        color: ColorManager.warning,
                      ),
                    ),
                  ),
                ],
              ),
            )
          else if (secretary.status == SecretaryStatus.active)
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: () => _confirmRemoval(context),
                icon: const Icon(
                  Icons.person_remove_outlined,
                  color: ColorManager.error,
                  size: AppSize.s18,
                ),
                label: Text(
                  StringsManager.secretaryRequestRemoval.tr(),
                  style: AppTextStyles.titleSmall.copyWith(
                    color: ColorManager.error,
                  ),
                ),
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: ColorManager.error),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Future<void> _confirmRemoval(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(StringsManager.secretaryRemovalConfirmTitle.tr()),
        content: Text(
          StringsManager.secretaryRemovalConfirmMessage.tr(
            namedArgs: {'name': secretary.name},
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text(StringsManager.secretaryCancelAction.tr()),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: FilledButton.styleFrom(backgroundColor: ColorManager.error),
            child: Text(StringsManager.secretaryConfirmAction.tr()),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      onRemoveRequested();
    }
  }
}

class _StatusBadge extends StatelessWidget {
  const _StatusBadge({required this.status});

  final SecretaryStatus status;

  @override
  Widget build(BuildContext context) {
    final isActive = status == SecretaryStatus.active;
    final color = isActive ? ColorManager.success : ColorManager.error;

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppPadding.p8,
        vertical: AppPadding.p4,
      ),
      decoration: BoxDecoration(
        color: color.withAlpha(25),
        borderRadius: BorderRadius.circular(AppRadius.circular),
      ),
      child: Text(
        isActive
            ? StringsManager.secretaryStatusActive.tr()
            : StringsManager.secretaryStatusInactive.tr(),
        style: AppTextStyles.labelSmall.copyWith(color: color),
      ),
    );
  }
}
