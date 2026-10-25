import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:centrally/features/finances/presentation/live_receipt_card.dart';
import 'package:centrally/features/finances/presentation/design/finance_design.dart';

void expectReceiptAlignment(WidgetTester tester, String locale) {
  final receiptHeader = find
      .descendant(of: find.byType(LiveReceiptCard), matching: find.byType(Row))
      .first;
  final receiptAmount = find
      .descendant(
        of: find.byType(LiveReceiptCard),
        matching: find.byType(FinanceMoney),
      )
      .first;
  final headerRect = tester.getRect(receiptHeader),
      amountRect = tester.getRect(receiptAmount);
  expect(amountRect.center.dy, closeTo(headerRect.center.dy, 1));
  expect(
    locale == 'ar' ? amountRect.left : amountRect.right,
    closeTo(locale == 'ar' ? headerRect.left : headerRect.right, 1),
  );
}
