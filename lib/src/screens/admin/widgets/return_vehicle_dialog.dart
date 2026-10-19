import 'package:flutter/material.dart';
import '../../../../models.dart';
import '../../../../store.dart';
import '../../../shared/app_colors.dart';
import '../../../shared/smart_image.dart';
import '../../../localization/app_language.dart';

class ReturnVehicleDialog extends StatefulWidget {
  final RentalStore store;
  final Rental rental;
  final VoidCallback onUpdated;

  const ReturnVehicleDialog({
    super.key,
    required this.store,
    required this.rental,
    required this.onUpdated,
  });

  @override
  State<ReturnVehicleDialog> createState() => _ReturnVehicleDialogState();
}

class _ReturnVehicleDialogState extends State<ReturnVehicleDialog> {
  late TextEditingController _notesController;
  late TextEditingController _paymentController;
  String _paymentMethod = 'ABA KHQR';
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    _notesController = TextEditingController();
    final balance = widget.rental.balanceCents;
    _paymentController = TextEditingController(
      text: balance > 0 ? (balance / 100).toStringAsFixed(2) : '',
    );
  }

  @override
  void dispose() {
    _notesController.dispose();
    _paymentController.dispose();
    super.dispose();
  }

  String _t(String key) => widget.store.t(key);

  String _money(int cents) => '\$${(cents / 100).toStringAsFixed(2)}';

  String _date(DateTime d) =>
      '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';

  int _parseCents(String text) {
    final clean = text.replaceAll(RegExp(r'[^0-9.]'), '');
    final val = double.tryParse(clean);
    if (val == null) return 0;
    return (val * 100).round();
  }

  Future<void> _handleSettleAndReturn() async {
    if (_isSubmitting) return;
    setState(() => _isSubmitting = true);

    try {
      final r = widget.rental;
      final payCents = _parseCents(_paymentController.text);
      final finalPayCents = payCents > 0 ? payCents : r.balanceCents;

      final noteParts = <String>[];
      if (finalPayCents > 0) {
        noteParts.add(
            '[Payment Settlement: ${_money(finalPayCents)} via $_paymentMethod on ${_date(DateTime.now())}]');
      }
      final enteredNotes = _notesController.text.trim();
      if (enteredNotes.isNotEmpty) {
        noteParts.add(enteredNotes);
      }
      final auditNote = noteParts.join(' • ');

      // 1. Settle or record payment
      if (finalPayCents >= r.balanceCents) {
        await widget.store.settleRentalPayment(r.id, notes: auditNote);
      } else if (finalPayCents > 0) {
        await widget.store.recordRentalPayment(r.id, finalPayCents, notes: auditNote);
      }

      // 2. Return vehicle to inventory
      await widget.store.returnRentalVehicle(
        r.id,
        notes: '[Return Check-In Complete: Vehicle verified & returned to active fleet on ${_date(DateTime.now())}]',
      );

      widget.onUpdated();

      if (mounted) {
        Navigator.pop(context, true);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            backgroundColor: AppColors.brandEmerald,
            content: Row(
              children: [
                const Icon(Icons.check_circle_rounded, color: Colors.white, size: 20),
                const SizedBox(width: 10),
                Expanded(child: Text(_t('full_payment_collected'))),
              ],
            ),
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  Future<void> _handleReturnWithDebt() async {
    if (_isSubmitting) return;
    setState(() => _isSubmitting = true);

    try {
      final r = widget.rental;
      final now = DateTime.now();
      final enteredNotes = _notesController.text.trim();

      final debtNote = '[Return Audit: Car returned to inventory with outstanding unpaid balance of ${_money(r.balanceCents)} on ${_date(now)}' +
          (enteredNotes.isNotEmpty ? ' • Notes: $enteredNotes' : '') +
          ']';

      await widget.store.returnRentalVehicle(r.id, notes: debtNote);

      widget.onUpdated();

      if (mounted) {
        Navigator.pop(context, true);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            backgroundColor: const Color(0xFFD97706),
            content: Row(
              children: [
                const Icon(Icons.warning_amber_rounded, color: Colors.white, size: 20),
                const SizedBox(width: 10),
                Expanded(child: Text(_t('returned_unpaid_success'))),
              ],
            ),
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  Future<void> _handleCleanReturn() async {
    if (_isSubmitting) return;
    setState(() => _isSubmitting = true);

    try {
      final r = widget.rental;
      final enteredNotes = _notesController.text.trim();
      final returnNote = enteredNotes.isNotEmpty
          ? '[Return Check-in: $enteredNotes on ${_date(DateTime.now())}]'
          : '[Return Check-in: Vehicle returned in good order on ${_date(DateTime.now())}]';

      await widget.store.returnRentalVehicle(r.id, notes: returnNote);

      widget.onUpdated();

      if (mounted) {
        Navigator.pop(context, true);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            backgroundColor: AppColors.brandEmerald,
            content: Row(
              children: [
                const Icon(Icons.check_circle_rounded, color: Colors.white, size: 20),
                const SizedBox(width: 10),
                Expanded(child: Text(_t('vehicle_checkin_complete'))),
              ],
            ),
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final r = widget.rental;
    final v = widget.store.vehicle(r.vehicleId);
    final c = widget.store.customer(r.customerId);
    final isKhmer = widget.store.language == AppLanguage.khmer;

    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final endDate = DateTime(r.end.year, r.end.month, r.end.day);
    final isOverdue = today.isAfter(endDate);
    final overdueDays = isOverdue ? today.difference(endDate).inDays : 0;
    final hasUnpaidBalance = r.balanceCents > 0;

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      backgroundColor: Colors.white,
      clipBehavior: Clip.antiAlias,
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 580),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Header
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                decoration: const BoxDecoration(
                  color: Color(0xFF0F172A),
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.white.withAlpha(20),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.assignment_turned_in_rounded,
                          color: Colors.white, size: 22),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            _t('return_vehicle_title'),
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 17,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            'Booking: ${r.id} • ${v.name}',
                            style: TextStyle(
                              color: Colors.white.withAlpha(180),
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close, color: Colors.white70, size: 20),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ],
                ),
              ),

              Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Vehicle & Customer Brief
                    Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF8FAFC),
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: const Color(0xFFE2E8F0)),
                      ),
                      child: Row(
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(10),
                            child: Container(
                              width: 72,
                              height: 52,
                              color: const Color(0xFFE2E8F0),
                              child: SmartImage(
                                imageSource: v.imageUrl,
                                fit: BoxFit.cover,
                                fallback: const Center(
                                  child: Icon(Icons.directions_car_filled_rounded,
                                      size: 24, color: Color(0xFF0F172A)),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  v.name,
                                  style: const TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.w800,
                                    color: Color(0xFF0F172A),
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  '${v.brand.toUpperCase()} • ${v.plate} • ${_money(v.dailyCents)}/${_t('day')}',
                                  style: const TextStyle(
                                    fontSize: 12,
                                    color: Color(0xFF64748B),
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Row(
                                  children: [
                                    const Icon(Icons.person_outline_rounded,
                                        size: 14, color: Color(0xFF475569)),
                                    const SizedBox(width: 4),
                                    Text(
                                      '${c.name} (${c.phone})',
                                      style: const TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.w600,
                                        color: Color(0xFF334155),
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
                    const SizedBox(height: 14),

                    // Overdue Alert Banner (if expired due)
                    if (isOverdue) ...[
                      Container(
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: const Color(0xFFFEF2F2),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: const Color(0xFFFCA5A5)),
                        ),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Icon(Icons.warning_amber_rounded,
                                color: Color(0xFFDC2626), size: 24),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    _t('rental_overdue_warning'),
                                    style: const TextStyle(
                                      fontSize: 13,
                                      fontWeight: FontWeight.w800,
                                      color: Color(0xFF991B1B),
                                    ),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    '${_t('overdue_days_count')} $overdueDays ${_t('days_unit')} (${_date(r.start)} → ${_date(r.end)}). ' +
                                        (isKhmer
                                            ? 'កាលបរិច្ឆេទសន្យាបានផុតកំណត់។ សូមត្រួតពិនិត្យ និងកត់ត្រាការប្រគល់រថយន្ត។'
                                            : 'The agreed return date has passed. Check vehicle condition and resolve any due charges.'),
                                    style: const TextStyle(
                                      fontSize: 12,
                                      color: Color(0xFFB91C1C),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 14),
                    ],

                    // Financial Summary Card
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: hasUnpaidBalance
                            ? const Color(0xFFFFFBEB)
                            : const Color(0xFFF0FDF4),
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(
                          color: hasUnpaidBalance
                              ? const Color(0xFFFDE68A)
                              : const Color(0xFFBBF7D0),
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(
                                hasUnpaidBalance
                                    ? Icons.account_balance_wallet_outlined
                                    : Icons.verified_outlined,
                                size: 18,
                                color: hasUnpaidBalance
                                    ? const Color(0xFFD97706)
                                    : AppColors.brandEmerald,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                _t('financial_summary'),
                                style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.bold,
                                  color: hasUnpaidBalance
                                      ? const Color(0xFF92400E)
                                      : const Color(0xFF166534),
                                ),
                              ),
                              const Spacer(),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 8, vertical: 3),
                                decoration: BoxDecoration(
                                  color: hasUnpaidBalance
                                      ? const Color(0xFFF59E0B)
                                      : AppColors.brandEmerald,
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: Text(
                                  hasUnpaidBalance
                                      ? (isKhmer ? 'នៅសល់ប្រាក់ជំពាក់' : 'UNPAID DUE')
                                      : (isKhmer ? 'បានទូទាត់ពេញ' : 'FULLY PAID'),
                                  style: const TextStyle(
                                    fontSize: 10,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              _buildMetricItem(_t('total'), _money(r.totalCents),
                                  const Color(0xFF0F172A)),
                              _buildMetricItem(_t('paid_deposit'),
                                  _money(r.paidCents), AppColors.brandEmerald),
                              _buildMetricItem(
                                _t('remaining_balance'),
                                _money(r.balanceCents),
                                hasUnpaidBalance
                                    ? const Color(0xFFDC2626)
                                    : AppColors.brandEmerald,
                                isBold: true,
                              ),
                            ],
                          ),
                          if (hasUnpaidBalance) ...[
                            const SizedBox(height: 12),
                            const Divider(color: Color(0xFFFDE68A), height: 1),
                            const SizedBox(height: 10),
                            Text(
                              _t('unpaid_debt_notice'),
                              style: const TextStyle(
                                fontSize: 11,
                                color: Color(0xFF92400E),
                                height: 1.4,
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                    const SizedBox(height: 14),

                    // If Unpaid Balance: Payment Settlement Form
                    if (hasUnpaidBalance) ...[
                      Text(
                        _t('payment_method'),
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF334155),
                        ),
                      ),
                      const SizedBox(height: 6),
                      Wrap(
                        spacing: 8,
                        children: [
                          _buildMethodChoiceChip('ABA KHQR', Icons.qr_code_2_rounded),
                          _buildMethodChoiceChip('Cash', Icons.payments_outlined),
                          _buildMethodChoiceChip('Card', Icons.credit_card_outlined),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Expanded(
                            child: TextField(
                              controller: _paymentController,
                              keyboardType: const TextInputType.numberWithOptions(decimal: true),
                              decoration: InputDecoration(
                                labelText: _t('payment_amount'),
                                prefixIcon: const Icon(Icons.attach_money_rounded, size: 18),
                                isDense: true,
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          OutlinedButton(
                            style: OutlinedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10)),
                            ),
                            onPressed: () {
                              _paymentController.text = (r.balanceCents / 100).toStringAsFixed(2);
                            },
                            child: Text(
                              isKhmer ? 'បង់ពេញ' : 'Full Balance',
                              style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 14),
                    ],

                    // Return Notes & Inspection
                    Text(
                      _t('return_notes'),
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF334155),
                      ),
                    ),
                    const SizedBox(height: 6),
                    TextField(
                      controller: _notesController,
                      maxLines: 2,
                      decoration: InputDecoration(
                        hintText: _t('return_notes_hint'),
                        hintStyle: const TextStyle(fontSize: 12, color: Color(0xFF94A3B8)),
                        isDense: true,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Action Buttons Area
                    if (hasUnpaidBalance) ...[
                      // Option A: Settle Balance & Return
                      FilledButton.icon(
                        style: FilledButton.styleFrom(
                          backgroundColor: AppColors.brandEmerald,
                          padding: const EdgeInsets.symmetric(vertical: 13),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10)),
                        ),
                        onPressed: _isSubmitting ? null : _handleSettleAndReturn,
                        icon: const Icon(Icons.check_circle_outline_rounded, size: 18),
                        label: Text(
                          _t('settle_and_return'),
                          style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold),
                        ),
                      ),
                      const SizedBox(height: 8),

                      // Option B: Return with Pending Debt
                      OutlinedButton.icon(
                        style: OutlinedButton.styleFrom(
                          foregroundColor: const Color(0xFFD97706),
                          side: const BorderSide(color: Color(0xFFF59E0B)),
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10)),
                        ),
                        onPressed: _isSubmitting ? null : _handleReturnWithDebt,
                        icon: const Icon(Icons.archive_outlined, size: 18),
                        label: Text(
                          _t('return_with_debt'),
                          style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ] else ...[
                      // Clean Return (No unpaid debt)
                      FilledButton.icon(
                        style: FilledButton.styleFrom(
                          backgroundColor: AppColors.brandEmerald,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10)),
                        ),
                        onPressed: _isSubmitting ? null : _handleCleanReturn,
                        icon: const Icon(Icons.check_circle_rounded, size: 18),
                        label: Text(
                          _t('return_vehicle'),
                          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ],

                    const SizedBox(height: 6),
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: Text(
                        _t('cancel'),
                        style: const TextStyle(
                          fontSize: 12,
                          color: Color(0xFF64748B),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMethodChoiceChip(String name, IconData icon) {
    final isSelected = _paymentMethod == name;
    return ChoiceChip(
      avatar: Icon(icon, size: 15, color: isSelected ? Colors.white : const Color(0xFF475569)),
      label: Text(name),
      labelStyle: TextStyle(
        fontSize: 11,
        fontWeight: FontWeight.bold,
        color: isSelected ? Colors.white : const Color(0xFF334155),
      ),
      selected: isSelected,
      selectedColor: const Color(0xFF0F172A),
      backgroundColor: const Color(0xFFF1F5F9),
      onSelected: (val) {
        if (val) setState(() => _paymentMethod = name);
      },
    );
  }

  Widget _buildMetricItem(String label, String value, Color color,
      {bool isBold = false}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(fontSize: 11, color: Color(0xFF64748B)),
        ),
        const SizedBox(height: 2),
        Text(
          value,
          style: TextStyle(
            fontSize: 14,
            fontWeight: isBold ? FontWeight.w900 : FontWeight.bold,
            color: color,
          ),
        ),
      ],
    );
  }
}

