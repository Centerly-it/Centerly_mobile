import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import '../../../core/api/teacher_read_client.dart';
import '../../../core/di/di.dart';
import '../../../core/errors/backend_failure.dart';
import '../../../core/theme/values_manager.dart';
import '../data/session_actions.dart';

class CancelSessionDialog extends StatefulWidget {
  const CancelSessionDialog({
    required this.sessionId,
    required this.sessionLabel,
    super.key,
  });
  final String sessionId, sessionLabel;
  @override
  State<CancelSessionDialog> createState() => _CancelSessionDialogState();
}

class _CancelSessionDialogState extends State<CancelSessionDialog> {
  final _reason = TextEditingController();
  bool _busy = false;
  bool _mustRefresh = false;
  String? _error;
  @override
  void dispose() {
    _reason.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (_busy) return;
    if (_reason.text.trim().isEmpty) {
      setState(() {
        _error = 'VALIDATION_ERROR';
      });
      return;
    }
    setState(() {
      _busy = true;
      _error = null;
    });
    try {
      await SessionActions(
        getIt<TeacherReadClient>(),
      ).cancel(widget.sessionId, _reason.text);
      if (mounted) Navigator.of(context).pop(true);
    } catch (error) {
      if (mounted) {
        setState(() {
          _busy = false;
          _error = error is BackendFailure ? error.code : 'SERVICE_UNAVAILABLE';
          _mustRefresh = true;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) => PopScope(
    canPop: !_busy,
    child: AlertDialog(
      title: Text('cancel_session_title'.tr()),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(widget.sessionLabel),
            Text('live_cancel_confirmation'.tr()),
            const SizedBox(height: AppSize.s12),
            TextField(
              controller: _reason,
              enabled: !_busy,
              maxLength: 500,
              maxLines: 3,
              decoration: InputDecoration(labelText: 'cancel_reason_hint'.tr()),
            ),
            if (_error != null)
              Semantics(
                liveRegion: true,
                child: Text('live_error_$_error'.tr()),
              ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: _busy ? null : () => Navigator.of(context).pop(false),
          child: Text('cancel_back'.tr()),
        ),
        FilledButton(
          onPressed: _busy || _mustRefresh ? null : _submit,
          child: Text((_busy ? 'loading_data' : 'cancel_submit').tr()),
        ),
      ],
    ),
  );
}
