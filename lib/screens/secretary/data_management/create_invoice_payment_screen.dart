import 'dart:math';

import 'package:centrally/core/constants/strings_manager.dart';
import 'package:centrally/core/theme/color_manager.dart';
import 'package:centrally/core/theme/style_manager.dart';
import 'package:centrally/core/theme/values_manager.dart';
import 'package:centrally/mock_data/centerly_mock_data.dart';
import 'package:centrally/models/centerly_models.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

enum InvoicePaymentMode { createInvoice, recordPayment }

class CreateInvoicePaymentScreen extends StatefulWidget {
  const CreateInvoicePaymentScreen({
    super.key,
    this.initialMode = InvoicePaymentMode.createInvoice,
    this.preselectedStudentId,
  });

  final InvoicePaymentMode initialMode;
  final String? preselectedStudentId;

  @override
  State<CreateInvoicePaymentScreen> createState() =>
      _CreateInvoicePaymentScreenState();
}

class _CreateInvoicePaymentScreenState extends State<CreateInvoicePaymentScreen>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;
  final _invoiceFormKey = GlobalKey<FormState>();
  final _paymentFormKey = GlobalKey<FormState>();

  // Create Invoice Form State
  String? _invoiceStudentId;
  late final TextEditingController _amountController;
  late final TextEditingController _invoiceNumberController;
  DateTime _dueDate = DateTime.now().add(const Duration(days: 15));

  // Record Payment Form State
  String? _selectedInvoiceId;
  late final TextEditingController _paymentAmountController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(
      length: 2,
      vsync: this,
      initialIndex: widget.initialMode == InvoicePaymentMode.createInvoice
          ? 0
          : 1,
    );

    _invoiceStudentId =
        widget.preselectedStudentId ??
        (CenterlyMockData.students.isNotEmpty
            ? CenterlyMockData.students.first.id
            : null);
    _amountController = TextEditingController(text: '400');
    _invoiceNumberController = TextEditingController(
      text: '#${Random().nextInt(9000) + 1000}',
    );

    final dueInvoices = CenterlyMockData.invoices
        .where((i) => i.status == InvoiceStatus.due)
        .toList();
    _selectedInvoiceId = dueInvoices.isNotEmpty ? dueInvoices.first.id : null;
    _paymentAmountController = TextEditingController(
      text: dueInvoices.isNotEmpty
          ? (dueInvoices.first.amount - dueInvoices.first.paidAmount)
                .toStringAsFixed(0)
          : '400',
    );
  }

  @override
  void dispose() {
    _tabController.dispose();
    _amountController.dispose();
    _invoiceNumberController.dispose();
    _paymentAmountController.dispose();
    super.dispose();
  }

  void _saveInvoice() {
    if (!_invoiceFormKey.currentState!.validate()) return;
    if (_invoiceStudentId == null) return;

    final student = CenterlyMockData.studentById(_invoiceStudentId!);
    final amount = double.tryParse(_amountController.text.trim()) ?? 400.0;

    final invoice = Invoice(
      id: 'invoice-${DateTime.now().millisecondsSinceEpoch}',
      teacherId: 'teacher-1',
      studentId: _invoiceStudentId!,
      groupId: student.groupId,
      invoiceNumber: _invoiceNumberController.text.trim(),
      amount: amount,
      dueDate: _dueDate,
      status: InvoiceStatus.due,
      paidAmount: 0,
      createdAt: DateTime.now(),
    );

    CenterlyMockData.invoices.add(invoice);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(StringsManager.dataMgmtInvoiceSaved.tr())),
    );
    Navigator.of(context).pop(true);
  }

  void _savePayment() {
    if (!_paymentFormKey.currentState!.validate()) return;
    if (_selectedInvoiceId == null) return;

    final index = CenterlyMockData.invoices.indexWhere(
      (i) => i.id == _selectedInvoiceId,
    );
    if (index != -1) {
      final inv = CenterlyMockData.invoices[index];
      final paidAmt =
          double.tryParse(_paymentAmountController.text.trim()) ?? inv.amount;

      CenterlyMockData.invoices[index] = Invoice(
        id: inv.id,
        teacherId: inv.teacherId,
        studentId: inv.studentId,
        groupId: inv.groupId,
        invoiceNumber: inv.invoiceNumber,
        amount: inv.amount,
        dueDate: inv.dueDate,
        status: paidAmt >= inv.amount ? InvoiceStatus.paid : InvoiceStatus.due,
        paidAmount: paidAmt,
        paidAt: DateTime.now(),
        paidBy: 'secretary-1',
        createdAt: inv.createdAt,
      );
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(StringsManager.dataMgmtPaymentSaved.tr())),
    );
    Navigator.of(context).pop(true);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ColorManager.background,
      appBar: AppBar(
        backgroundColor: ColorManager.background,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(
            Icons.chevron_right,
            color: ColorManager.textPrimary,
          ),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          StringsManager.financeTitle.tr(),
          style: AppTextStyles.headlineSmall.copyWith(
            color: ColorManager.textPrimary,
          ),
        ),
        bottom: TabBar(
          controller: _tabController,
          labelColor: ColorManager.primary,
          unselectedLabelColor: ColorManager.textSecondary,
          indicatorColor: ColorManager.primary,
          labelStyle: AppTextStyles.titleSmall,
          tabs: [
            Tab(text: StringsManager.dataMgmtCreateInvoiceTitle.tr()),
            Tab(text: StringsManager.dataMgmtRecordPaymentTitle.tr()),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [_buildCreateInvoiceTab(), _buildRecordPaymentTab()],
      ),
    );
  }

  Widget _buildCreateInvoiceTab() {
    return Form(
      key: _invoiceFormKey,
      child: ListView(
        padding: const EdgeInsets.all(AppPadding.p16),
        children: [
          _FormFieldCard(
            label: StringsManager.dataMgmtSelectStudent.tr(),
            child: DropdownButtonFormField<String>(
              initialValue: _invoiceStudentId,
              decoration: InputDecoration(
                fillColor: ColorManager.grey200,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(AppRadius.r8),
                  borderSide: BorderSide.none,
                ),
              ),
              items: CenterlyMockData.students.map((student) {
                return DropdownMenuItem<String>(
                  value: student.id,
                  child: Text(student.name),
                );
              }).toList(),
              onChanged: (val) => setState(() => _invoiceStudentId = val),
            ),
          ),
          const SizedBox(height: AppSize.s14),
          _FormFieldCard(
            label: StringsManager.dataMgmtInvoiceNumber.tr(),
            child: TextFormField(
              controller: _invoiceNumberController,
              decoration: InputDecoration(
                fillColor: ColorManager.grey200,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(AppRadius.r8),
                  borderSide: BorderSide.none,
                ),
              ),
              validator: (val) => val == null || val.trim().isEmpty
                  ? StringsManager.validationRequired.tr()
                  : null,
            ),
          ),
          const SizedBox(height: AppSize.s14),
          _FormFieldCard(
            label: StringsManager.dataMgmtAmount.tr(),
            child: TextFormField(
              controller: _amountController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                fillColor: ColorManager.grey200,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(AppRadius.r8),
                  borderSide: BorderSide.none,
                ),
              ),
              validator: (val) => val == null || val.trim().isEmpty
                  ? StringsManager.validationRequired.tr()
                  : null,
            ),
          ),
          const SizedBox(height: AppSize.s14),
          _FormFieldCard(
            label: StringsManager.dataMgmtDueDate.tr(),
            child: InkWell(
              onTap: () async {
                final picked = await showDatePicker(
                  context: context,
                  initialDate: _dueDate,
                  firstDate: DateTime(2025),
                  lastDate: DateTime(2030),
                );
                if (picked != null) {
                  setState(() => _dueDate = picked);
                }
              },
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppPadding.p14,
                  vertical: AppPadding.p12,
                ),
                decoration: BoxDecoration(
                  color: ColorManager.grey200,
                  borderRadius: BorderRadius.circular(AppRadius.r8),
                ),
                child: Row(
                  children: [
                    const Icon(
                      Icons.calendar_today_outlined,
                      size: AppSize.s18,
                      color: ColorManager.grey500,
                    ),
                    const SizedBox(width: AppSize.s10),
                    Text(
                      '${_dueDate.day}/${_dueDate.month}/${_dueDate.year}',
                      style: AppTextStyles.bodyMedium,
                    ),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(height: AppSize.s24),
          SizedBox(
            width: double.infinity,
            height: AppSize.s48,
            child: FilledButton(
              onPressed: _saveInvoice,
              child: Text(StringsManager.dataMgmtSaveInvoice.tr()),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRecordPaymentTab() {
    final dueInvoices = CenterlyMockData.invoices
        .where((i) => i.status == InvoiceStatus.due)
        .toList();

    if (dueInvoices.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(AppPadding.p24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.check_circle_outline,
                size: AppSize.s64,
                color: ColorManager.success,
              ),
              const SizedBox(height: AppSize.s16),
              Text(
                StringsManager.dataMgmtNoDueInvoices.tr(),
                style: AppTextStyles.titleMedium,
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      );
    }

    return Form(
      key: _paymentFormKey,
      child: ListView(
        padding: const EdgeInsets.all(AppPadding.p16),
        children: [
          _FormFieldCard(
            label: StringsManager.dataMgmtSelectInvoice.tr(),
            child: DropdownButtonFormField<String>(
              initialValue: _selectedInvoiceId,
              decoration: InputDecoration(
                fillColor: ColorManager.grey200,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(AppRadius.r8),
                  borderSide: BorderSide.none,
                ),
              ),
              items: dueInvoices.map((inv) {
                final student = CenterlyMockData.studentById(inv.studentId);
                return DropdownMenuItem<String>(
                  value: inv.id,
                  child: Text(
                    '${student.name} - ${inv.invoiceNumber} (${inv.amount.toStringAsFixed(0)} جنيه)',
                  ),
                );
              }).toList(),
              onChanged: (val) {
                if (val != null) {
                  setState(() {
                    _selectedInvoiceId = val;
                    final selected = dueInvoices.firstWhere((i) => i.id == val);
                    _paymentAmountController.text =
                        (selected.amount - selected.paidAmount).toStringAsFixed(
                          0,
                        );
                  });
                }
              },
            ),
          ),
          const SizedBox(height: AppSize.s14),
          _FormFieldCard(
            label: StringsManager.dataMgmtPaymentAmount.tr(),
            child: TextFormField(
              controller: _paymentAmountController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                fillColor: ColorManager.grey200,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(AppRadius.r8),
                  borderSide: BorderSide.none,
                ),
              ),
              validator: (val) => val == null || val.trim().isEmpty
                  ? StringsManager.validationRequired.tr()
                  : null,
            ),
          ),
          const SizedBox(height: AppSize.s24),
          SizedBox(
            width: double.infinity,
            height: AppSize.s48,
            child: FilledButton(
              onPressed: _savePayment,
              child: Text(StringsManager.dataMgmtSavePayment.tr()),
            ),
          ),
        ],
      ),
    );
  }
}

class _FormFieldCard extends StatelessWidget {
  const _FormFieldCard({required this.label, required this.child});

  final String label;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppPadding.p14),
      decoration: BoxDecoration(
        color: ColorManager.surface,
        borderRadius: BorderRadius.circular(AppRadius.r12),
        border: Border.all(color: ColorManager.divider),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: AppTextStyles.titleSmall),
          const SizedBox(height: AppSize.s8),
          child,
        ],
      ),
    );
  }
}
