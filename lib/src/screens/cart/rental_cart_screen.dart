import 'dart:math';
import 'package:flutter/material.dart';
import '../../models/vehicle.dart';
import '../../models/customer.dart';
import '../../models/rental.dart';
import '../../models/formatters.dart';
import '../../../store.dart';
import '../../shared/app_colors.dart';
import '../../shared/smart_image.dart';
import '../../shared/vehicle_art.dart';
import '../../localization/app_translations.dart';
import '../../localization/app_language.dart';
import '../../localization/language_selector_widget.dart';
import '../storefront/widgets/professional_booking_date_dialog.dart';

/// Professional, responsive horizontal Reservation Cart & Checkout Screen.
/// In desktop & tablet landscape (>= 880px), displays a 2-column layout:
/// - Left: Rental Dates & Stepper, Vehicle Line-Items, Promo Code Box.
/// - Right: Order Cost Breakdown, Renter Details Form, Confirm Reservation CTA.
class RentalCart extends StatefulWidget {
  final RentalStore store;
  final List<Vehicle> items;
  final DateTime from;
  final DateTime to;
  final void Function(String id) onRemove;
  final VoidCallback onComplete;

  const RentalCart({
    super.key,
    required this.store,
    required this.items,
    required this.from,
    required this.to,
    required this.onRemove,
    required this.onComplete,
  });

  @override
  State<RentalCart> createState() => _RentalCartState();
}

enum PaymentTerm { full, deposit, onArrival }
enum PaymentMethod { khqr, card }

class _RentalCartState extends State<RentalCart> {
  final _name = TextEditingController();
  final _phone = TextEditingController();
  final _email = TextEditingController();
  final _notes = TextEditingController();
  final _voucherController = TextEditingController();
  final _cardNumberController = TextEditingController(text: '4532 8821 9912 8892');
  final _cardExpiryController = TextEditingController(text: '08/28');
  final _cardCvvController = TextEditingController(text: '889');

  PaymentTerm _paymentTerm = PaymentTerm.full;
  PaymentMethod _paymentMethod = PaymentMethod.khqr;

  int _lastAmountPaidCents = 0;
  int _lastRemainingBalanceCents = 0;
  PaymentTerm _lastPaymentTerm = PaymentTerm.full;
  PaymentMethod _lastPaymentMethod = PaymentMethod.khqr;
  String _lastBookingRef = '';

  bool _busy = false;
  String? _error;
  List<String>? _confirmed;
  String? _appliedVoucher;
  int _voucherDiscountCents = 0;
  late int _customDays;
  late DateTime _effectiveFrom;
  String? _selectedCustomerId;

  @override
  void initState() {
    super.initState();
    _effectiveFrom = widget.from;
    _customDays = DateTime.utc(widget.to.year, widget.to.month, widget.to.day)
            .difference(DateTime.utc(widget.from.year, widget.from.month, widget.from.day))
            .inDays +
        1;
    if (_customDays < 1) _customDays = 1;
  }

  Future<void> _pickCartDates() async {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final currentEnd = _effectiveFrom.add(Duration(days: _customDays - 1));
    final range = await showProfessionalBookingDatePicker(
      context: context,
      initialStart: _effectiveFrom.isBefore(today) ? today : _effectiveFrom,
      initialEnd: currentEnd.isBefore(today) ? today.add(const Duration(days: 2)) : currentEnd,
      firstDate: today,
      language: widget.store.language,
    );
    if (range != null && mounted) {
      final days = range.end.difference(range.start).inDays + 1;
      setState(() {
        _effectiveFrom = range.start;
        _customDays = days > 0 ? days : 1;
      });
    }
  }

  @override
  void dispose() {
    _name.dispose();
    _phone.dispose();
    _email.dispose();
    _notes.dispose();
    _voucherController.dispose();
    _cardNumberController.dispose();
    _cardExpiryController.dispose();
    _cardCvvController.dispose();
    super.dispose();
  }

  String _t(String key) => AppTranslations.tr(key, widget.store.language);

  void _applyVoucher() {
    final code = _voucherController.text.trim().toUpperCase();
    if (code.isEmpty) return;

    final rawSubtotal = widget.items.fold<int>(0, (sum, v) => sum + v.dailyCents * _customDays);

    setState(() {
      if (code == 'VIP10') {
        _appliedVoucher = 'VIP10 (10% OFF)';
        _voucherDiscountCents = (rawSubtotal * 0.10).round();
        _error = null;
      } else if (code == 'TIGGO9') {
        _appliedVoucher = 'TIGGO9 (\$50 OFF)';
        _voucherDiscountCents = min(rawSubtotal, 5000);
        _error = null;
      } else if (code == 'DRIVELINE') {
        _appliedVoucher = 'DRIVELINE (\$30 OFF)';
        _voucherDiscountCents = min(rawSubtotal, 3000);
        _error = null;
      } else if (code == 'WELCOME') {
        _appliedVoucher = 'WELCOME (\$20 OFF)';
        _voucherDiscountCents = min(rawSubtotal, 2000);
        _error = null;
      } else {
        _error = widget.store.language == AppLanguage.khmer
            ? 'កូដបញ្ចុះតម្លៃមិនត្រឹមត្រូវ។ សាកល្បង "VIP10", "TIGGO9", ឬ "DRIVELINE"។'
            : 'Invalid voucher code. Try "VIP10", "TIGGO9", or "DRIVELINE".';
        _appliedVoucher = null;
        _voucherDiscountCents = 0;
      }
    });
  }

  void _removeVoucher() {
    setState(() {
      _appliedVoucher = null;
      _voucherDiscountCents = 0;
      _voucherController.clear();
    });
  }

  Future<void> _checkout() async {
    if (_busy) return;
    if (_name.text.trim().isEmpty || _phone.text.trim().isEmpty) {
      setState(() => _error = widget.store.language == AppLanguage.khmer
          ? 'សូមបញ្ចូលឈ្មោះពេញ និងលេខទូរស័ព្ទរបស់អ្នក។'
          : 'Please enter your Full Name and Phone Number.');
      return;
    }

    final s = widget.store;
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    if (_effectiveFrom.isBefore(today)) {
      setState(() => _error = widget.store.language == AppLanguage.khmer
          ? 'កាលបរិច្ឆេទដែលបានជ្រើសរើសគឺកន្លងផុតទៅហើយ។'
          : 'Selected dates are in the past.');
      return;
    }
    final effectiveTo = _effectiveFrom.add(Duration(days: _customDays - 1));
    if (widget.items.any((v) => !s.available(v, _effectiveFrom, effectiveTo))) {
      setState(() => _error = widget.store.language == AppLanguage.khmer
          ? 'រថយន្តមិនទំនេរសម្រាប់កាលបរិច្ឆេទដែលបានជ្រើសរើសទេ។'
          : 'A vehicle is no longer available for selected dates.');
      return;
    }

    setState(() {
      _busy = true;
      _error = null;
    });

    Customer customer;
    final matchedCustomer = _selectedCustomerId != null
        ? s.customers.cast<Customer?>().firstWhere(
            (c) => c?.id == _selectedCustomerId,
            orElse: () => null,
          )
        : null;

    if (matchedCustomer != null && matchedCustomer.name.toLowerCase() == _name.text.trim().toLowerCase()) {
      customer = matchedCustomer;
    } else {
      customer = Customer(
        s.newId('C'),
        _name.text.trim(),
        _phone.text.trim(),
        email: _email.text.trim(),
      );
    }

    final rawSubtotal = widget.items.fold<int>(0, (sum, v) => sum + v.dailyCents * _customDays);
    final totalCents = max(0, rawSubtotal - _voucherDiscountCents);

    final int amountToPayCents;
    if (_paymentTerm == PaymentTerm.full) {
      amountToPayCents = totalCents;
    } else if (_paymentTerm == PaymentTerm.deposit) {
      amountToPayCents = (totalCents * 0.30).round();
    } else {
      amountToPayCents = 0;
    }
    final remainingBalanceCents = totalCents - amountToPayCents;

    final termLabel = _paymentTerm == PaymentTerm.full
        ? 'Pay in Full (100%)'
        : _paymentTerm == PaymentTerm.deposit
            ? '30% Deposit'
            : 'Pay at Pickup (Cash/Card)';

    final lastDigits = _cardNumberController.text.trim().replaceAll(' ', '');
    final maskedCard = lastDigits.length >= 4 ? lastDigits.substring(lastDigits.length - 4) : '8892';

    final methodLabel = _paymentTerm == PaymentTerm.onArrival
        ? 'Cash on Arrival'
        : _paymentMethod == PaymentMethod.khqr
            ? 'ABA / KHQR Mobile Banking'
            : 'Credit/Debit Card (ending $maskedCard)';

    final bookingRef = 'DL-RES-${Random().nextInt(900000) + 100000}';

    final bookings = <Rental>[];
    int allocatedPaid = 0;
    for (var i = 0; i < widget.items.length; i++) {
      final item = widget.items[i];
      final isLast = i == widget.items.length - 1;
      final itemShare = rawSubtotal == 0 ? 0.0 : (item.dailyCents * _customDays / rawSubtotal);
      final itemPaid = isLast
          ? (amountToPayCents - allocatedPaid)
          : (amountToPayCents * itemShare).round();
      allocatedPaid += itemPaid;

      bookings.add(
        Rental(
          '${s.newId('R')}-$i',
          item.id,
          customer.id,
          _effectiveFrom,
          effectiveTo,
          item.dailyCents,
          paidCents: itemPaid,
          notes: '${_notes.text.trim()} [Ref: $bookingRef] [Terms: $termLabel] [Method: $methodLabel]${_appliedVoucher != null ? ' [Voucher: $_appliedVoucher]' : ''}'.trim(),
        ),
      );
    }

    try {
      await s.commit(() {
        if (!s.customers.any((c) => c.id == customer.id)) {
          s.customers.add(customer);
        }
        s.rentals.addAll(bookings);
      });
      widget.onComplete();
      if (mounted) {
        setState(() {
          _lastAmountPaidCents = amountToPayCents;
          _lastRemainingBalanceCents = remainingBalanceCents;
          _lastPaymentTerm = _paymentTerm;
          _lastPaymentMethod = _paymentMethod;
          _lastBookingRef = bookingRef;
          _confirmed = bookings.map((r) => r.id).toList();
        });
      }
    } catch (_) {
      if (mounted) {
        setState(() => _error = widget.store.language == AppLanguage.khmer
            ? 'មិនអាចរក្សាទុកការកក់បានទេ។ សូមពិនិត្យការផ្ទុកទិន្នន័យ។'
            : 'Failed to save booking. Please check storage.');
      }
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final rawSubtotal = widget.items.fold<int>(0, (sum, v) => sum + v.dailyCents * _customDays);
    final totalCents = max(0, rawSubtotal - _voucherDiscountCents);
    final int amountToPayCents;
    if (_paymentTerm == PaymentTerm.full) {
      amountToPayCents = totalCents;
    } else if (_paymentTerm == PaymentTerm.deposit) {
      amountToPayCents = (totalCents * 0.30).round();
    } else {
      amountToPayCents = 0;
    }
    final remainingBalanceCents = totalCents - amountToPayCents;
    final screenWidth = MediaQuery.sizeOf(context).width;
    final isHorizontal = screenWidth >= 880;

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        foregroundColor: const Color(0xFF0F172A),
        surfaceTintColor: Colors.transparent,
        bottom: const PreferredSize(
          preferredSize: Size.fromHeight(1),
          child: Divider(color: Color(0xFFE2E8F0), height: 1),
        ),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(7),
              decoration: BoxDecoration(
                color: AppColors.brandRed.withAlpha(20),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(Icons.shopping_bag_outlined, color: AppColors.brandRed, size: 20),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    children: [
                      Text(
                        _t('cart'),
                        style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 16, color: Color(0xFF0F172A)),
                      ),
                      if (widget.items.isNotEmpty) ...[
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                            color: AppColors.brandRed,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            '${widget.items.length}',
                            style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold),
                          ),
                        ),
                      ],
                    ],
                  ),
                  Text(
                    widget.store.language == AppLanguage.khmer
                        ? '${widget.store.agencyConfig.companyName} • ការកក់ប្រកបដោយសុវត្ថិភាព'
                        : '${widget.store.agencyConfig.companyName} • Secure Reservation',
                    style: const TextStyle(fontSize: 11, color: Color(0xFF64748B), fontWeight: FontWeight.w500),
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 12),
            child: LanguageSelectorWidget(
              currentLanguage: widget.store.language,
              onLanguageChanged: (lang) => setState(() => widget.store.setLanguage(lang)),
            ),
          ),
        ],
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: BoxConstraints(maxWidth: isHorizontal ? 1160 : 720),
          child: _confirmed != null
              ? SingleChildScrollView(
                  padding: const EdgeInsets.all(24),
                  child: _buildConfirmationCard(totalCents, rawSubtotal),
                )
              : widget.items.isEmpty
                  ? Center(child: _buildEmptyCart())
                  : SingleChildScrollView(
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
                      child: isHorizontal
                          ? Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // Left Column: Schedule, Vehicles, Voucher
                                Expanded(
                                  flex: 6,
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.stretch,
                                    children: [
                                      _buildScheduleDurationCard(),
                                      const SizedBox(height: 18),
                                      _buildVehiclesListSection(),
                                      const SizedBox(height: 18),
                                      _buildVoucherCard(),
                                    ],
                                  ),
                                ),
                                const SizedBox(width: 24),
                                // Right Column: Summary, Renter Form, Payment Terms & Processing
                                Expanded(
                                  flex: 5,
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.stretch,
                                    children: [
                                      _buildSummaryCard(rawSubtotal, totalCents, amountToPayCents, remainingBalanceCents),
                                      const SizedBox(height: 18),
                                      _buildRenterDetailsCard(),
                                      const SizedBox(height: 18),
                                      _buildPaymentCard(totalCents, amountToPayCents, remainingBalanceCents),
                                    ],
                                  ),
                                ),
                              ],
                            )
                          : Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                _buildScheduleDurationCard(),
                                const SizedBox(height: 18),
                                _buildVehiclesListSection(),
                                const SizedBox(height: 18),
                                _buildVoucherCard(),
                                const SizedBox(height: 18),
                                _buildSummaryCard(rawSubtotal, totalCents, amountToPayCents, remainingBalanceCents),
                                const SizedBox(height: 18),
                                _buildRenterDetailsCard(),
                                const SizedBox(height: 18),
                                _buildPaymentCard(totalCents, amountToPayCents, remainingBalanceCents),
                              ],
                            ),
                    ),
        ),
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // 1. SCHEDULE & DURATION STEPPER CARD (PICKUP DATE & DUE DATE)
  // ---------------------------------------------------------------------------
  Widget _buildScheduleDurationCard() {
    final effectiveTo = _effectiveFrom.add(Duration(days: _customDays - 1));

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: [
          BoxShadow(color: Colors.black.withAlpha(6), blurRadius: 12, offset: const Offset(0, 3)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header row with Icon, Title, and "Calendar Picker" button
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: AppColors.brandRed.withAlpha(20),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Icon(Icons.date_range_rounded, color: AppColors.brandRed, size: 20),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            _t('select_dates'),
                            style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 16, color: Color(0xFF0F172A)),
                          ),
                          Text(
                            widget.store.language == AppLanguage.khmer
                                ? 'ជ្រើសរើសកាលបរិច្ឆេទទទួល និងកាលបរិច្ឆេទប្រគល់រថយន្ត'
                                : 'Select pickup date and vehicle return due date',
                            style: const TextStyle(fontSize: 11, color: Color(0xFF64748B), fontWeight: FontWeight.w500),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              OutlinedButton.icon(
                style: OutlinedButton.styleFrom(
                  foregroundColor: const Color(0xFF1D4ED8),
                  side: const BorderSide(color: Color(0xFFBFDBFE)),
                  backgroundColor: const Color(0xFFEFF6FF),
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                ),
                icon: const Icon(Icons.calendar_month_rounded, size: 16),
                label: Text(
                  widget.store.language == AppLanguage.khmer ? 'ប្រតិទិន' : 'Calendar',
                  style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                ),
                onPressed: _pickCartDates,
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Two-panel Date Selection Cards (Pickup Date & Due Date)
          LayoutBuilder(
            builder: (context, constraints) {
              final isNarrow = constraints.maxWidth < 460;
              final pickupCard = _buildDateCard(
                title: _t('pickup_date').toUpperCase(),
                date: _effectiveFrom,
                timeLabel: widget.store.language == AppLanguage.khmer
                    ? '០៩:០០ ព្រឹក (ទទួលរថយន្ត)'
                    : '09:00 AM (Hand-off)',
                icon: Icons.key_rounded,
                accentColor: const Color(0xFF2563EB),
                isDue: false,
              );
              final dueCard = _buildDateCard(
                title: _t('due_date').toUpperCase(),
                date: effectiveTo,
                timeLabel: widget.store.language == AppLanguage.khmer
                    ? '០៦:០០ ល្ងាច (ប្រគល់រថយន្ត)'
                    : '06:00 PM (Vehicle Due)',
                icon: Icons.flag_rounded,
                accentColor: AppColors.brandRed,
                isDue: true,
              );

              if (isNarrow) {
                return Column(
                  children: [
                    pickupCard,
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.arrow_downward_rounded, size: 16, color: Color(0xFF94A3B8)),
                          const SizedBox(width: 6),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                              color: const Color(0xFF0F172A),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(
                              '$_customDays ${_t('days_rental')}',
                              style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold),
                            ),
                          ),
                        ],
                      ),
                    ),
                    dueCard,
                  ],
                );
              }

              return Row(
                children: [
                  Expanded(child: pickupCard),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 10),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
                          decoration: BoxDecoration(
                            color: const Color(0xFF0F172A),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            '$_customDays d',
                            style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold),
                          ),
                        ),
                        const SizedBox(height: 4),
                        const Icon(Icons.arrow_forward_rounded, size: 16, color: Color(0xFF94A3B8)),
                      ],
                    ),
                  ),
                  Expanded(child: dueCard),
                ],
              );
            },
          ),
          const SizedBox(height: 14),

          // Duration Stepper & Quick Presets
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFFF8FAFC),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const Color(0xFFE2E8F0)),
            ),
            child: Wrap(
              spacing: 8,
              runSpacing: 8,
              crossAxisAlignment: WrapCrossAlignment.center,
              alignment: WrapAlignment.spaceBetween,
              children: [
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        widget.store.language == AppLanguage.khmer ? 'កំណត់ទុក:' : 'Presets:',
                        style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Color(0xFF64748B)),
                      ),
                      const SizedBox(width: 6),
                      _buildDurationChip(3, widget.store.language == AppLanguage.khmer ? '៣ ថ្ងៃ (ចុងសប្តាហ៍)' : '3d (Weekend)'),
                      const SizedBox(width: 5),
                      _buildDurationChip(5, widget.store.language == AppLanguage.khmer ? '៥ ថ្ងៃ' : '5d'),
                      const SizedBox(width: 5),
                      _buildDurationChip(7, widget.store.language == AppLanguage.khmer ? '៧ ថ្ងៃ (១ សប្តាហ៍)' : '7d (1 Wk)'),
                      const SizedBox(width: 5),
                      _buildDurationChip(14, widget.store.language == AppLanguage.khmer ? '១៤ ថ្ងៃ (២ សប្តាហ៍)' : '14d (2 Wk)'),
                      const SizedBox(width: 5),
                      _buildDurationChip(30, widget.store.language == AppLanguage.khmer ? '៣០ ថ្ងៃ (១ ខែ)' : '30d (Month)'),
                    ],
                  ),
                ),
                // Stepper
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: const Color(0xFFCBD5E1)),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        style: IconButton.styleFrom(
                          padding: const EdgeInsets.all(6),
                          minimumSize: const Size(28, 28),
                        ),
                        icon: const Icon(Icons.remove, size: 14, color: Color(0xFF0F172A)),
                        onPressed: _customDays > 1 ? () => setState(() => _customDays--) : null,
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 8),
                        child: Text(
                          '$_customDays ${_t('days_rental')}',
                          style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 13, color: Color(0xFF0F172A)),
                        ),
                      ),
                      IconButton(
                        style: IconButton.styleFrom(
                          padding: const EdgeInsets.all(6),
                          minimumSize: const Size(28, 28),
                        ),
                        icon: const Icon(Icons.add, size: 14, color: Color(0xFF0F172A)),
                        onPressed: _customDays < 90 ? () => setState(() => _customDays++) : null,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 10),

          // Informational Due Notice
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: const Color(0xFFFFFBEB),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: const Color(0xFFFDE68A)),
            ),
            child: Row(
              children: [
                const Icon(Icons.access_time_filled_rounded, size: 15, color: Color(0xFFD97706)),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    widget.store.language == AppLanguage.khmer
                        ? 'រថយន្តត្រូវប្រគល់ត្រឡប់មកវិញត្រឹម ${formattedDate(effectiveTo)} វេលាម៉ោង ០៦:០០ ល្ងាច។'
                        : 'Vehicle is due for return by ${formattedDate(effectiveTo)} at 06:00 PM.',
                    style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: Color(0xFF92400E)),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDateCard({
    required String title,
    required DateTime date,
    required String timeLabel,
    required IconData icon,
    required Color accentColor,
    required bool isDue,
  }) {
    return InkWell(
      onTap: _pickCartDates,
      borderRadius: BorderRadius.circular(14),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: isDue ? const Color(0xFFFFF7ED) : const Color(0xFFF0FDF4),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: isDue ? const Color(0xFFFFEDD5) : const Color(0xFFDCFCE7),
            width: 1.5,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, size: 15, color: accentColor),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    title,
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 0.8,
                      color: accentColor,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                Text(
                  widget.store.language == AppLanguage.khmer ? 'ផ្លាស់ប្តូរ ❯' : 'Change ❯',
                  style: const TextStyle(fontSize: 9, fontWeight: FontWeight.bold, color: Color(0xFF64748B)),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              formattedDate(date),
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w900,
                color: Color(0xFF0F172A),
              ),
            ),
            const SizedBox(height: 4),
            Text(
              timeLabel,
              style: const TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: Color(0xFF64748B),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDurationChip(int days, String label) {
    final isSelected = _customDays == days;
    return InkWell(
      onTap: () => setState(() => _customDays = days),
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF0F172A) : Colors.white,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: isSelected ? const Color(0xFF0F172A) : const Color(0xFFCBD5E1),
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 11,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.w600,
            color: isSelected ? Colors.white : const Color(0xFF334155),
          ),
        ),
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // 2. VEHICLES IN CART SECTION
  // ---------------------------------------------------------------------------
  Widget _buildVehiclesListSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              _t('fleet'),
              style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 16, color: Color(0xFF0F172A)),
            ),
            Text(
              widget.store.language == AppLanguage.khmer
                  ? '${widget.items.length} គ្រឿង'
                  : '${widget.items.length} ${widget.items.length == 1 ? 'vehicle' : 'vehicles'}',
              style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Color(0xFF64748B)),
            ),
          ],
        ),
        const SizedBox(height: 10),
        for (final v in widget.items)
          Container(
            margin: const EdgeInsets.only(bottom: 12),
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: const Color(0xFFE2E8F0)),
              boxShadow: [
                BoxShadow(color: Colors.black.withAlpha(5), blurRadius: 8, offset: const Offset(0, 2)),
              ],
            ),
            child: Row(
              children: [
                // Vehicle Thumbnail with SmartImage
                ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: Container(
                    width: 76,
                    height: 56,
                    color: const Color(0xFFF1F5F9),
                    child: SmartImage(
                      imageSource: (v.imageUrl != null && v.imageUrl!.isNotEmpty && v.imageUrl != 'null')
                          ? v.imageUrl
                          : (v.id == 'v_tiggo9' || v.name.toLowerCase().contains('tiggo')
                              ? 'assets/images/tiggo9_banner.png'
                              : null),
                      fit: BoxFit.cover,
                      fallback: Padding(
                        padding: const EdgeInsets.all(4),
                        child: VehicleArt(type: v.type, color: const Color(0xFF1E293B)),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 14),
                // Vehicle Info
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              v.name.isNotEmpty && v.name != 'null' ? v.name : 'Vehicle',
                              style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 15, color: Color(0xFF0F172A)),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: const Color(0xFFF1F5F9),
                              borderRadius: BorderRadius.circular(4),
                              border: Border.all(color: const Color(0xFFE2E8F0)),
                            ),
                            child: Text(
                              v.type.isNotEmpty && v.type != 'null' ? v.type.toUpperCase() : 'CAR',
                              style: const TextStyle(fontSize: 9, fontWeight: FontWeight.w800, color: Color(0xFF475569)),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Text(
                            '${money(v.dailyCents)}/${_t('day')}',
                            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Color(0xFF64748B)),
                          ),
                          Text(
                            ' × $_customDays d = ',
                            style: const TextStyle(fontSize: 12, color: Color(0xFF94A3B8)),
                          ),
                          Text(
                            money(v.dailyCents * _customDays),
                            style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w900, color: AppColors.brandRed),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                // Remove Action
                IconButton(
                  icon: const Icon(Icons.delete_outline_rounded, color: Color(0xFFEF4444), size: 20),
                  tooltip: widget.store.language == AppLanguage.khmer ? 'លុបចេញ' : 'Remove',
                  onPressed: _busy
                      ? null
                      : () {
                          setState(() => widget.items.remove(v));
                          widget.onRemove(v.id);
                        },
                ),
              ],
            ),
          ),
      ],
    );
  }

  // ---------------------------------------------------------------------------
  // 3. VOUCHER PROMO BOX
  // ---------------------------------------------------------------------------
  Widget _buildVoucherCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.confirmation_number_outlined, color: AppColors.brandRed, size: 18),
              const SizedBox(width: 8),
              Text(
                _t('apply_voucher'),
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Color(0xFF0F172A)),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _voucherController,
                  textCapitalization: TextCapitalization.characters,
                  style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700),
                  decoration: InputDecoration(
                    hintText: widget.store.language == AppLanguage.khmer
                        ? 'កូដ (ឧ. VIP10, TIGGO9, DRIVELINE)'
                        : 'Code (e.g. VIP10, TIGGO9, DRIVELINE)',
                    hintStyle: const TextStyle(fontSize: 12, color: Color(0xFF94A3B8)),
                    filled: true,
                    fillColor: const Color(0xFFF8FAFC),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              FilledButton(
                style: FilledButton.styleFrom(
                  backgroundColor: const Color(0xFF0F172A),
                  padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                ),
                onPressed: _applyVoucher,
                child: Text(_t('apply'), style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
              ),
            ],
          ),
          if (_appliedVoucher != null) ...[
            const SizedBox(height: 10),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: AppColors.brandEmerald.withAlpha(20),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: AppColors.brandEmerald.withAlpha(100)),
              ),
              child: Row(
                children: [
                  const Icon(Icons.check_circle, color: AppColors.brandEmerald, size: 16),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      widget.store.language == AppLanguage.khmer
                          ? 'បានអនុវត្តកូដ: $_appliedVoucher (-${money(_voucherDiscountCents)})'
                          : 'Voucher Applied: $_appliedVoucher (-${money(_voucherDiscountCents)})',
                      style: const TextStyle(color: AppColors.brandEmerald, fontWeight: FontWeight.bold, fontSize: 12),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close, size: 16, color: Color(0xFF475569)),
                    onPressed: _removeVoucher,
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // 4. SUMMARY & PRICING BREAKDOWN CARD
  // ---------------------------------------------------------------------------
  Widget _buildSummaryCard(int rawSubtotal, int totalCents, int amountToPayCents, int remainingBalanceCents) {
    final effectiveTo = _effectiveFrom.add(Duration(days: _customDays - 1));

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: [
          BoxShadow(color: Colors.black.withAlpha(8), blurRadius: 14, offset: const Offset(0, 4)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              const Icon(Icons.receipt_long_rounded, color: Color(0xFF0F172A), size: 20),
              const SizedBox(width: 8),
              Text(
                widget.store.language == AppLanguage.khmer
                    ? 'សង្ខេបតម្លៃ & កាលវិភាគ'
                    : 'Price & Schedule Summary',
                style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 16, color: Color(0xFF0F172A)),
              ),
            ],
          ),
          const SizedBox(height: 16),
          // Schedule Timeline in summary
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(_t('pickup_date'), style: const TextStyle(color: Color(0xFF64748B), fontSize: 13, fontWeight: FontWeight.w500)),
              ),
              const SizedBox(width: 8),
              Text(
                '${formattedDate(_effectiveFrom)} (${widget.store.language == AppLanguage.khmer ? '០៩:០០ ព្រឹក' : '09:00 AM'})',
                style: const TextStyle(color: Color(0xFF0F172A), fontSize: 13, fontWeight: FontWeight.w700),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(_t('due_date'), style: const TextStyle(color: Color(0xFF64748B), fontSize: 13, fontWeight: FontWeight.w500)),
              ),
              const SizedBox(width: 8),
              Text(
                '${formattedDate(effectiveTo)} (${widget.store.language == AppLanguage.khmer ? '០៦:០០ ល្ងាច' : '06:00 PM'})',
                style: const TextStyle(color: AppColors.brandRed, fontSize: 13, fontWeight: FontWeight.w800),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  widget.store.language == AppLanguage.khmer ? 'រយៈពេលជួល' : 'Duration Days',
                  style: const TextStyle(color: Color(0xFF64748B), fontSize: 13, fontWeight: FontWeight.w500),
                ),
              ),
              const SizedBox(width: 8),
              Text('$_customDays ${_t('days_rental')}', style: const TextStyle(color: Color(0xFF0F172A), fontSize: 13, fontWeight: FontWeight.w600)),
            ],
          ),
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 8),
            child: Divider(color: Color(0xFFF1F5F9), height: 1),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  widget.store.language == AppLanguage.khmer ? 'តម្លៃរថយន្តសរុប' : 'Fleet Subtotal',
                  style: const TextStyle(color: Color(0xFF64748B), fontSize: 13, fontWeight: FontWeight.w500),
                ),
              ),
              const SizedBox(width: 8),
              Text(money(rawSubtotal), style: const TextStyle(color: Color(0xFF0F172A), fontSize: 14, fontWeight: FontWeight.w700)),
            ],
          ),
          if (_voucherDiscountCents > 0) ...[
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    widget.store.language == AppLanguage.khmer
                        ? 'បញ្ចុះតម្លៃពីកូដ ($_appliedVoucher)'
                        : 'Voucher Savings ($_appliedVoucher)',
                    style: const TextStyle(color: AppColors.brandEmerald, fontSize: 13, fontWeight: FontWeight.bold),
                  ),
                ),
                const SizedBox(width: 8),
                Text('- ${money(_voucherDiscountCents)}', style: const TextStyle(color: AppColors.brandEmerald, fontSize: 14, fontWeight: FontWeight.w900)),
              ],
            ),
          ],
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  widget.store.language == AppLanguage.khmer ? 'ជំនួយសង្គ្រោះតាមផ្លូវ 24/7' : '24/7 Roadside Assistance',
                  style: const TextStyle(color: Color(0xFF64748B), fontSize: 13, fontWeight: FontWeight.w500),
                ),
              ),
              const SizedBox(width: 8),
              Text(
                widget.store.language == AppLanguage.khmer ? 'រួមបញ្ចូលរួច' : 'Included',
                style: const TextStyle(color: AppColors.brandEmerald, fontSize: 12, fontWeight: FontWeight.bold),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  widget.store.language == AppLanguage.khmer ? 'ពន្ធ & ធានារ៉ាប់រងស្តង់ដារ' : 'Taxes & Standard Insurance',
                  style: const TextStyle(color: Color(0xFF64748B), fontSize: 13, fontWeight: FontWeight.w500),
                ),
              ),
              const SizedBox(width: 8),
              Text(
                widget.store.language == AppLanguage.khmer ? 'រួមបញ្ចូលរួច' : 'Included',
                style: const TextStyle(color: AppColors.brandEmerald, fontSize: 12, fontWeight: FontWeight.bold),
              ),
            ],
          ),
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 14),
            child: Divider(color: Color(0xFFE2E8F0), height: 1),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(_t('balance_due'), style: const TextStyle(color: Color(0xFF0F172A), fontWeight: FontWeight.w900, fontSize: 14)),
                    const SizedBox(height: 2),
                    Text(
                      widget.store.language == AppLanguage.khmer
                          ? 'គ្មានការគិតថ្លៃលាក់កំបាំង • រួមបញ្ចូលទាំងអស់'
                          : 'No hidden charges • All inclusive',
                      style: const TextStyle(color: Color(0xFF94A3B8), fontSize: 10),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Text(
                money(totalCents),
                style: const TextStyle(color: AppColors.brandRed, fontSize: 24, fontWeight: FontWeight.w900),
              ),
            ],
          ),
          if (_paymentTerm == PaymentTerm.deposit) ...[
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: const Color(0xFFEFF6FF),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: const Color(0xFFBFDBFE)),
              ),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          widget.store.language == AppLanguage.khmer ? 'ប្រាក់កក់បង់ថ្ងៃនេះ (30%):' : 'Deposit Due Today (30%):',
                          style: const TextStyle(color: Color(0xFF1D4ED8), fontSize: 12, fontWeight: FontWeight.bold),
                        ),
                      ),
                      Text(money(amountToPayCents), style: const TextStyle(color: Color(0xFF1D4ED8), fontSize: 13, fontWeight: FontWeight.w900)),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          widget.store.language == AppLanguage.khmer ? 'សមតុល្យនៅសល់ពេលទទួលរថយន្ត:' : 'Remaining at Pickup:',
                          style: const TextStyle(color: Color(0xFF64748B), fontSize: 12, fontWeight: FontWeight.w600),
                        ),
                      ),
                      Text(money(remainingBalanceCents), style: const TextStyle(color: Color(0xFF0F172A), fontSize: 13, fontWeight: FontWeight.w800)),
                    ],
                  ),
                ],
              ),
            ),
          ] else if (_paymentTerm == PaymentTerm.onArrival) ...[
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: const Color(0xFFFFFBEB),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: const Color(0xFFFDE68A)),
              ),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          widget.store.language == AppLanguage.khmer ? 'ទឹកប្រាក់ត្រូវបង់ថ្ងៃនេះ:' : 'Due Today:',
                          style: const TextStyle(color: Color(0xFF047857), fontSize: 12, fontWeight: FontWeight.bold),
                        ),
                      ),
                      const Text('\$0.00', style: TextStyle(color: Color(0xFF047857), fontSize: 13, fontWeight: FontWeight.w900)),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          widget.store.language == AppLanguage.khmer ? 'សមតុល្យត្រូវទូទាត់ពេលទទួល:' : 'Payable at Pickup:',
                          style: const TextStyle(color: Color(0xFFB45309), fontSize: 12, fontWeight: FontWeight.w600),
                        ),
                      ),
                      Text(money(totalCents), style: const TextStyle(color: AppColors.brandRed, fontSize: 13, fontWeight: FontWeight.w800)),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // 5. RENTER DETAILS CARD
  // ---------------------------------------------------------------------------
  Widget _buildRenterDetailsCard() {
    final customers = widget.store.customers;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: [
          BoxShadow(color: Colors.black.withAlpha(8), blurRadius: 14, offset: const Offset(0, 4)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(7),
                decoration: BoxDecoration(
                  color: const Color(0xFF0F172A).withAlpha(15),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(Icons.person_pin_rounded, color: Color(0xFF0F172A), size: 20),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _t('renter_details'),
                      style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 16, color: Color(0xFF0F172A)),
                    ),
                    Text(
                      widget.store.language == AppLanguage.khmer
                          ? 'បញ្ចូលឈ្មោះអ្នកកក់ ឬជ្រើសរើសព័ត៌មានអតិថិជនដែលមានស្រាប់'
                          : 'Input booking user name or pick existing customer profile',
                      style: const TextStyle(fontSize: 11, color: Color(0xFF64748B), fontWeight: FontWeight.w500),
                    ),
                  ],
                ),
              ),
            ],
          ),

          if (customers.isNotEmpty) ...[
            const SizedBox(height: 14),
            Row(
              children: [
                const Icon(Icons.flash_on_rounded, size: 14, color: AppColors.brandRed),
                const SizedBox(width: 4),
                Text(
                  _t('registered_renters'),
                  style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w800, color: Color(0xFF475569)),
                ),
              ],
            ),
            const SizedBox(height: 8),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  ActionChip(
                    avatar: const Icon(Icons.person_add_rounded, size: 14, color: Color(0xFF475569)),
                    label: Text(
                      widget.store.language == AppLanguage.khmer ? 'អ្នកប្រើប្រាស់ថ្មី' : 'New User',
                      style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold),
                    ),
                    backgroundColor: _selectedCustomerId == null ? const Color(0xFF0F172A) : const Color(0xFFF1F5F9),
                    labelStyle: TextStyle(
                      color: _selectedCustomerId == null ? Colors.white : const Color(0xFF334155),
                    ),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                    onPressed: () {
                      setState(() {
                        _selectedCustomerId = null;
                        _name.clear();
                        _phone.clear();
                        _email.clear();
                      });
                    },
                  ),
                  const SizedBox(width: 6),
                  for (final c in customers) ...[
                    ActionChip(
                      avatar: CircleAvatar(
                        radius: 10,
                        backgroundColor: _selectedCustomerId == c.id ? Colors.white : AppColors.brandRed.withAlpha(40),
                        child: Text(
                          c.name.isNotEmpty ? c.name[0].toUpperCase() : '?',
                          style: TextStyle(
                            fontSize: 9,
                            fontWeight: FontWeight.bold,
                            color: _selectedCustomerId == c.id ? const Color(0xFF0F172A) : AppColors.brandRed,
                          ),
                        ),
                      ),
                      label: Text(c.name, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600)),
                      backgroundColor: _selectedCustomerId == c.id ? AppColors.brandRed : Colors.white,
                      labelStyle: TextStyle(
                        color: _selectedCustomerId == c.id ? Colors.white : const Color(0xFF0F172A),
                        fontWeight: _selectedCustomerId == c.id ? FontWeight.bold : FontWeight.w600,
                      ),
                      side: BorderSide(
                        color: _selectedCustomerId == c.id ? AppColors.brandRed : const Color(0xFFE2E8F0),
                      ),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                      onPressed: () {
                        setState(() {
                          _selectedCustomerId = c.id;
                          _name.text = c.name;
                          _phone.text = c.phone;
                          _email.text = c.email;
                        });
                      },
                    ),
                    const SizedBox(width: 6),
                  ],
                ],
              ),
            ),
          ],

          const SizedBox(height: 16),
          // User Name Input
          TextField(
            controller: _name,
            decoration: InputDecoration(
              labelText: '${_t('booking_user_name')} *',
              hintText: 'e.g. Sokha Chan, Michael Smith',
              prefixIcon: const Icon(Icons.person_rounded, size: 20, color: Color(0xFF0F172A)),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
              contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
              filled: true,
              fillColor: const Color(0xFFF8FAFC),
              helperText: widget.store.language == AppLanguage.khmer
                  ? 'កិច្ចសន្យាជួលនឹងត្រូវចេញក្រោមឈ្មោះអ្នកប្រើប្រាស់នេះ'
                  : 'Rental agreement will be issued under this user name',
              helperStyle: const TextStyle(fontSize: 10, color: Color(0xFF64748B)),
            ),
          ),
          const SizedBox(height: 14),
          // Phone Input
          TextField(
            controller: _phone,
            keyboardType: TextInputType.phone,
            decoration: InputDecoration(
              labelText: '${_t('phone_number')} *',
              hintText: '+855 12 345 678',
              prefixIcon: const Icon(Icons.phone_rounded, size: 20, color: Color(0xFF0F172A)),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
              contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
              filled: true,
              fillColor: const Color(0xFFF8FAFC),
            ),
          ),
          const SizedBox(height: 14),
          // Email Input
          TextField(
            controller: _email,
            keyboardType: TextInputType.emailAddress,
            decoration: InputDecoration(
              labelText: widget.store.language == AppLanguage.khmer
                  ? '${_t('email_address')} (ជម្រើស)'
                  : '${_t('email_address')} (Optional)',
              hintText: 'booking@example.com',
              prefixIcon: const Icon(Icons.email_outlined, size: 20, color: Color(0xFF64748B)),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
              contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
              filled: true,
              fillColor: const Color(0xFFF8FAFC),
            ),
          ),
          const SizedBox(height: 14),
          // Notes Input
          TextField(
            controller: _notes,
            maxLines: 2,
            decoration: InputDecoration(
              labelText: widget.store.language == AppLanguage.khmer
                  ? 'ទីតាំងទទួល / កំណត់ចំណាំជើងហោះហើរ (ជម្រើស)'
                  : 'Pickup Location / Flight Notes (Optional)',
              hintText: widget.store.language == AppLanguage.khmer
                  ? 'ឧ. ព្រលានយន្តហោះអន្តរជាតិភ្នំពេញ ច្រកទី 2 ឬឡប់ប៊ីសណ្ឋាគារ'
                  : 'e.g. Phnom Penh Intl Airport Gate 2 or Hotel Lobby',
              prefixIcon: const Icon(Icons.flight_land_rounded, size: 20, color: Color(0xFF64748B)),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
              contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              filled: true,
              fillColor: const Color(0xFFF8FAFC),
            ),
          ),
        ],
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // 6. PAYMENT TERMS, METHOD & FINAL RESERVATION CTA
  // ---------------------------------------------------------------------------
  Widget _buildPaymentCard(int totalCents, int amountToPayCents, int remainingBalanceCents) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: [
          BoxShadow(color: Colors.black.withAlpha(8), blurRadius: 14, offset: const Offset(0, 4)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Section Title
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(7),
                decoration: BoxDecoration(
                  color: AppColors.brandRed.withAlpha(20),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(Icons.payment_rounded, color: AppColors.brandRed, size: 20),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _t('payment_method'),
                      style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 16, color: Color(0xFF0F172A)),
                    ),
                    Text(
                      widget.store.language == AppLanguage.khmer
                          ? 'ជ្រើសរើសលក្ខខណ្ឌទូទាត់ និងវិធីសាស្ត្រទូទាត់ប្រាក់'
                          : 'Select flexible payment terms & payment method',
                      style: const TextStyle(fontSize: 11, color: Color(0xFF64748B), fontWeight: FontWeight.w500),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Payment Terms: 3 Options
          _buildPaymentTermTile(
            term: PaymentTerm.full,
            title: _t('pay_in_full'),
            badge: widget.store.language == AppLanguage.khmer ? 'ណែនាំ' : 'RECOMMENDED',
            badgeColor: AppColors.brandEmerald,
            amountSubtitle: money(totalCents),
            description: widget.store.language == AppLanguage.khmer
                ? 'ទូទាត់ 100% ឥឡូវនេះ • គ្មានសមតុល្យជំពាក់ពេលមកទទួលរថយន្ត'
                : '100% payment now • Zero balance remaining at vehicle pickup',
          ),
          const SizedBox(height: 10),
          _buildPaymentTermTile(
            term: PaymentTerm.deposit,
            title: _t('pay_deposit'),
            badge: widget.store.language == AppLanguage.khmer ? 'ប្រាក់កក់ 30%' : '30% DEPOSIT',
            badgeColor: const Color(0xFF2563EB),
            amountSubtitle: '${money((totalCents * 0.30).round())} today',
            description: widget.store.language == AppLanguage.khmer
                ? 'កក់រថយន្តទុកជាមុន • 70% ទៀតទូទាត់ពេលមកទទួលរថយន្ត'
                : 'Hold vehicle reservation now • Pay remaining 70% on arrival',
          ),
          const SizedBox(height: 10),
          _buildPaymentTermTile(
            term: PaymentTerm.onArrival,
            title: _t('pay_at_pickup'),
            badge: widget.store.language == AppLanguage.khmer ? 'ពេលមកដល់' : 'ON ARRIVAL',
            badgeColor: const Color(0xFFD97706),
            amountSubtitle: '\$0.00 today',
            description: widget.store.language == AppLanguage.khmer
                ? 'ពិនិត្យរថយន្តផ្ទាល់ • ទូទាត់សាច់ប្រាក់ ឬកាតពេលមកដល់'
                : 'Inspect car in person • Pay with cash or card upon pickup',
          ),

          const SizedBox(height: 18),
          const Divider(color: Color(0xFFE2E8F0), height: 1),
          const SizedBox(height: 16),

          // Payment Method Selector (When Full or Deposit)
          if (_paymentTerm != PaymentTerm.onArrival) ...[
            Text(
              widget.store.language == AppLanguage.khmer ? 'ជ្រើសរើសវិធីសាស្ត្រទូទាត់:' : 'Select Payment Gateway:',
              style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 13, color: Color(0xFF0F172A)),
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(
                  child: _buildPaymentMethodTab(
                    method: PaymentMethod.khqr,
                    icon: Icons.qr_code_scanner_rounded,
                    label: _t('khqr_aba'),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: _buildPaymentMethodTab(
                    method: PaymentMethod.card,
                    icon: Icons.credit_card_rounded,
                    label: _t('credit_card'),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),

            // Method details
            if (_paymentMethod == PaymentMethod.khqr) ...[
              _buildKhqrBox(amountToPayCents),
            ] else ...[
              _buildCardInputs(),
            ],
          ] else ...[
            // On Arrival Info Box
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: const Color(0xFFFFFBEB),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xFFFDE68A)),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(Icons.storefront_rounded, color: Color(0xFFD97706), size: 22),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _t('cash_on_arrival'),
                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Color(0xFF92400E)),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          widget.store.language == AppLanguage.khmer
                              ? 'សូមយកប័ណ្ណបើកបរ និងអត្តសញ្ញាណប័ណ្ណមកជាមួយ។ អ្នកអាចទូទាត់ដោយសាច់ប្រាក់ ដុល្លារ រៀល ឬកាតធនាគារក្នុងស្រុកនៅការិយាល័យ DriveLine ភ្នំពេញ។'
                              : 'Please bring your driver license and ID. Settle full balance via USD/KHR cash or card at our showroom upon vehicle inspection.',
                          style: const TextStyle(fontSize: 11, color: Color(0xFF78350F), height: 1.4),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],

          const SizedBox(height: 18),
          // Telemetry Settlement Summary
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            decoration: BoxDecoration(
              color: const Color(0xFFF8FAFC),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const Color(0xFFE2E8F0)),
            ),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(_t('amount_paid'), style: const TextStyle(fontSize: 12, color: Color(0xFF64748B), fontWeight: FontWeight.w600)),
                    Text(money(amountToPayCents), style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w900, color: Color(0xFF0F172A))),
                  ],
                ),
                const SizedBox(height: 6),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(_t('remaining_balance'), style: const TextStyle(fontSize: 12, color: Color(0xFF64748B), fontWeight: FontWeight.w600)),
                    Text(
                      money(remainingBalanceCents),
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w900,
                        color: remainingBalanceCents > 0 ? AppColors.brandRed : AppColors.brandEmerald,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          if (_error != null)
            Padding(
              padding: const EdgeInsets.only(top: 14),
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.red.withAlpha(20),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: Colors.red.withAlpha(80)),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.error_outline, color: Colors.red, size: 18),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        _error!,
                        style: const TextStyle(color: Colors.red, fontWeight: FontWeight.bold, fontSize: 12),
                      ),
                    ),
                  ],
                ),
              ),
            ),

          const SizedBox(height: 20),
          FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor: AppColors.brandRed,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              elevation: 0,
            ),
            onPressed: _busy ? null : _checkout,
            child: _busy
                ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                : Text(
                    _paymentTerm == PaymentTerm.full
                        ? '${_t('confirm_reservation')} (${money(totalCents)})'
                        : _paymentTerm == PaymentTerm.deposit
                            ? '${_t('confirm_reservation')} (${money(amountToPayCents)} Deposit)'
                            : '${_t('confirm_reservation')} (${money(totalCents)} at Pickup)',
                    style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 15),
                  ),
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.lock_outline, size: 13, color: Color(0xFF94A3B8)),
              const SizedBox(width: 4),
              Text(
                widget.store.language == AppLanguage.khmer
                    ? 'ធានាសុវត្ថិភាពការកក់កម្រិត 256-bit SSL'
                    : '256-bit SSL Encrypted Booking Guarantee',
                style: const TextStyle(fontSize: 10, color: Color(0xFF94A3B8), fontWeight: FontWeight.w600),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPaymentTermTile({
    required PaymentTerm term,
    required String title,
    required String badge,
    required Color badgeColor,
    required String amountSubtitle,
    required String description,
  }) {
    final isSelected = _paymentTerm == term;
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () => setState(() => _paymentTerm = term),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFFF8FAFC) : Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: isSelected ? AppColors.brandRed : const Color(0xFFE2E8F0),
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              margin: const EdgeInsets.only(top: 2),
              width: 18,
              height: 18,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: isSelected ? AppColors.brandRed : const Color(0xFF94A3B8),
                  width: isSelected ? 5 : 2,
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          title,
                          style: TextStyle(
                            fontWeight: FontWeight.w800,
                            fontSize: 13,
                            color: isSelected ? const Color(0xFF0F172A) : const Color(0xFF334155),
                          ),
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                        decoration: BoxDecoration(
                          color: badgeColor.withAlpha(20),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          badge,
                          style: TextStyle(fontSize: 9, fontWeight: FontWeight.bold, color: badgeColor),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 3),
                  Text(
                    amountSubtitle,
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w900,
                      color: isSelected ? AppColors.brandRed : const Color(0xFF0F172A),
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    description,
                    style: const TextStyle(fontSize: 11, color: Color(0xFF64748B), height: 1.3),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPaymentMethodTab({
    required PaymentMethod method,
    required IconData icon,
    required String label,
  }) {
    final isSelected = _paymentMethod == method;
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () => setState(() => _paymentMethod = method),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 12),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF0F172A) : const Color(0xFFF8FAFC),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? const Color(0xFF0F172A) : const Color(0xFFCBD5E1),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 16,
              color: isSelected ? Colors.white : const Color(0xFF475569),
            ),
            const SizedBox(width: 6),
            Flexible(
              child: Text(
                label,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 11,
                  color: isSelected ? Colors.white : const Color(0xFF0F172A),
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildKhqrBox(int amountToPayCents) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFE11D48).withAlpha(120), width: 1.5),
        boxShadow: [
          BoxShadow(color: const Color(0xFFE11D48).withAlpha(15), blurRadius: 10, offset: const Offset(0, 4)),
        ],
      ),
      child: Column(
        children: [
          // Bakong Red Top Bar
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
            decoration: const BoxDecoration(
              color: Color(0xFFE11D48),
              borderRadius: BorderRadius.vertical(top: Radius.circular(12)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: const Text('KHQR', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 11, color: Color(0xFFE11D48))),
                      ),
                      const SizedBox(width: 8),
                      const Expanded(
                        child: Text(
                          'Bakong National Payment',
                          style: TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  widget.store.language == AppLanguage.khmer ? 'ស្កេនរហ័ស' : 'INSTANT SCAN',
                  style: const TextStyle(color: Colors.white70, fontSize: 10, fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                Text(
                  widget.store.agencyConfig.companyName.toUpperCase(),
                  style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 12, letterSpacing: 0.8, color: Color(0xFF0F172A)),
                ),
                const SizedBox(height: 2),
                Text(
                  widget.store.language == AppLanguage.khmer
                      ? 'គណនីទូទាត់ផ្លូវការ (USD)'
                      : 'Official Merchant Account (USD)',
                  style: const TextStyle(fontSize: 10, color: Color(0xFF64748B)),
                ),
                const SizedBox(height: 10),

                // QR Box Simulation
                Container(
                  width: 140,
                  height: 140,
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: const Color(0xFF0F172A), width: 2),
                  ),
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      Column(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              _qrCorner(),
                              _qrCorner(),
                            ],
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              _qrCorner(),
                              Container(
                                width: 26,
                                height: 26,
                                decoration: BoxDecoration(
                                  color: const Color(0xFF0F172A),
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: const Icon(Icons.qr_code_2_rounded, size: 18, color: Colors.white),
                              ),
                            ],
                          ),
                        ],
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                        decoration: BoxDecoration(
                          color: const Color(0xFFE11D48),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: const Text('KHQR', style: TextStyle(color: Colors.white, fontSize: 9, fontWeight: FontWeight.w900)),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  'USD ${money(amountToPayCents)}',
                  style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 18, color: Color(0xFFE11D48)),
                ),
                const SizedBox(height: 4),
                Text(
                  _t('scan_khqr'),
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 10, color: Color(0xFF64748B)),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _qrCorner() {
    return Container(
      width: 26,
      height: 26,
      padding: const EdgeInsets.all(3),
      decoration: BoxDecoration(
        color: const Color(0xFF0F172A),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Container(
        color: Colors.white,
        padding: const EdgeInsets.all(3),
        child: Container(
          color: const Color(0xFF0F172A),
        ),
      ),
    );
  }

  Widget _buildCardInputs() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        TextField(
          controller: _cardNumberController,
          keyboardType: TextInputType.number,
          decoration: InputDecoration(
            labelText: _t('card_number'),
            hintText: '4532 •••• •••• 8892',
            prefixIcon: const Icon(Icons.credit_card_rounded, size: 20, color: Color(0xFF0F172A)),
            suffixIcon: const Padding(
              padding: EdgeInsets.only(right: 12),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.payment, size: 18, color: Color(0xFF2563EB)),
                  SizedBox(width: 4),
                  Icon(Icons.lock_rounded, size: 16, color: Color(0xFF10B981)),
                ],
              ),
            ),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
            contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            filled: true,
            fillColor: const Color(0xFFF8FAFC),
          ),
        ),
        const SizedBox(height: 10),
        Row(
          children: [
            Expanded(
              child: TextField(
                controller: _cardExpiryController,
                keyboardType: TextInputType.datetime,
                decoration: InputDecoration(
                  labelText: _t('card_expiry'),
                  hintText: 'MM/YY',
                  prefixIcon: const Icon(Icons.date_range_rounded, size: 18, color: Color(0xFF64748B)),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                  filled: true,
                  fillColor: const Color(0xFFF8FAFC),
                ),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: TextField(
                controller: _cardCvvController,
                keyboardType: TextInputType.number,
                obscureText: true,
                decoration: InputDecoration(
                  labelText: _t('card_cvv'),
                  hintText: 'CVC / CVV',
                  prefixIcon: const Icon(Icons.security_rounded, size: 18, color: Color(0xFF64748B)),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                  filled: true,
                  fillColor: const Color(0xFFF8FAFC),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  // ---------------------------------------------------------------------------
  // 7. EMPTY CART VIEW
  // ---------------------------------------------------------------------------
  Widget _buildEmptyCart() {
    return Container(
      constraints: const BoxConstraints(maxWidth: 480),
      padding: const EdgeInsets.all(40),
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: [
          BoxShadow(color: Colors.black.withAlpha(6), blurRadius: 16, offset: const Offset(0, 4)),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: const BoxDecoration(
              color: Color(0xFFF1F5F9),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.shopping_bag_outlined, size: 54, color: Color(0xFF64748B)),
          ),
          const SizedBox(height: 20),
          Text(_t('empty_cart'), style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w900, color: Color(0xFF0F172A))),
          const SizedBox(height: 8),
          Text(
            widget.store.language == AppLanguage.khmer
                ? 'ស្វែងរកការប្រមូលផ្តុំរថយន្តប្រណិត និងស្ព័ររបស់យើង ហើយកក់រថយន្តរបស់អ្នកក្នុងរយៈពេលប៉ុន្មានវិនាទី។'
                : 'Explore our luxury and sports car collection and reserve yours in seconds.',
            textAlign: TextAlign.center,
            style: const TextStyle(color: Color(0xFF64748B), fontSize: 13, height: 1.4),
          ),
          const SizedBox(height: 24),
          FilledButton.icon(
            style: FilledButton.styleFrom(
              backgroundColor: AppColors.brandRed,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
            icon: const Icon(Icons.directions_car, size: 18),
            label: Text(_t('fleet'), style: const TextStyle(fontWeight: FontWeight.bold)),
            onPressed: () => Navigator.pop(context),
          ),
        ],
      ),
    );
  }

  String get _paymentMethodLabel {
    if (_lastPaymentTerm == PaymentTerm.onArrival) {
      return widget.store.language == AppLanguage.khmer ? 'បង់ប្រាក់ពេលមកដល់' : 'Pay on Arrival';
    }
    if (_lastPaymentMethod == PaymentMethod.khqr) {
      return widget.store.language == AppLanguage.khmer ? 'ស្កេន KHQR / ABA Mobile' : 'ABA / KHQR Mobile Banking';
    }
    final lastDigits = _cardNumberController.text.trim().replaceAll(' ', '');
    final masked = lastDigits.length >= 4 ? lastDigits.substring(lastDigits.length - 4) : '8892';
    return widget.store.language == AppLanguage.khmer ? 'កាតធនាគារ (••• $masked)' : 'Card ending $masked';
  }

  // ---------------------------------------------------------------------------
  // 8. OFFICIAL RESERVATION RECEIPT & PAYMENT CONFIRMATION VOUCHER
  // ---------------------------------------------------------------------------
  Widget _buildConfirmationCard(int totalCents, int rawSubtotal) {
    final effectiveTo = _effectiveFrom.add(Duration(days: _customDays - 1));

    return Center(
      child: Container(
        constraints: const BoxConstraints(maxWidth: 680),
        padding: const EdgeInsets.all(32),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: const Color(0xFFE2E8F0)),
          boxShadow: [
            BoxShadow(color: Colors.black.withAlpha(12), blurRadius: 24, offset: const Offset(0, 8)),
          ],
        ),
        child: Column(
          children: [
            // Top Header & Seal
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: AppColors.brandRed.withAlpha(20),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Icon(Icons.car_rental_rounded, color: AppColors.brandRed, size: 22),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              widget.store.agencyConfig.companyName.toUpperCase(),
                              style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 16, color: Color(0xFF0F172A)),
                              overflow: TextOverflow.ellipsis,
                            ),
                            Text(
                              _t('booking_receipt'),
                              style: const TextStyle(fontSize: 11, color: Color(0xFF64748B), fontWeight: FontWeight.w600),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: const Color(0xFF0F172A),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    _lastBookingRef.isNotEmpty ? _lastBookingRef : 'DL-RES-CONFIRMED',
                    style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 11),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),

            // Dynamic Payment Status Banner
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: _lastPaymentTerm == PaymentTerm.full
                    ? AppColors.brandEmerald.withAlpha(20)
                    : _lastPaymentTerm == PaymentTerm.deposit
                        ? const Color(0xFFEFF6FF)
                        : const Color(0xFFFFFBEB),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                  color: _lastPaymentTerm == PaymentTerm.full
                      ? AppColors.brandEmerald.withAlpha(90)
                      : _lastPaymentTerm == PaymentTerm.deposit
                          ? const Color(0xFFBFDBFE)
                          : const Color(0xFFFDE68A),
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    _lastPaymentTerm == PaymentTerm.full
                        ? Icons.check_circle_rounded
                        : _lastPaymentTerm == PaymentTerm.deposit
                            ? Icons.shield_rounded
                            : Icons.pending_actions_rounded,
                    color: _lastPaymentTerm == PaymentTerm.full
                        ? AppColors.brandEmerald
                        : _lastPaymentTerm == PaymentTerm.deposit
                            ? const Color(0xFF1D4ED8)
                            : const Color(0xFFD97706),
                    size: 32,
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _lastPaymentTerm == PaymentTerm.full
                              ? _t('paid_in_full')
                              : _lastPaymentTerm == PaymentTerm.deposit
                                  ? _t('deposit_paid')
                                  : _t('payment_pending'),
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w900,
                            color: _lastPaymentTerm == PaymentTerm.full
                                ? AppColors.brandEmerald
                                : _lastPaymentTerm == PaymentTerm.deposit
                                    ? const Color(0xFF1D4ED8)
                                    : const Color(0xFFB45309),
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          _lastPaymentTerm == PaymentTerm.full
                              ? (widget.store.language == AppLanguage.khmer
                                  ? 'បានទូទាត់ពេញលេញ ${money(_lastAmountPaidCents)} តាម $_paymentMethodLabel'
                                  : 'Full payment of ${money(_lastAmountPaidCents)} confirmed via $_paymentMethodLabel')
                              : _lastPaymentTerm == PaymentTerm.deposit
                                  ? (widget.store.language == AppLanguage.khmer
                                      ? 'បានបង់ប្រាក់កក់ ${money(_lastAmountPaidCents)} • នៅសល់ ${money(_lastRemainingBalanceCents)} ត្រូវទូទាត់ពេលទទួល'
                                      : 'Deposit of ${money(_lastAmountPaidCents)} confirmed • Remaining ${money(_lastRemainingBalanceCents)} due at pickup')
                                  : (widget.store.language == AppLanguage.khmer
                                      ? 'ការកក់មានសុពលភាព • ត្រូវទូទាត់ ${money(_lastRemainingBalanceCents)} ពេលមកទទួលរថយន្ត'
                                      : 'Reservation verified • Please settle ${money(_lastRemainingBalanceCents)} upon vehicle inspection'),
                          style: const TextStyle(fontSize: 11, color: Color(0xFF475569)),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Itemized Details Grid
            Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: const Color(0xFFF8FAFC),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: const Color(0xFFE2E8F0)),
              ),
              child: Column(
                children: [
                  for (final id in _confirmed!)
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 3),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Text(
                              widget.store.language == AppLanguage.khmer ? 'លេខយោងការកក់:' : 'Booking ID Reference:',
                              style: const TextStyle(color: Color(0xFF64748B), fontSize: 12),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(id, style: const TextStyle(fontWeight: FontWeight.w900, color: Color(0xFF0F172A), fontSize: 13)),
                        ],
                      ),
                    ),
                  const Divider(height: 18),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text('${_t('booking_user_name')}:', style: const TextStyle(color: Color(0xFF64748B), fontSize: 12)),
                      ),
                      const SizedBox(width: 8),
                      Flexible(
                        child: Text(_name.text.trim(), textAlign: TextAlign.right, style: const TextStyle(fontWeight: FontWeight.w900, color: Color(0xFF0F172A), fontSize: 13)),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text('${_t('phone_number')}:', style: const TextStyle(color: Color(0xFF64748B), fontSize: 12)),
                      ),
                      const SizedBox(width: 8),
                      Flexible(
                        child: Text(_phone.text.trim(), textAlign: TextAlign.right, style: const TextStyle(fontWeight: FontWeight.w700, color: Color(0xFF0F172A), fontSize: 12)),
                      ),
                    ],
                  ),
                  if (_email.text.trim().isNotEmpty) ...[
                    const SizedBox(height: 6),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text('${_t('email_address')}:', style: const TextStyle(color: Color(0xFF64748B), fontSize: 12)),
                        ),
                        const SizedBox(width: 8),
                        Flexible(
                          child: Text(_email.text.trim(), textAlign: TextAlign.right, style: const TextStyle(fontWeight: FontWeight.w600, color: Color(0xFF0F172A), fontSize: 12)),
                        ),
                      ],
                    ),
                  ],
                  const SizedBox(height: 6),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text('${_t('pickup_date')}:', style: const TextStyle(color: Color(0xFF64748B), fontSize: 12)),
                      ),
                      const SizedBox(width: 8),
                      Flexible(
                        child: Text(
                          '${formattedDate(_effectiveFrom)} (${widget.store.language == AppLanguage.khmer ? '០៩:០០ ព្រឹក' : '09:00 AM'})',
                          textAlign: TextAlign.right,
                          style: const TextStyle(fontWeight: FontWeight.w700, color: Color(0xFF0F172A), fontSize: 12),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text('${_t('due_date')}:', style: const TextStyle(color: Color(0xFF64748B), fontSize: 12)),
                      ),
                      const SizedBox(width: 8),
                      Flexible(
                        child: Text(
                          '${formattedDate(effectiveTo)} (${widget.store.language == AppLanguage.khmer ? '០៦:០០ ល្ងាច' : '06:00 PM'})',
                          textAlign: TextAlign.right,
                          style: const TextStyle(fontWeight: FontWeight.w800, color: AppColors.brandRed, fontSize: 12),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          widget.store.language == AppLanguage.khmer ? 'រយៈពេលជួល:' : 'Rental Duration:',
                          style: const TextStyle(color: Color(0xFF64748B), fontSize: 12),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text('$_customDays ${_t('days_rental')}', style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF0F172A), fontSize: 12)),
                    ],
                  ),
                  const Divider(height: 18),

                  // Reserved Fleet Vehicles itemized
                  for (final v in widget.items)
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 4),
                      child: Row(
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(6),
                            child: SizedBox(
                              width: 38,
                              height: 28,
                              child: SmartImage(
                                imageSource: (v.imageUrl != null && v.imageUrl!.isNotEmpty && v.imageUrl != 'null') ? v.imageUrl : null,
                                fallback: VehicleArt(type: v.type, color: AppColors.brandRed),
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(v.name.isNotEmpty && v.name != 'null' ? v.name : 'Vehicle', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: Color(0xFF0F172A))),
                                Text('${v.brand.isNotEmpty && v.brand != 'null' ? v.brand : 'DRIVELINE'} • ${money(v.dailyCents)} / day', style: const TextStyle(fontSize: 10, color: Color(0xFF64748B))),
                              ],
                            ),
                          ),
                          Text(money(v.dailyCents * _customDays), style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 12, color: Color(0xFF0F172A))),
                        ],
                      ),
                    ),

                  const Divider(height: 18),
                  // Financial Breakdown
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text('${_t('balance_due')}:', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Color(0xFF0F172A))),
                      ),
                      const SizedBox(width: 8),
                      Text(money(totalCents), style: const TextStyle(fontWeight: FontWeight.w900, color: Color(0xFF0F172A), fontSize: 15)),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          widget.store.language == AppLanguage.khmer ? 'ទឹកប្រាក់បានទូទាត់ថ្ងៃនេះ:' : 'Amount Paid Today:',
                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: AppColors.brandEmerald),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(money(_lastAmountPaidCents), style: const TextStyle(fontWeight: FontWeight.w900, color: AppColors.brandEmerald, fontSize: 15)),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          widget.store.language == AppLanguage.khmer ? 'សមតុល្យនៅសល់ត្រូវទូទាត់:' : 'Remaining Balance Due:',
                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: AppColors.brandRed),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(money(_lastRemainingBalanceCents), style: const TextStyle(fontWeight: FontWeight.w900, color: AppColors.brandRed, fontSize: 16)),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Hotline / Concierge Help
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              decoration: BoxDecoration(
                color: const Color(0xFFF1F5F9),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Row(
                children: [
                  const Icon(Icons.headset_mic_rounded, size: 16, color: Color(0xFF475569)),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      widget.store.language == AppLanguage.khmer
                          ? 'សេវាអតិថិជន 24/7: +855 23 888 999 • ភ្នំពេញ កម្ពុជា'
                          : '24/7 Concierge Support: +855 23 888 999 • Phnom Penh Showroom',
                      style: const TextStyle(fontSize: 11, color: Color(0xFF475569), fontWeight: FontWeight.w500),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            Wrap(
              spacing: 12,
              runSpacing: 10,
              alignment: WrapAlignment.center,
              children: [
                FilledButton.icon(
                  style: FilledButton.styleFrom(
                    backgroundColor: const Color(0xFF0F172A),
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.directions_car_rounded, size: 18),
                  label: Text(
                    widget.store.language == AppLanguage.khmer ? 'ត្រឡប់ទៅកាន់ទំព័ររថយន្ត' : 'Back to Fleet Storefront',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
                OutlinedButton.icon(
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          widget.store.language == AppLanguage.khmer
                              ? 'ប័ណ្ណបញ្ជាក់ការកក់រថយន្តត្រូវបានរក្សាទុកជា PDF រួចរាល់។'
                              : 'Reservation receipt saved to PDF downloads.',
                        ),
                      ),
                    );
                  },
                  icon: const Icon(Icons.receipt_rounded, size: 18),
                  label: Text(
                    widget.store.language == AppLanguage.khmer ? 'បោះពុម្ពវិក្កយបត្រ' : 'Print / Save Receipt',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
