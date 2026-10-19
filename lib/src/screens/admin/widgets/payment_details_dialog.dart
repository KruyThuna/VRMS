import 'package:flutter/material.dart';
import '../../../../models.dart';
import '../../../../store.dart';
import '../../../shared/app_colors.dart';
import '../../../shared/smart_image.dart';
import '../../../localization/app_language.dart';
import 'payment_form_dialog.dart';

class PaymentDetailsDialog extends StatelessWidget {
  final RentalStore store;
  final Rental rental;
  final VoidCallback onUpdated;

  const PaymentDetailsDialog({
    super.key,
    required this.store,
    required this.rental,
    required this.onUpdated,
  });

  bool get isKhmer => store.language == AppLanguage.khmer;

  String _money(int cents) => '\$${(cents / 100).toStringAsFixed(2)}';

  String _date(DateTime d) =>
      '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';

  @override
  Widget build(BuildContext context) {
    final v = store.vehicle(rental.vehicleId);
    final c = store.customer(rental.customerId);
    final total = rental.totalCents;
    final paid = rental.paidCents;
    final balance = rental.balanceCents;
    final progress = total > 0 ? (paid / total).clamp(0.0, 1.0) : 0.0;

    final isPaid = balance <= 0;
    final isPartial = paid > 0 && balance > 0;

    final Color statusColor = isPaid
        ? AppColors.brandEmerald
        : isPartial
            ? AppColors.brandAmber
            : AppColors.brandRed;

    final String statusLabel = isPaid
        ? (isKhmer ? 'ទូទាត់រួចរាល់' : 'Fully Settled')
        : isPartial
            ? (isKhmer ? 'បានបង់ខ្លះ' : 'Partial Payment')
            : (isKhmer ? 'មិនទាន់ទូទាត់' : 'Payment Pending');

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
                          isKhmer ? 'វិក្កយបត្រ & បង្កាន់ដៃទទួលប្រាក់' : 'Official Payment Receipt & Invoice',
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
                            Text(
                              'REC-${rental.id}',
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.bold,
                                color: Colors.grey.shade700,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                              decoration: BoxDecoration(
                                color: statusColor.withAlpha(25),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Text(
                                statusLabel,
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.bold,
                                  color: statusColor,
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
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              const Divider(height: 1),
              const SizedBox(height: 16),

              // Content Body
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // Vehicle Card
                      Container(
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF8FAFC),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: const Color(0xFFE2E8F0)),
                        ),
                        child: Row(
                          children: [
                            ClipRRect(
                              borderRadius: BorderRadius.circular(12),
                              child: SizedBox(
                                width: 90,
                                height: 60,
                                child: SmartImage(
                                  imageSource: v.imageUrl,
                                  fit: BoxFit.cover,
                                  fallback: Container(
                                    color: Colors.grey.shade200,
                                    child: const Icon(Icons.directions_car_rounded, color: Colors.grey),
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
                                    '${v.brand} ${v.name}',
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 15,
                                      color: Color(0xFF0F172A),
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    '${isKhmer ? "ស្លាកលេខ" : "Plate"}: ${v.plate} • ${v.type}',
                                    style: TextStyle(fontSize: 12, color: Colors.grey.shade700),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    '${isKhmer ? "តម្លៃជួល" : "Rate"}: ${_money(rental.dailyCents)} / ${isKhmer ? "ថ្ងៃ" : "day"}',
                                    style: const TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w600,
                                      color: Color(0xFF0F172A),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 14),

                      // Customer Information
                      Container(
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF8FAFC),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: const Color(0xFFE2E8F0)),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              isKhmer ? 'ព័ត៌មានអតិថិជន & អ្នកជួល' : 'Renter Information',
                              style: const TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF0F172A),
                              ),
                            ),
                            const SizedBox(height: 10),
                            Row(
                              children: [
                                const Icon(Icons.person_outline_rounded, size: 16, color: Colors.grey),
                                const SizedBox(width: 6),
                                Text(
                                  c.name,
                                  style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
                                ),
                              ],
                            ),
                            const SizedBox(height: 6),
                            Wrap(
                              spacing: 16,
                              runSpacing: 6,
                              children: [
                                Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    const Icon(Icons.phone_outlined, size: 16, color: Colors.grey),
                                    const SizedBox(width: 6),
                                    Text(c.phone, style: const TextStyle(fontSize: 13)),
                                  ],
                                ),
                                Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    const Icon(Icons.email_outlined, size: 16, color: Colors.grey),
                                    const SizedBox(width: 6),
                                    Text(c.email, style: const TextStyle(fontSize: 13)),
                                  ],
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 14),

                      // Rental Duration
                      Container(
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF8FAFC),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: const Color(0xFFE2E8F0)),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  isKhmer ? 'កាលបរិច្ឆេទជួល' : 'Rental Period',
                                  style: TextStyle(fontSize: 11, color: Colors.grey.shade600),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  '${_date(rental.start)} → ${_date(rental.end)}',
                                  style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold),
                                ),
                              ],
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                              decoration: BoxDecoration(
                                color: Colors.blue.withAlpha(20),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                '${rental.days} ${isKhmer ? "ថ្ងៃ" : "Days"}',
                                style: const TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.blue,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Financial Ledger Statement Card
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              const Color(0xFF0F172A),
                              const Color(0xFF1E293B),
                            ],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          borderRadius: BorderRadius.circular(18),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  isKhmer ? 'សេចក្តីសង្ខេបហិរញ្ញវត្ថុ' : 'Financial Statement',
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 14,
                                  ),
                                ),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                  decoration: BoxDecoration(
                                    color: statusColor.withAlpha(50),
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  child: Text(
                                    statusLabel,
                                    style: TextStyle(
                                      color: statusColor,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 11,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 14),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  isKhmer ? 'តម្លៃជួលសរុប (Billed):' : 'Total Billed:',
                                  style: const TextStyle(color: Colors.white70, fontSize: 13),
                                ),
                                Text(
                                  _money(total),
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 15,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  isKhmer ? 'បានទូទាត់រួច (Paid):' : 'Amount Paid:',
                                  style: const TextStyle(color: Colors.white70, fontSize: 13),
                                ),
                                Text(
                                  _money(paid),
                                  style: const TextStyle(
                                    color: AppColors.brandEmerald,
                                    fontSize: 15,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  isKhmer ? 'សមតុល្យនៅសល់ (Balance):' : 'Balance Remaining:',
                                  style: const TextStyle(color: Colors.white70, fontSize: 13),
                                ),
                                Text(
                                  _money(balance),
                                  style: TextStyle(
                                    color: balance > 0 ? const Color(0xFFF87171) : Colors.white60,
                                    fontSize: 15,
                                    fontWeight: FontWeight.w900,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 14),
                            // Progress bar
                            ClipRRect(
                              borderRadius: BorderRadius.circular(6),
                              child: LinearProgressIndicator(
                                value: progress,
                                minHeight: 8,
                                backgroundColor: Colors.white12,
                                valueColor: AlwaysStoppedAnimation<Color>(
                                  isPaid ? AppColors.brandEmerald : AppColors.brandAmber,
                                ),
                              ),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              '${(progress * 100).toInt()}% ${isKhmer ? "បានបង់រួច" : "Paid"}',
                              textAlign: TextAlign.right,
                              style: const TextStyle(color: Colors.white60, fontSize: 11),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 14),

                      // Notes / Transactions
                      if (rental.notes.isNotEmpty) ...[
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: const Color(0xFFFFFBEB),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: const Color(0xFFFDE68A)),
                          ),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Icon(Icons.info_outline_rounded, size: 16, color: Color(0xFFD97706)),
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
                        const SizedBox(height: 16),
                      ],
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              const Divider(height: 1),
              const SizedBox(height: 16),

              // Action Buttons Row
              Wrap(
                alignment: WrapAlignment.spaceBetween,
                crossAxisAlignment: WrapCrossAlignment.center,
                spacing: 8,
                runSpacing: 8,
                children: [
                  // Left side actions: Reset & Edit
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      OutlinedButton.icon(
                        onPressed: () => _confirmReset(context),
                        icon: const Icon(Icons.refresh_rounded, size: 16, color: AppColors.brandRed),
                        label: Text(
                          isKhmer ? 'កំណត់ជា \$0' : 'Reset \$0',
                          style: const TextStyle(color: AppColors.brandRed, fontSize: 12),
                        ),
                        style: OutlinedButton.styleFrom(
                          side: BorderSide(color: AppColors.brandRed.withAlpha(100)),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                        ),
                      ),
                      const SizedBox(width: 8),
                      OutlinedButton.icon(
                        onPressed: () => _openEditDialog(context),
                        icon: const Icon(Icons.edit_outlined, size: 16),
                        label: Text(isKhmer ? 'កែសម្រួល' : 'Edit', style: const TextStyle(fontSize: 12)),
                        style: OutlinedButton.styleFrom(
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                        ),
                      ),
                    ],
                  ),

                  // Right side actions: Mark Settled / Record Payment
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (balance > 0) ...[
                        FilledButton.tonal(
                          onPressed: () async {
                            await store.settleRentalPayment(rental.id);
                            onUpdated();
                            if (context.mounted) Navigator.of(context).pop();
                          },
                          style: FilledButton.styleFrom(
                            backgroundColor: AppColors.brandEmerald.withAlpha(30),
                            foregroundColor: AppColors.brandEmerald,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                          ),
                          child: Text(
                            isKhmer ? 'ទូទាត់ពេញ' : 'Settle Full',
                            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
                          ),
                        ),
                        const SizedBox(width: 8),
                        FilledButton.icon(
                          onPressed: () => _openRecordPayment(context),
                          icon: const Icon(Icons.add_card_rounded, size: 16),
                          label: Text(
                            isKhmer ? 'កត់ត្រាការបង់ប្រាក់' : 'Add Payment',
                            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                          ),
                          style: FilledButton.styleFrom(
                            backgroundColor: AppColors.brandEmerald,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                          ),
                        ),
                      ] else ...[
                        FilledButton(
                          onPressed: () => Navigator.of(context).pop(),
                          style: FilledButton.styleFrom(
                            backgroundColor: const Color(0xFF0F172A),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
                          ),
                          child: Text(isKhmer ? 'បិទ' : 'Close'),
                        ),
                      ],
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

  void _openRecordPayment(BuildContext context) {
    Navigator.of(context).pop();
    showDialog<void>(
      context: context,
      builder: (ctx) => PaymentFormDialog(
        store: store,
        preselectedRental: rental,
        onSaved: onUpdated,
      ),
    );
  }

  void _openEditDialog(BuildContext context) {
    Navigator.of(context).pop();
    showDialog<void>(
      context: context,
      builder: (ctx) => PaymentFormDialog(
        store: store,
        preselectedRental: rental,
        isEdit: true,
        onSaved: onUpdated,
      ),
    );
  }

  void _confirmReset(BuildContext context) {
    showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(isKhmer ? 'បញ្ជាក់ការសងប្រាក់វិញ' : 'Confirm Payment Reset'),
        content: Text(
          isKhmer
              ? 'តើអ្នកចង់កំណត់ចំនួនទឹកប្រាក់ដែលបានបង់ឡើងវិញជា \$0 មែនទេ? វានឹងស្តារសមតុល្យត្រូវបង់ពេញលេញឡើងវិញ។'
              : 'Are you sure you want to reset recorded payments to \$0? This will restore the full balance due.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: Text(isKhmer ? 'បោះបង់' : 'Cancel'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: AppColors.brandRed),
            onPressed: () async {
              await store.resetRentalPayment(rental.id);
              if (ctx.mounted) Navigator.of(ctx).pop();
              onUpdated();
              if (context.mounted) Navigator.of(context).pop();
            },
            child: Text(isKhmer ? 'កំណត់ឡើងវិញ' : 'Reset to \$0'),
          ),
        ],
      ),
    );
  }
}
