import 'dart:ui' as ui;
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import '../../../../core/theme/style_manager.dart';
import '../../../../core/theme/values_manager.dart';
import 'session_design.dart';
import 'session_summary_item.dart';
export 'session_summary_item.dart';

class SessionSummaryStrip extends StatelessWidget {
  const SessionSummaryStrip({required this.items, super.key});
  final List<SessionSummaryItem> items;
  @override
  Widget build(BuildContext context) => SessionPanel(
    padding: AppPadding.p8,
    child: LayoutBuilder(
      builder: (context, constraints) {
        final large = MediaQuery.textScalerOf(context).scale(12) > 18;
        return Wrap(
          spacing: 0,
          runSpacing: AppSize.s12,
          children: [
            for (var i = 0; i < items.length; i++)
              SizedBox(
                width: constraints.maxWidth / (large ? 2 : items.length),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppPadding.p4,
                  ),
                  decoration: BoxDecoration(
                    border: i == 0 || large
                        ? null
                        : const BorderDirectional(
                            start: BorderSide(color: SessionDesign.stroke),
                          ),
                  ),
                  child: Column(
                    children: [
                      Wrap(
                        textDirection: ui.TextDirection.ltr,
                        alignment: WrapAlignment.center,
                        crossAxisAlignment: WrapCrossAlignment.center,
                        spacing: 2,
                        children: [
                          SessionAsset(items[i].asset),
                          Text(
                            '${items[i].value}',
                            style: AppTextStyles.headlineMedium.copyWith(
                              color: items[i].color,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: AppSize.s4),
                      Text(
                        items[i].label.tr(),
                        textAlign: TextAlign.center,
                        style: AppTextStyles.caption.copyWith(
                          fontSize: items.length > 3 ? 10 : 12,
                          color: items[i].color,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
          ],
        );
      },
    ),
  );
}
