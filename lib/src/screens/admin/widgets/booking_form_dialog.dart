import 'package:flutter/material.dart';
import '../../../../models.dart';
import '../../../../store.dart';
import '../../../shared/app_colors.dart';
import '../../../shared/smart_image.dart';
import '../../../localization/app_language.dart';
import '../../storefront/widgets/professional_booking_date_dialog.dart';

class BookingFormDialog extends StatefulWidget {
  final RentalStore store;
  final Rental? rental;

  const BookingFormDialog({
    super.key,
    required this.store,
    this.rental,
  });

  @override
  State<BookingFormDialog> createState() => _BookingFormDialogState();
}

class _BookingFormDialogState extends State<BookingFormDialog> {
  final _formKey = GlobalKey<FormState>();

  late String _selectedVehicleId;
  late String _selectedCustomerId;
  late DateTime _startDate;
  late DateTime _endDate;
  late TextEditingController _dailyRateController;
  late TextEditingController _paidController;
  late TextEditingController _notesController;
  late bool _returned;

  bool get isEditing => widget.rental != null;

  String _t(String key) => widget.store.t(key);

  @override
  void initState() {
    super.initState();
    final r = widget.rental;
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    _selectedVehicleId = r?.vehicleId ??
        (widget.store.vehicles.isNotEmpty ? widget.store.vehicles.first.id : '');
    _selectedCustomerId = r?.customerId ??
        (widget.store.customers.isNotEmpty ? widget.store.customers.first.id : '');

    _startDate = r?.start ?? today;
    _endDate = r?.end ?? today.add(const Duration(days: 2));

    final initialRateCents = r?.dailyCents ??
        (_selectedVehicleId.isNotEmpty
            ? widget.store.vehicle(_selectedVehicleId).dailyCents
            : 4500);

    _dailyRateController = TextEditingController(
      text: (initialRateCents / 100).toStringAsFixed(2),
    );

    _paidController = TextEditingController(
      text: r != null ? (r.paidCents / 100).toStringAsFixed(2) : '0.00',
    );

    _notesController = TextEditingController(text: r?.notes ?? '');
    _returned = r?.returned ?? false;
  }

  @override
  void dispose() {
    _dailyRateController.dispose();
    _paidController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  int get _calculatedDays {
    return DateTime.utc(_endDate.year, _endDate.month, _endDate.day)
            .difference(DateTime.utc(_startDate.year, _startDate.month, _startDate.day))
            .inDays +
        1;
  }

  double get _dailyRate => double.tryParse(_dailyRateController.text.trim()) ?? 0.0;
  double get _paidAmount => double.tryParse(_paidController.text.trim()) ?? 0.0;
  double get _totalAmount => _calculatedDays * _dailyRate;
  double get _balanceDue => (_totalAmount - _paidAmount).clamp(0.0, double.infinity);

  @override
  Widget build(BuildContext context) {
    if (widget.store.vehicles.isEmpty || widget.store.customers.isEmpty) {
      return AlertDialog(
        title: Text(isEditing ? _t('edit_booking') : _t('new_booking')),
        content: Text(
          widget.store.language == AppLanguage.khmer
              ? 'សូមបង្កើតរថយន្ត និងអតិថិជនយ៉ាងហោចមួយជាមុនសិន។'
              : 'Please add at least one vehicle and customer first.',
        ),
        actions: [
          FilledButton(
            onPressed: () => Navigator.pop(context),
            child: Text(_t('close')),
          ),
        ],
      );
    }

    final isKhmer = widget.store.language == AppLanguage.khmer;

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      backgroundColor: Colors.white,
      insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 580, maxHeight: 800),
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
                        color: AppColors.brandRed.withAlpha(25),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(
                        Icons.car_rental_rounded,
                        color: AppColors.brandRed,
                        size: 26,
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            isEditing ? _t('edit_booking') : _t('new_booking'),
                            style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.w900,
                              color: Color(0xFF0F172A),
                              letterSpacing: -0.5,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            isEditing
                                ? (isKhmer ? 'កែប្រែកិច្ចសន្យាជួលរថយន្ត' : 'Modify existing rental agreement')
                                : (isKhmer ? 'បង្កើតកិច្ចសន្យា និងការកក់រថយន្តថ្មី' : 'Create a new rental contract and reservation'),
                            style: TextStyle(fontSize: 12, color: AppColors.textMuted),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close_rounded),
                      onPressed: () => Navigator.pop(context),
                      tooltip: _t('close'),
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
                        // Vehicle Dropdown
                        Text(
                          _t('select_vehicle'),
                          style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.textMuted),
                        ),
                        const SizedBox(height: 6),
                        DropdownButtonFormField<String>(
                          initialValue: _selectedVehicleId,
                          isExpanded: true,
                          decoration: InputDecoration(
                            prefixIcon: const Icon(Icons.directions_car_outlined, size: 20),
                            contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                          ),
                          items: widget.store.vehicles.map((v) {
                            return DropdownMenuItem(
                              value: v.id,
                              child: Text(
                                '${v.name} (${v.brand.toUpperCase()} • ${v.plate})',
                                overflow: TextOverflow.ellipsis,
                              ),
                            );
                          }).toList(),
                          onChanged: (id) {
                            if (id != null) {
                              setState(() {
                                _selectedVehicleId = id;
                                final v = widget.store.vehicle(id);
                                _dailyRateController.text = (v.dailyCents / 100).toStringAsFixed(2);
                              });
                            }
                          },
                        ),
                        if (_selectedVehicleId.isNotEmpty) ...[
                          const SizedBox(height: 8),
                          Builder(
                            builder: (_) {
                              final selV = widget.store.vehicle(_selectedVehicleId);
                              return Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFF8FAFC),
                                  borderRadius: BorderRadius.circular(10),
                                  border: Border.all(color: const Color(0xFFE2E8F0)),
                                ),
                                child: Row(
                                  children: [
                                    ClipRRect(
                                      borderRadius: BorderRadius.circular(8),
                                      child: SizedBox(
                                        width: 70,
                                        height: 48,
                                        child: SmartImage(
                                          imageSource: selV.imageUrl,
                                          fit: BoxFit.cover,
                                          fallback: const Center(
                                            child: Icon(Icons.directions_car, size: 24, color: Colors.grey),
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
                                            selV.name,
                                            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                                          ),
                                          Text(
                                            '${selV.brand.toUpperCase()} • ${selV.type} • \$${(selV.dailyCents / 100).toStringAsFixed(2)} / day',
                                            style: TextStyle(fontSize: 11, color: AppColors.textMuted),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            },
                          ),
                        ],
                        const SizedBox(height: 14),

                        // Customer Dropdown
                        Text(
                          _t('select_customer'),
                          style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.textMuted),
                        ),
                        const SizedBox(height: 6),
                        DropdownButtonFormField<String>(
                          initialValue: _selectedCustomerId,
                          isExpanded: true,
                          decoration: InputDecoration(
                            prefixIcon: const Icon(Icons.person_outline_rounded, size: 20),
                            contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                          ),
                          items: widget.store.customers.map((c) {
                            return DropdownMenuItem(
                              value: c.id,
                              child: Text(
                                '${c.name} (${c.phone.isNotEmpty ? c.phone : c.id})',
                                overflow: TextOverflow.ellipsis,
                              ),
                            );
                          }).toList(),
                          onChanged: (id) {
                            if (id != null) setState(() => _selectedCustomerId = id);
                          },
                        ),
                        const SizedBox(height: 16),

                        // Date Picker Button
                        Text(
                          _t('rental_period'),
                          style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.textMuted),
                        ),
                        const SizedBox(height: 6),
                        InkWell(
                          onTap: () async {
                            final today = DateTime.now();
                            final range = await showProfessionalBookingDatePicker(
                              context: context,
                              initialStart: _startDate,
                              initialEnd: _endDate,
                              firstDate: isEditing ? _startDate : DateTime(today.year, today.month, today.day),
                            );
                            if (range != null) {
                              setState(() {
                                _startDate = range.start;
                                _endDate = range.end;
                              });
                            }
                          },
                          borderRadius: BorderRadius.circular(12),
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: Colors.grey.shade300),
                              color: const Color(0xFFF8FAFC),
                            ),
                            child: Row(
                              children: [
                                const Icon(Icons.calendar_month_outlined, color: AppColors.brandRed, size: 20),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: Text(
                                    '${_startDate.year}-${_startDate.month.toString().padLeft(2, '0')}-${_startDate.day.toString().padLeft(2, '0')} → ${_endDate.year}-${_endDate.month.toString().padLeft(2, '0')}-${_endDate.day.toString().padLeft(2, '0')} (${_calculatedDays} ${isKhmer ? 'ថ្ងៃ' : 'Days'})',
                                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                                  ),
                                ),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: AppColors.brandRed.withAlpha(20),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Text(
                                    isKhmer ? 'ផ្លាស់ប្តូរ' : 'Change',
                                    style: const TextStyle(
                                      color: AppColors.brandRed,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 11,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),

                        // Pricing Row: Daily Rate & Paid Amount
                        Row(
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    '${_t('daily_rate')} (\$)',
                                    style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.textMuted),
                                  ),
                                  const SizedBox(height: 6),
                                  TextFormField(
                                    controller: _dailyRateController,
                                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                                    decoration: InputDecoration(
                                      prefixText: '\$ ',
                                      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                                    ),
                                    onChanged: (_) => setState(() {}),
                                    validator: (val) {
                                      if (val == null || val.isEmpty) return 'Required';
                                      if (double.tryParse(val) == null) return 'Invalid';
                                      return null;
                                    },
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 14),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    _t('paid_deposit'),
                                    style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.textMuted),
                                  ),
                                  const SizedBox(height: 6),
                                  TextFormField(
                                    controller: _paidController,
                                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                                    decoration: InputDecoration(
                                      prefixText: '\$ ',
                                      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                                    ),
                                    onChanged: (_) => setState(() {}),
                                    validator: (val) {
                                      if (val == null || val.isEmpty) return 'Required';
                                      if (double.tryParse(val) == null) return 'Invalid';
                                      return null;
                                    },
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),

                        // Financial Calculation Card
                        Container(
                          padding: const EdgeInsets.all(14),
                          decoration: BoxDecoration(
                            color: const Color(0xFFF1F5F9),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: const Color(0xFFE2E8F0)),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    _t('financial_summary'),
                                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Color(0xFF334155)),
                                  ),
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                    decoration: BoxDecoration(
                                      color: _balanceDue == 0 ? AppColors.brandEmerald : AppColors.brandAmber,
                                      borderRadius: BorderRadius.circular(6),
                                    ),
                                    child: Text(
                                      _balanceDue == 0
                                          ? (isKhmer ? 'បានទូទាត់ពេញ' : 'PAID IN FULL')
                                          : (isKhmer ? 'នៅសល់សមតុល្យ' : 'BALANCE DUE'),
                                      style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 8),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text('${_calculatedDays} ${isKhmer ? "ថ្ងៃ" : "Days"} × \$${_dailyRate.toStringAsFixed(2)}:', style: TextStyle(fontSize: 12, color: AppColors.textMuted)),
                                  Text('\$${_totalAmount.toStringAsFixed(2)}', style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
                                ],
                              ),
                              const SizedBox(height: 4),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text('${_t('paid_deposit')}:', style: const TextStyle(fontSize: 12, color: AppColors.brandEmerald)),
                                  Text('\$${_paidAmount.toStringAsFixed(2)}', style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.brandEmerald)),
                                ],
                              ),
                              const Divider(height: 12),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text('${_t('balance_due')}:', style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Color(0xFF0F172A))),
                                  Text('\$${_balanceDue.toStringAsFixed(2)}', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w900, color: _balanceDue == 0 ? AppColors.brandEmerald : AppColors.brandRed)),
                                ],
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 16),

                        // If editing, provide Returned / Check-in switch
                        if (isEditing) ...[
                          SwitchListTile(
                            contentPadding: EdgeInsets.zero,
                            title: Text(
                              _t('return_vehicle'),
                              style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold),
                            ),
                            subtitle: Text(
                              isKhmer
                                  ? (_returned ? 'រថយន្តបានទទួលត្រឡប់រួចរាល់' : 'រថយន្តកំពុងស្ថិតក្នុងការជួល')
                                  : (_returned ? 'Vehicle has been checked in / returned' : 'Vehicle is currently out on rent'),
                              style: TextStyle(fontSize: 11, color: AppColors.textMuted),
                            ),
                            value: _returned,
                            activeThumbColor: AppColors.brandEmerald,
                            onChanged: (val) => setState(() => _returned = val),
                          ),
                          const SizedBox(height: 10),
                        ],

                        // Notes Input
                        Text(
                          _t('customer_notes'),
                          style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.textMuted),
                        ),
                        const SizedBox(height: 6),
                        TextFormField(
                          controller: _notesController,
                          maxLines: 2,
                          decoration: InputDecoration(
                            hintText: isKhmer
                                ? 'បញ្ចូលកំណត់សម្គាល់ពិសេស (ឧ. កក់តាមទូរស័ព្ទ, ត្រូវការអ្នកបើកបរ)...'
                                : 'Special instructions, security deposit notes, delivery details...',
                            contentPadding: const EdgeInsets.all(12),
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 16),
                const Divider(height: 1),
                const SizedBox(height: 16),

                // Dialog Actions (Cancel & Save)
                Wrap(
                  alignment: WrapAlignment.end,
                  spacing: 10,
                  runSpacing: 8,
                  children: [
                    OutlinedButton(
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      ),
                      onPressed: () => Navigator.pop(context, false),
                      child: Text(_t('cancel')),
                    ),
                    FilledButton(
                      style: FilledButton.styleFrom(
                        backgroundColor: AppColors.brandRed,
                        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      ),
                      onPressed: () async {
                        if (!_formKey.currentState!.validate()) return;

                        final dailyCents = (_dailyRate * 100).round();
                        final paidCents = (_paidAmount * 100).round();
                        final notes = _notesController.text.trim();

                        if (isEditing) {
                          final updated = widget.rental!.copyWith(
                            vehicleId: _selectedVehicleId,
                            customerId: _selectedCustomerId,
                            start: _startDate,
                            end: _endDate,
                            dailyCents: dailyCents,
                            paidCents: paidCents,
                            returned: _returned,
                            notes: notes,
                          );
                          await widget.store.updateRental(updated);
                        } else {
                          final newRental = Rental(
                            widget.store.newId('R'),
                            _selectedVehicleId,
                            _selectedCustomerId,
                            _startDate,
                            _endDate,
                            dailyCents,
                            paidCents: paidCents,
                            returned: _returned,
                            notes: notes,
                          );
                          await widget.store.addRental(newRental);
                        }

                        if (context.mounted) {
                          Navigator.pop(context, true);
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text(_t('booking_saved'))),
                          );
                        }
                      },
                      child: Text(
                        isEditing
                            ? (isKhmer ? 'រក្សាទុកការកែប្រែ' : 'Update Booking')
                            : (isKhmer ? 'បង្កើតការកក់ថ្មី' : 'Create Booking'),
                        style: const TextStyle(fontWeight: FontWeight.bold),
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
