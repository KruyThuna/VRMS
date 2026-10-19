import 'package:flutter/material.dart';
import '../../../../models.dart';
import '../../../../store.dart';
import '../../../shared/app_colors.dart';
import '../../../shared/smart_image.dart';
import '../../../localization/app_language.dart';

class PaymentFormDialog extends StatefulWidget {
  final RentalStore store;
  final Rental? preselectedRental;
  final bool isEdit;
  final VoidCallback onSaved;

  const PaymentFormDialog({
    super.key,
    required this.store,
    this.preselectedRental,
    this.isEdit = false,
    required this.onSaved,
  });

  @override
  State<PaymentFormDialog> createState() => _PaymentFormDialogState();
}

class _PaymentFormDialogState extends State<PaymentFormDialog> {
  final _formKey = GlobalKey<FormState>();
  late String _selectedRentalId;
  late final TextEditingController _amountController;
  late final TextEditingController _notesController;
  late final TextEditingController _refController;
  String _selectedMethod = 'ABA KHQR';
  DateTime _paymentDate = DateTime.now();

  RentalStore get store => widget.store;
  bool get isKhmer => store.language == AppLanguage.khmer;

  final List<String> _methods = [
    'ABA KHQR',
    'Cash',
    'Credit Card',
    'Wing Bank',
    'Bank Transfer',
  ];

  @override
  void initState() {
    super.initState();
    final defaultRental = widget.preselectedRental ??
        (store.rentals.isNotEmpty ? store.rentals.first : null);
    _selectedRentalId = defaultRental?.id ?? '';

    final initialAmount = widget.isEdit
        ? (defaultRental != null ? (defaultRental.paidCents / 100).toStringAsFixed(2) : '0.00')
        : (defaultRental != null && defaultRental.balanceCents > 0
            ? (defaultRental.balanceCents / 100).toStringAsFixed(2)
            : '0.00');

    _amountController = TextEditingController(text: initialAmount);
    _refController = TextEditingController(
      text: 'PAY-${DateTime.now().millisecondsSinceEpoch.toString().substring(7)}',
    );
    _notesController = TextEditingController(text: defaultRental?.notes ?? '');
  }

  @override
  void dispose() {
    _amountController.dispose();
    _refController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  Rental? get currentRental {
    try {
      return store.rentals.firstWhere((r) => r.id == _selectedRentalId);
    } catch (_) {
      return null;
    }
  }

  void _onRentalChanged(String? newId) {
    if (newId == null || newId == _selectedRentalId) return;
    setState(() {
      _selectedRentalId = newId;
      final r = currentRental;
      if (r != null) {
        if (widget.isEdit) {
          _amountController.text = (r.paidCents / 100).toStringAsFixed(2);
        } else {
          _amountController.text = (r.balanceCents > 0
              ? (r.balanceCents / 100).toStringAsFixed(2)
              : '0.00');
        }
      }
    });
  }

  void _applyQuickFill(double ratio) {
    final r = currentRental;
    if (r == null) return;
    final targetCents = (r.balanceCents * ratio).round();
    setState(() {
      _amountController.text = (targetCents / 100).toStringAsFixed(2);
    });
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    final r = currentRental;
    if (r == null) return;

    final enteredAmount = double.tryParse(_amountController.text.trim()) ?? 0.0;
    final enteredCents = (enteredAmount * 100).round();

    final dateStr = '${_paymentDate.year}-${_paymentDate.month.toString().padLeft(2, '0')}-${_paymentDate.day.toString().padLeft(2, '0')}';
    final noteText = [
      'Date: $dateStr',
      if (_refController.text.trim().isNotEmpty) 'Ref: ${_refController.text.trim()}',
      'Method: $_selectedMethod',
      if (_notesController.text.trim().isNotEmpty) _notesController.text.trim(),
    ].join(' • ');

    if (widget.isEdit) {
      await store.updateRentalPayment(
        r.id,
        enteredCents,
        notes: noteText,
      );
    } else {
      await store.recordRentalPayment(
        r.id,
        enteredCents,
        notes: noteText,
      );
    }

    widget.onSaved();
    if (mounted) Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final r = currentRental;
    final vehicle = r != null ? store.vehicle(r.vehicleId) : null;
    final customer = r != null ? store.customer(r.customerId) : null;

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      backgroundColor: Colors.white,
      insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 580, maxHeight: 780),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Header
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: AppColors.brandEmerald.withAlpha(25),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(
                        Icons.payments_rounded,
                        color: AppColors.brandEmerald,
                        size: 24,
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            widget.isEdit
                                ? (isKhmer ? 'កែសម្រួលការទូទាត់' : 'Edit Payment Record')
                                : (isKhmer ? 'កត់ត្រាការបង់ប្រាក់' : 'Record Rental Payment'),
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w900,
                              color: Color(0xFF0F172A),
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            isKhmer
                                ? 'បញ្ចូលព័ត៌មានបង្កាន់ដៃ និងសមតុល្យប្រាក់ដុល្លារ (USD)'
                                : 'Record deposit, settle balance, and track payment method',
                            style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close_rounded),
                      onPressed: () => Navigator.of(context).pop(),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                const Divider(height: 1),
                const SizedBox(height: 16),

                // Form Scrollable Body
                Expanded(
                  child: SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        // Booking Selection Dropdown
                        Text(
                          isKhmer ? 'ជ្រើសរើសកិច្ចសន្យា / ការកក់' : 'Select Rental Contract',
                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                        ),
                        const SizedBox(height: 6),
                        DropdownButtonFormField<String>(
                          initialValue: _selectedRentalId.isNotEmpty ? _selectedRentalId : null,
                          isExpanded: true,
                          decoration: InputDecoration(
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                            contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                            prefixIcon: const Icon(Icons.receipt_long_rounded, size: 20),
                          ),
                          items: store.rentals.map((item) {
                            final c = store.customer(item.customerId);
                            final v = store.vehicle(item.vehicleId);
                            final balanceStr = '\$${(item.balanceCents / 100).toStringAsFixed(2)}';
                            return DropdownMenuItem<String>(
                              value: item.id,
                              child: Text(
                                '${c.name} • ${item.id} (${v.name}) • Due: $balanceStr',
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(fontSize: 13),
                              ),
                            );
                          }).toList(),
                          onChanged: widget.isEdit ? null : _onRentalChanged,
                        ),
                        const SizedBox(height: 14),

                        // Selected Rental & Vehicle Card Preview
                        if (r != null && vehicle != null && customer != null) ...[
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: const Color(0xFFF8FAFC),
                              borderRadius: BorderRadius.circular(14),
                              border: Border.all(color: const Color(0xFFE2E8F0)),
                            ),
                            child: Row(
                              children: [
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(10),
                                  child: SizedBox(
                                    width: 72,
                                    height: 50,
                                    child: SmartImage(
                                      imageSource: vehicle.imageUrl,
                                      fit: BoxFit.cover,
                                      fallback: Container(
                                        color: Colors.grey.shade200,
                                        child: const Icon(Icons.directions_car_rounded, color: Colors.grey),
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        '${vehicle.brand} ${vehicle.name}',
                                        style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 14,
                                          color: Color(0xFF0F172A),
                                        ),
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                      const SizedBox(height: 2),
                                      Text(
                                        '${customer.name} • ${customer.phone}',
                                        style: TextStyle(fontSize: 12, color: Colors.grey.shade700),
                                      ),
                                      const SizedBox(height: 4),
                                      Wrap(
                                        spacing: 8,
                                        runSpacing: 4,
                                        children: [
                                          Text(
                                            'Total: \$${(r.totalCents / 100).toStringAsFixed(2)}',
                                            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
                                          ),
                                          Text(
                                            'Paid: \$${(r.paidCents / 100).toStringAsFixed(2)}',
                                            style: const TextStyle(
                                              fontSize: 12,
                                              color: AppColors.brandEmerald,
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                          Text(
                                            'Due: \$${(r.balanceCents / 100).toStringAsFixed(2)}',
                                            style: TextStyle(
                                              fontSize: 12,
                                              color: r.balanceCents > 0 ? AppColors.brandRed : Colors.grey,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 16),
                        ],

                        // Quick Presets
                        if (!widget.isEdit && r != null && r.balanceCents > 0) ...[
                          Row(
                            children: [
                              Text(
                                isKhmer ? 'ជម្រើសបង់រហ័ស:' : 'Quick Presets:',
                                style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                              ),
                              const SizedBox(width: 8),
                              ActionChip(
                                label: Text(isKhmer ? 'បង់ទាំងអស់ (100%)' : 'Full Balance'),
                                onPressed: () => _applyQuickFill(1.0),
                                backgroundColor: AppColors.brandEmerald.withAlpha(25),
                                labelStyle: const TextStyle(
                                  fontSize: 11,
                                  color: AppColors.brandEmerald,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(width: 6),
                              ActionChip(
                                label: Text(isKhmer ? 'បង់ពាក់កណ្តាល (50%)' : '50% Balance'),
                                onPressed: () => _applyQuickFill(0.5),
                                backgroundColor: Colors.grey.shade100,
                                labelStyle: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600),
                              ),
                            ],
                          ),
                          const SizedBox(height: 14),
                        ],

                        // Amount Field
                        Text(
                          widget.isEdit
                              ? (isKhmer ? 'ចំនួនទឹកប្រាក់បង់សរុបថ្មី (\$)' : 'Total Paid Amount (\$)')
                              : (isKhmer ? 'ចំនួនទឹកប្រាក់បង់ (\$)' : 'Amount to Pay (\$)'),
                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                        ),
                        const SizedBox(height: 6),
                        TextFormField(
                          controller: _amountController,
                          keyboardType: const TextInputType.numberWithOptions(decimal: true),
                          decoration: InputDecoration(
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                            prefixIcon: const Icon(Icons.attach_money_rounded),
                            hintText: '0.00',
                          ),
                          validator: (val) {
                            if (val == null || val.trim().isEmpty) {
                              return isKhmer ? 'សូមបញ្ចូលចំនួនទឹកប្រាក់' : 'Please enter payment amount';
                            }
                            final num = double.tryParse(val.trim());
                            if (num == null || num < 0) {
                              return isKhmer ? 'ចំនួនទឹកប្រាក់មិនត្រឹមត្រូវ' : 'Invalid amount';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 16),

                        // Payment Method Selector
                        Text(
                          isKhmer ? 'វិធីសាស្ត្រទូទាត់' : 'Payment Method',
                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                        ),
                        const SizedBox(height: 8),
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: _methods.map((method) {
                            final isSelected = _selectedMethod == method;
                            return ChoiceChip(
                              label: Text(method),
                              selected: isSelected,
                              onSelected: (selected) {
                                if (selected) setState(() => _selectedMethod = method);
                              },
                              selectedColor: AppColors.brandEmerald.withAlpha(35),
                              labelStyle: TextStyle(
                                fontSize: 12,
                                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                                color: isSelected ? AppColors.brandEmerald : Colors.grey.shade800,
                              ),
                            );
                          }).toList(),
                        ),
                        // Payment Date
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              isKhmer ? 'កាលបរិច្ឆេទបង់ប្រាក់' : 'Payment Date',
                              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                            ),
                            TextButton.icon(
                              onPressed: () async {
                                final picked = await showDatePicker(
                                  context: context,
                                  initialDate: _paymentDate,
                                  firstDate: DateTime(2020),
                                  lastDate: DateTime(2030),
                                );
                                if (picked != null) {
                                  setState(() => _paymentDate = picked);
                                }
                              },
                              icon: const Icon(Icons.calendar_month_rounded, size: 16),
                              label: Text(
                                '${_paymentDate.year}-${_paymentDate.month.toString().padLeft(2, '0')}-${_paymentDate.day.toString().padLeft(2, '0')}',
                                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),

                        // Reference Number
                        Text(
                          isKhmer ? 'លេខយោងវិក្កយបត្រ / ប្រតិបត្តិការ' : 'Receipt / Transaction Ref #',
                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                        ),
                        const SizedBox(height: 6),
                        TextFormField(
                          controller: _refController,
                          decoration: InputDecoration(
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                            prefixIcon: const Icon(Icons.tag_rounded, size: 20),
                            hintText: 'e.g. ABA-TXN-99812',
                          ),
                        ),
                        const SizedBox(height: 16),

                        // Notes & Remarks
                        Text(
                          isKhmer ? 'កំណត់សម្គាល់បន្ថែម' : 'Payment Notes / Remarks',
                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                        ),
                        const SizedBox(height: 6),
                        TextFormField(
                          controller: _notesController,
                          maxLines: 2,
                          decoration: InputDecoration(
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                            hintText: isKhmer ? 'កំណត់សម្គាល់ការទូទាត់...' : 'Optional payment remarks...',
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // Action Buttons
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    OutlinedButton(
                      onPressed: () => Navigator.of(context).pop(),
                      style: OutlinedButton.styleFrom(
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                      ),
                      child: Text(isKhmer ? 'បោះបង់' : 'Cancel'),
                    ),
                    const SizedBox(width: 12),
                    FilledButton.icon(
                      onPressed: _submit,
                      icon: const Icon(Icons.check_circle_rounded, size: 18),
                      label: Text(
                        widget.isEdit
                            ? (isKhmer ? 'រក្សាទុកការកែប្រែ' : 'Save Changes')
                            : (isKhmer ? 'កត់ត្រាការបង់ប្រាក់' : 'Confirm Payment'),
                      ),
                      style: FilledButton.styleFrom(
                        backgroundColor: AppColors.brandEmerald,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 12),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
