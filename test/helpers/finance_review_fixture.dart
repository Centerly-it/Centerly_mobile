import 'package:centrally/features/finances/domain/finance_due.dart';

FinanceDue financeReviewInvoice() => FinanceDue({
  'id': 'invoice',
  'invoice_number': 'MAT-local',
  'student_name': 'محمد حسن — اسم طالب طويل للاختبار',
  'group_name': 'ثالثة ثانوي (ب)',
  'amount_egp': '700.50',
  'net_paid_egp': '300.25',
  'outstanding_egp': '400.25',
  'due_on': '2026-10-25',
  'status': 'partially_paid',
  'created_by_name': 'اسم السكرتير الذي أنشأ الفاتورة',
});

Map<String, dynamic> financeReviewReceipt(FinanceDue invoice) =>
    <String, dynamic>{
      'student_name': invoice.student,
      'signed_amount_egp': '-25.25',
      'collected_by_name': 'سكرتير التصحيح',
      'original_collected_by_name': 'سكرتير التحصيل الأصلي',
      'collected_at': '2026-10-25T08:15:00Z',
      'method': 'cash',
      'reversal_of': 'original',
      'reason': 'تصحيح تحصيل مع الحفاظ على السجل السابق',
    };
