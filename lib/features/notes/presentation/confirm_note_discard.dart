import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

Future<bool> confirmNoteDiscard(BuildContext context) async =>
    await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: Text('completion_discard_note'.tr()),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text('cancel_back'.tr()),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text('completion_discard'.tr()),
          ),
        ],
      ),
    ) ==
    true;
