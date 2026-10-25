import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

import '../format/cairo_time.dart';
import '../theme/color_manager.dart';
import '../theme/values_manager.dart';

/// A single, quiet timestamp shown at the very end of a data page.
class DataUpdateFooter extends StatelessWidget {
  const DataUpdateFooter({required this.updatedAt, super.key});

  final DateTime updatedAt;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(top: AppPadding.p16, bottom: AppPadding.p8),
    child: Text(
      'detail_updated'.tr(
        args: [
          '${CairoTime.date(CairoTime.local(updatedAt))} ${CairoTime.time(updatedAt, context.locale.languageCode)}',
        ],
      ),
      textAlign: TextAlign.center,
      style: const TextStyle(
        color: ColorManager.textSecondary,
        fontSize: 9,
        height: 1.2,
      ),
    ),
  );
}
