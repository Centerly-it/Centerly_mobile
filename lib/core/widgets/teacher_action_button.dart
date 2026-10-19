import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import '../errors/backend_failure.dart';

class TeacherActionButton extends StatefulWidget {
  const TeacherActionButton({
    required this.label,
    required this.action,
    required this.onReconcile,
    this.confirmation,
    super.key,
  });
  final String label;
  final String? confirmation;
  final Future<void> Function() action, onReconcile;
  @override
  State<TeacherActionButton> createState() => _TeacherActionButtonState();
}

class _TeacherActionButtonState extends State<TeacherActionButton> {
  bool busy = false;
  Future<void> submit() async {
    if (busy) return;
    setState(() => busy = true);
    try {
      if (widget.confirmation != null) {
        final yes = await showDialog<bool>(
          context: context,
          barrierDismissible: false,
          builder: (_) => AlertDialog(
            title: Text(widget.label),
            content: Text(widget.confirmation!),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: Text('cancel_back'.tr()),
              ),
              FilledButton(
                onPressed: () => Navigator.pop(context, true),
                child: Text('completion_confirm'.tr()),
              ),
            ],
          ),
        );
        if (yes != true) return;
      }
      await widget.action();
    } catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'live_error_${error is BackendFailure ? error.code : 'SERVICE_UNAVAILABLE'}'
                  .tr(),
            ),
          ),
        );
      }
    } finally {
      // Includes ambiguous transport errors: never automatically repeat the mutation.
      if (mounted) {
        await widget.onReconcile();
        if (mounted) setState(() => busy = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) => TextButton(
    onPressed: busy ? null : submit,
    child: Text(busy ? 'loading_data'.tr() : widget.label),
  );
}
