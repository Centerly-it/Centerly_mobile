import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import '../../../core/theme/values_manager.dart';
import '../../../models/centerly_models.dart';
import '../domain/session_record.dart';
import 'cancel_session_dialog.dart';
import 'session_detail_page.dart';

class SessionCardActions extends StatelessWidget {
  const SessionCardActions({
    required this.session,
    required this.showDetails,
    this.onChanged,
    this.onTap,
    super.key,
  });
  final SessionRecord session;
  final bool showDetails;
  final VoidCallback? onChanged, onTap;
  @override
  Widget build(BuildContext context) => Wrap(
    alignment: WrapAlignment.spaceBetween,
    spacing: AppSize.s12,
    children: [
      if (onChanged != null &&
          session.groupName != null &&
          session.status != SessionStatus.cancelled &&
          session.status != SessionStatus.completed)
        TextButton(
          onPressed: () async {
            final changed = await showDialog<bool>(
              context: context,
              barrierDismissible: false,
              builder: (_) => CancelSessionDialog(
                sessionId: session.id,
                sessionLabel: session.groupName!,
              ),
            );
            // Errors may be ambiguous; always reconcile after closing.
            if (context.mounted && changed != null) onChanged!();
          },
          child: Text('session_cancel_button'.tr()),
        ),
      if (showDetails)
        TextButton(
          onPressed:
              onTap ??
              () async {
                await SessionDetailPage.open(context, session.id);
                if (context.mounted) onChanged?.call();
              },
          child: Text('session_details_title'.tr()),
        ),
    ],
  );
}
