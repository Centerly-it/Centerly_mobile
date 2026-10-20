import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import '../../../../core/theme/style_manager.dart';
import '../../../../core/theme/values_manager.dart';
import 'session_cancel_reason.dart';
import 'session_cancel_buttons.dart';
import '../../../../core/theme/color_manager.dart';

class SessionCancelForm extends StatefulWidget {
  const SessionCancelForm({super.key});
  @override
  State<SessionCancelForm> createState() => _SessionCancelFormState();
}

class _SessionCancelFormState extends State<SessionCancelForm> {
  int _reason = 2;
  final _text = TextEditingController();
  bool _error = false;
  @override
  void dispose() {
    _text.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => SafeArea(
    top: false,
    child: SingleChildScrollView(
      padding: EdgeInsets.fromLTRB(
        AppPadding.p16,
        0,
        AppPadding.p16,
        AppPadding.p16 + MediaQuery.viewInsetsOf(context).bottom,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            'cancel_session_title'.tr(),
            textAlign: TextAlign.center,
            style: AppTextStyles.headlineMedium,
          ),
          const SizedBox(height: AppSize.s16),
          for (var i = 0; i < 3; i++) ...[
            SessionCancelReason(
              index: i,
              selected: _reason == i,
              onTap: () => setState(() {
                _reason = i;
                _error = false;
              }),
              child: i == 2 && _reason == 2
                  ? TextField(
                      controller: _text,
                      minLines: 1,
                      maxLines: 2,
                      maxLength: 500,
                      decoration: InputDecoration(
                        hintText: 'cancel_reason_hint'.tr(),
                        counterText: '',
                        filled: true,
                        fillColor: ColorManager.grey200,
                        errorText: _error
                            ? 'live_error_VALIDATION_ERROR'.tr()
                            : null,
                      ),
                    )
                  : null,
            ),
            const SizedBox(height: AppSize.s12),
          ],
          SessionCancelButtons(
            onConfirm: () {
              if (_reason == 2 && _text.text.trim().isEmpty) {
                setState(() => _error = true);
                return;
              }
              Navigator.of(context).pop(
                _reason == 2
                    ? _text.text.trim()
                    : SessionCancelReason.keys[_reason].tr(),
              );
            },
          ),
        ],
      ),
    ),
  );
}
