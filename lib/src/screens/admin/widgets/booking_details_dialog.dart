import 'package:flutter/material.dart';
import '../../../../models.dart';
import '../../../../store.dart';
import '../../../shared/app_colors.dart';
import '../../../shared/smart_image.dart';
import '../../../localization/app_language.dart';
import 'booking_form_dialog.dart';
import 'return_vehicle_dialog.dart';

class BookingDetailsDialog extends StatelessWidget {
  final RentalStore store;
  final Rental rental;
  final VoidCallback onUpdated;

  const BookingDetailsDialog({
    super.key,
    required this.store,
    required this.rental,
    required this.onUpdated,
  });

  String _t(String key) => store.t(key);

  String _date(DateTime d) =>
      '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';

  String _money(int cents) => '\$${(cents / 100).toStringAsFixed(2)}';

  @override
  Widget build(BuildContext context) {
    final v = store.vehicle(rental.vehicleId);
    final c = store.customer(rental.customerId);
    final now = DateTime.now();
    final status = rental.status(now);
    final isKhmer = store.language == AppLanguage.khmer;

    Color statusColor;
    String statusLabel;
    switch (status) {
      case 'Active':
        statusColor = AppColors.brandEmerald;
        statusLabel = isKhmer ? 'កំពុងជួល' : 'Active';
        break;
      case 'Upcoming':
        statusColor = const Color(0xFF3B82F6);
        statusLabel = isKhmer ? 'ជិតមកដល់' : 'Upcoming';
        break;
      case 'Overdue':
        statusColor = AppColors.brandRed;
        statusLabel = isKhmer ? 'ហួសកាលកំណត់' : 'Overdue';
        break;
      default:
        statusColor = const Color(0xFF64748B);
        statusLabel = isKhmer ? 'បានប្រគល់រួច' : 'Returned';
    }

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      backgroundColor: Colors.white,
      insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 620, maxHeight: 820),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Header
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: statusColor.withAlpha(25),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(Icons.receipt_long_rounded, color: statusColor, size: 24),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          rental.id,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w900,
                            letterSpacing: -0.3,
                            color: Color(0xFF0F172A),
                          ),
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                              decoration: BoxDecoration(
                                color: statusColor.withAlpha(25),
                                borderRadius: BorderRadius.circular(6),
                                border: Border.all(color: statusColor.withAlpha(80)),
                              ),
                              child: Text(
                                statusLabel,
                                style: TextStyle(
                                  color: statusColor,
                                  fontSize: 11,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                              decoration: BoxDecoration(
                                color: rental.balanceCents == 0
                                    ? AppColors.brandEmerald.withAlpha(25)
                                    : AppColors.brandRed.withAlpha(25),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Text(
                                rental.balanceCents == 0
                                    ? (isKhmer ? 'បានបង់ពេញ' : 'PAID')
                                    : (isKhmer ? 'នៅសល់សមតុល្យ' : 'UNPAID'),
                                style: TextStyle(
                                  color: rental.balanceCents == 0 ? AppColors.brandEmerald : AppColors.brandRed,
                                  fontSize: 11,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close_rounded),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              const Divider(height: 1),
              const SizedBox(height: 16),

              // Scrollable Contract Body
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // Vehicle Info Panel
                      Container(
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF8FAFC),
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(color: const Color(0xFFE2E8F0)),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                const Icon(Icons.directions_car_rounded, size: 18, color: AppColors.brandRed),
                                const SizedBox(width: 8),
                                Text(
                                  isKhmer ? 'ព័ត៌មានរថយន្ត' : 'Vehicle Specifications',
                                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Color(0xFF334155)),
                                ),
                              ],
                            ),
                            const SizedBox(height: 10),
                            Row(
                              children: [
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(10),
                                  child: Container(
                                    width: 80,
                                    height: 56,
                                    decoration: BoxDecoration(
                                      color: const Color(0xFFF1F5F9),
                                      borderRadius: BorderRadius.circular(10),
                                      border: Border.all(color: const Color(0xFFE2E8F0)),
                                    ),
                                    child: SmartImage(
                                      imageSource: v.imageUrl,
                                      fit: BoxFit.cover,
                                      fallback: const Center(
                                        child: Icon(Icons.directions_car_filled_rounded, size: 28, color: Color(0xFF0F172A)),
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
                                        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w900, color: Color(0xFF0F172A)),
                                      ),
                                      const SizedBox(height: 2),
                                      Text(
                                        '${v.brand.toUpperCase()} • ${v.type} • Plate: ${v.plate}',
                                        style: TextStyle(fontSize: 12, color: AppColors.textMuted),
                                      ),
                                    ],
                                  ),
                                ),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(8),
                                    border: Border.all(color: Colors.grey.shade300),
                                  ),
                                  child: Text(
                                    '${_money(rental.dailyCents)} / ${isKhmer ? "ថ្ងៃ" : "day"}',
                                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 14),

                      // Customer Info Panel
                      Container(
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF8FAFC),
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(color: const Color(0xFFE2E8F0)),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                const Icon(Icons.person_outline_rounded, size: 18, color: Color(0xFF3B82F6)),
                                const SizedBox(width: 8),
                                Text(
                                  isKhmer ? 'ព័ត៌មានអតិថិជន' : 'Customer Profile',
                                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Color(0xFF334155)),
                                ),
                              ],
                            ),
                            const SizedBox(height: 10),
                            Row(
                              children: [
                                CircleAvatar(
                                  radius: 18,
                                  backgroundColor: const Color(0xFF3B82F6).withAlpha(25),
                                  child: Text(
                                    c.name.isNotEmpty ? c.name[0].toUpperCase() : 'C',
                                    style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF3B82F6)),
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        c.name,
                                        style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Color(0xFF0F172A)),
                                      ),
                                      const SizedBox(height: 2),
                                      Text(
                                        '📞 ${c.phone.isNotEmpty ? c.phone : "N/A"}  •  🪪 ${c.licenseNumber.isNotEmpty ? c.licenseNumber : "N/A"}',
                                        style: TextStyle(fontSize: 12, color: AppColors.textMuted),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 14),

                      // Rental Timeline
                      Container(
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF8FAFC),
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(color: const Color(0xFFE2E8F0)),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                const Icon(Icons.calendar_month_outlined, size: 18, color: AppColors.brandEmerald),
                                const SizedBox(width: 8),
                                Text(
                                  _t('rental_period'),
                                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Color(0xFF334155)),
                                ),
                              ],
                            ),
                            const SizedBox(height: 10),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(isKhmer ? 'កាលបរិច្ឆេទចាប់ផ្តើម' : 'Start Date', style: TextStyle(fontSize: 11, color: AppColors.textMuted)),
                                    const SizedBox(height: 2),
                                    Text(_date(rental.start), style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                                  ],
                                ),
                                const Icon(Icons.arrow_forward_rounded, size: 16, color: Colors.grey),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(isKhmer ? 'កាលបរិច្ឆេទត្រឡប់' : 'End Date', style: TextStyle(fontSize: 11, color: AppColors.textMuted)),
                                    const SizedBox(height: 2),
                                    Text(_date(rental.end), style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                                  ],
                                ),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFE2E8F0),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Text(
                                    '${rental.days} ${isKhmer ? "ថ្ងៃ" : "Days"}',
                                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 14),

                      // Financial Ledger Breakdown
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF1F5F9),
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(color: const Color(0xFFCBD5E1)),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              _t('financial_summary'),
                              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Color(0xFF1E293B)),
                            ),
                            const SizedBox(height: 10),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text('${rental.days} ${isKhmer ? "ថ្ងៃ" : "Days"} × ${_money(rental.dailyCents)}:', style: TextStyle(fontSize: 13, color: AppColors.textMuted)),
                                Text(_money(rental.totalCents), style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold)),
                              ],
                            ),
                            const SizedBox(height: 6),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text('${_t('paid_deposit')}:', style: const TextStyle(fontSize: 13, color: AppColors.brandEmerald)),
                                Text(_money(rental.paidCents), style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: AppColors.brandEmerald)),
                              ],
                            ),
                            const Divider(height: 16),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text('${_t('balance_due')}:', style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w900, color: Color(0xFF0F172A))),
                                Text(
                                  _money(rental.balanceCents),
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w900,
                                    color: rental.balanceCents == 0 ? AppColors.brandEmerald : AppColors.brandRed,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),

                      if (rental.notes.isNotEmpty) ...[
                        const SizedBox(height: 14),
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: const Color(0xFFFFFBEB),
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(color: const Color(0xFFFDE68A)),
                          ),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Icon(Icons.note_alt_outlined, size: 16, color: Color(0xFFB45309)),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  rental.notes,
                                  style: const TextStyle(fontSize: 12, color: Color(0xFF92400E)),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 16),
              const Divider(height: 1),
              const SizedBox(height: 16),

              // Bottom Responsive Action Bar
              Wrap(
                alignment: WrapAlignment.spaceBetween,
                crossAxisAlignment: WrapCrossAlignment.center,
                spacing: 8,
                runSpacing: 8,
                children: [
                  // Delete Button
                  TextButton.icon(
                    style: TextButton.styleFrom(foregroundColor: AppColors.brandRed),
                    icon: const Icon(Icons.delete_outline_rounded, size: 18),
                    label: Text(_t('delete_booking')),
                    onPressed: () async {
                      if (!rental.returned && status == 'Active') {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text(_t('cannot_delete_active_booking'))),
                        );
                        return;
                      }

                      final confirmed = await showDialog<bool>(
                        context: context,
                        builder: (ctx) => AlertDialog(
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                          title: Text(_t('delete_booking')),
                          content: Text(_t('confirm_delete_booking')),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.pop(ctx, false),
                              child: Text(_t('cancel')),
                            ),
                            FilledButton(
                              style: FilledButton.styleFrom(backgroundColor: AppColors.brandRed),
                              onPressed: () => Navigator.pop(ctx, true),
                              child: Text(_t('delete')),
                            ),
                          ],
                        ),
                      );

                      if (confirmed == true) {
                        await store.deleteRental(rental.id);
                        onUpdated();
                        if (context.mounted) {
                          Navigator.pop(context);
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text(_t('booking_deleted'))),
                          );
                        }
                      }
                    },
                  ),

                  // Operations & Modals
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    crossAxisAlignment: WrapCrossAlignment.center,
                    children: [
                      // Record Payment
                      if (rental.balanceCents > 0)
                        FilledButton.tonalIcon(
                          icon: const Icon(Icons.payment_rounded, size: 16),
                          label: Text(_t('record_payment')),
                          onPressed: () async {
                            final controller = TextEditingController(
                              text: (rental.balanceCents / 100).toStringAsFixed(2),
                            );
                            final confirmed = await showDialog<bool>(
                              context: context,
                              builder: (ctx) => AlertDialog(
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                                title: Text(_t('record_payment')),
                                content: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text('${_t('balance_due')}: ${_money(rental.balanceCents)}'),
                                    const SizedBox(height: 12),
                                    TextField(
                                      controller: controller,
                                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                                      decoration: InputDecoration(
                                        labelText: _t('payment_amount'),
                                        prefixText: '\$ ',
                                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                                      ),
                                    ),
                                  ],
                                ),
                                actions: [
                                  TextButton(
                                    onPressed: () => Navigator.pop(ctx, false),
                                    child: Text(_t('cancel')),
                                  ),
                                  FilledButton(
                                    style: FilledButton.styleFrom(backgroundColor: AppColors.brandEmerald),
                                    onPressed: () => Navigator.pop(ctx, true),
                                    child: Text(_t('confirm')),
                                  ),
                                ],
                              ),
                            );

                            if (confirmed == true) {
                              final amount = double.tryParse(controller.text) ?? 0.0;
                              final amountCents = (amount * 100).round();
                              if (amountCents > 0) {
                                await store.recordRentalPayment(rental.id, amountCents);
                                onUpdated();
                                if (context.mounted) {
                                  Navigator.pop(context);
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(content: Text(_t('payment_recorded_success'))),
                                  );
                                }
                              }
                            }
                          },
                        ),

                      // Return Car
                      if (!rental.returned)
                        OutlinedButton.icon(
                          style: OutlinedButton.styleFrom(
                            foregroundColor: (rental.balanceCents > 0 || rental.status(DateTime.now()) == 'Overdue')
                                ? const Color(0xFFD97706)
                                : AppColors.brandEmerald,
                            side: BorderSide(
                              color: (rental.balanceCents > 0 || rental.status(DateTime.now()) == 'Overdue')
                                  ? const Color(0xFFF59E0B)
                                  : AppColors.brandEmerald,
                            ),
                          ),
                          icon: Icon(
                            (rental.balanceCents > 0 || rental.status(DateTime.now()) == 'Overdue')
                                ? Icons.assignment_return_rounded
                                : Icons.check_circle_outline_rounded,
                            size: 16,
                          ),
                          label: Text(_t('return_vehicle')),
                          onPressed: () async {
                            final ok = await showDialog<bool>(
                              context: context,
                              builder: (ctx) => ReturnVehicleDialog(
                                store: store,
                                rental: rental,
                                onUpdated: onUpdated,
                              ),
                            );

                            if (ok == true && context.mounted) {
                              Navigator.pop(context);
                            }
                          },
                        ),

                      // Edit Button
                      OutlinedButton.icon(
                        icon: const Icon(Icons.edit_outlined, size: 16),
                        label: Text(_t('edit_booking')),
                        onPressed: () async {
                          final updated = await showDialog<bool>(
                            context: context,
                            builder: (_) => BookingFormDialog(store: store, rental: rental),
                          );
                          if (updated == true) {
                            onUpdated();
                            if (context.mounted) Navigator.pop(context);
                          }
                        },
                      ),

                      // Close Button
                      FilledButton(
                        style: FilledButton.styleFrom(backgroundColor: const Color(0xFF0F172A)),
                        onPressed: () => Navigator.pop(context),
                        child: Text(_t('close')),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

