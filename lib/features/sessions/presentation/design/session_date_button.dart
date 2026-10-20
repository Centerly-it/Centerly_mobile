import 'package:flutter/material.dart';
import '../../../../core/theme/style_manager.dart';
import '../../../../core/theme/values_manager.dart';
import 'session_design.dart';

class SessionDateButton extends StatelessWidget {
  const SessionDateButton({
    required this.date,
    required this.title,
    required this.onDate,
    this.icon = false,
    super.key,
  });
  final DateTime date;
  final String title;
  final bool icon;
  final ValueChanged<DateTime> onDate;
  @override
  Widget build(BuildContext context) => TextButton(
    onPressed: () async {
      final selected = await showDatePicker(
        context: context,
        initialDate: date,
        firstDate: DateTime(2000),
        lastDate: DateTime(2100),
      );
      if (selected != null && context.mounted) onDate(selected);
    },
    child: Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (icon) ...[
          const SessionAsset('b1b35.svg'),
          const SizedBox(width: AppSize.s8),
        ],
        Flexible(
          child: Text(
            title,
            textAlign: TextAlign.center,
            style: AppTextStyles.bodyMedium,
          ),
        ),
      ],
    ),
  );
}
