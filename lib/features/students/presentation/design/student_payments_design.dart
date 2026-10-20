import 'student_invoice_history.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import '../../../../core/format/money_egp.dart';
import '../../../../core/theme/color_manager.dart';
import '../../../../core/theme/values_manager.dart';
import '../../../../core/widgets/app_surface_section.dart';
import 'student_design.dart';
import '../../preview/student_preview_data.dart';
import 'student_summary_tiles.dart';

class StudentPaymentsDesign extends StatelessWidget {
  const StudentPaymentsDesign({required this.data, super.key});
  final StudentPreviewData data;
  @override
  Widget build(BuildContext context) {
    final unit = 'student_design_currency'.tr();
    return Column(
      children: [
        AppSurfaceSection(
          title: 'student_design_payments_summary'.tr(),
          icon: const StudentAsset('246ac.svg'),
          child: StudentSummaryTiles(
            values: [
              StudentSummaryValue(
                'student_design_expected'.tr(),
                MoneyEgp.parse(data.expectedEgp).groupedWholePounds,
                unit: unit,
              ),
              StudentSummaryValue(
                'student_design_collected'.tr(),
                MoneyEgp.parse(data.collectedEgp).groupedWholePounds,
                unit: unit,
                color: ColorManager.success,
              ),
              StudentSummaryValue(
                'student_design_remaining'.tr(),
                MoneyEgp.parse(data.remainingEgp).groupedWholePounds,
                unit: unit,
                color: ColorManager.error,
              ),
            ],
          ),
        ),
        const SizedBox(height: AppSize.s16),
        StudentInvoiceHistory(data: data),
      ],
    );
  }
}
