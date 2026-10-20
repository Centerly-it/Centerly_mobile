import 'package:flutter/material.dart';
import '../../../../core/theme/values_manager.dart';
import 'session_design.dart';
import 'session_cancel_form.dart';

class SessionCancelSheet extends StatelessWidget {
  const SessionCancelSheet({super.key});
  static Future<String?> open(BuildContext context) =>
      showModalBottomSheet<String>(
        context: context,
        isScrollControlled: true,
        showDragHandle: true,
        backgroundColor: SessionDesign.background,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(
            top: Radius.circular(AppRadius.r16),
          ),
        ),
        builder: (_) => const SessionCancelSheet(),
      );
  @override
  Widget build(BuildContext context) => const SessionCancelForm();
}
