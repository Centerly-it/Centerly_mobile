import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../../../../core/theme/color_manager.dart';
import '../../../../core/theme/style_manager.dart';
import '../../../../core/theme/values_manager.dart';

class StudentDataTable extends StatelessWidget {
  const StudentDataTable({
    required this.headers,
    required this.rows,
    super.key,
  });
  final List<String> headers;
  final List<List<Widget>> rows;
  @override
  Widget build(BuildContext context) => LayoutBuilder(
    builder: (context, constraints) {
      final scale = MediaQuery.textScalerOf(context).scale(12) / 12;
      final width = math.max(constraints.maxWidth, 310 * scale);
      Widget row(List<Widget> cells) => Container(
        padding: const EdgeInsets.symmetric(vertical: AppPadding.p12),
        decoration: const BoxDecoration(
          border: Border(top: BorderSide(color: ColorManager.stroke)),
        ),
        child: Row(
          children: [
            for (var i = 0; i < cells.length; i++)
              Expanded(
                child: Align(
                  alignment: i == 0
                      ? AlignmentDirectional.centerStart
                      : i == cells.length - 1
                      ? AlignmentDirectional.centerEnd
                      : Alignment.center,
                  child: cells[i],
                ),
              ),
          ],
        ),
      );
      return SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: SizedBox(
          width: width,
          child: Column(
            children: [
              row([
                for (final label in headers)
                  Text(
                    label,
                    style: AppTextStyles.caption.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
              ]),
              for (final cells in rows) row(cells),
            ],
          ),
        ),
      );
    },
  );
}
