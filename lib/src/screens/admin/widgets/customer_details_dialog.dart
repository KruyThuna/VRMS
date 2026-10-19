import 'package:flutter/material.dart';
import '../../../../models.dart';
import '../../../../store.dart';
import '../../../shared/app_colors.dart';
import '../../../shared/smart_image.dart';
import '../../../localization/app_language.dart';
import 'customer_form_dialog.dart';

class CustomerDetailsDialog extends StatelessWidget {
  final RentalStore store;
  final Customer customer;
  final VoidCallback onUpdated;

  const CustomerDetailsDialog({
    super.key,
    required this.store,
    required this.customer,
    required this.onUpdated,
  });

  String _t(String key) => store.t(key);

  @override
  Widget build(BuildContext context) {
    final rentals = store.rentalsForCustomer(customer.id);
    final totalSpentCents = store.customerTotalSpend(customer.id);
    final activeCount = store.customerActiveRentals(customer.id);

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      backgroundColor: Colors.white,
      surfaceTintColor: Colors.transparent,
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 620, maxHeight: 720),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Header
              Row(
                children: [
                  CircleAvatar(
                    radius: 26,
                    backgroundColor: AppColors.brandRed.withAlpha(25),
                    child: Text(
                      customer.name.isNotEmpty ? customer.name[0].toUpperCase() : '?',
                      style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 20, color: AppColors.brandRed),
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Flexible(
                              child: Text(
                                customer.name,
                                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w900, color: Color(0xFF0F172A)),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                              decoration: BoxDecoration(
                                color: const Color(0xFFF1F5F9),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Text(
                                customer.id,
                                style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Color(0xFF475569)),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 3),
                        Text(
                          '${customer.phone}${customer.email.isNotEmpty ? " • ${customer.email}" : ""}',
                          style: const TextStyle(fontSize: 12, color: Color(0xFF64748B), fontWeight: FontWeight.w500),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.of(context).pop(),
                    icon: const Icon(Icons.close_rounded, color: Color(0xFF94A3B8)),
                  ),
                ],
              ),
              const Divider(height: 24),

              // Telemetry KPI Cards
              Row(
                children: [
                  Expanded(
                    child: _buildMetricCard(
                      label: store.language == AppLanguage.khmer ? 'ការកក់សរុប' : 'Total Bookings',
                      value: '${rentals.length}',
                      icon: Icons.calendar_today_rounded,
                      color: const Color(0xFF2563EB),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: _buildMetricCard(
                      label: store.language == AppLanguage.khmer ? 'ការជួលសកម្ម' : 'Active Rentals',
                      value: '$activeCount',
                      icon: Icons.directions_car_rounded,
                      color: activeCount > 0 ? AppColors.brandEmerald : const Color(0xFF64748B),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: _buildMetricCard(
                      label: store.language == AppLanguage.khmer ? 'ចំណាយសរុប' : 'Total Spent',
                      value: money(totalSpentCents),
                      icon: Icons.payments_rounded,
                      color: AppColors.brandRed,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Additional Details (License & Location & Notes)
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color(0xFFF8FAFC),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: const Color(0xFFE2E8F0)),
                ),
                child: Column(
                  children: [
                    if (customer.licenseNumber.isNotEmpty)
                      _buildInfoRow(
                        Icons.badge_outlined,
                        _t('driver_license'),
                        customer.licenseNumber,
                      ),
                    if (customer.address.isNotEmpty) ...[
                      if (customer.licenseNumber.isNotEmpty) const Divider(height: 12),
                      _buildInfoRow(
                        Icons.location_on_outlined,
                        _t('customer_address'),
                        customer.address,
                      ),
                    ],
                    if (customer.notes.isNotEmpty) ...[
                      if (customer.licenseNumber.isNotEmpty || customer.address.isNotEmpty)
                        const Divider(height: 12),
                      _buildInfoRow(
                        Icons.note_alt_outlined,
                        _t('customer_notes'),
                        customer.notes,
                      ),
                    ],
                    if (customer.licenseNumber.isEmpty && customer.address.isEmpty && customer.notes.isEmpty)
                      Row(
                        children: [
                          const Icon(Icons.info_outline_rounded, size: 16, color: Color(0xFF94A3B8)),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              store.language == AppLanguage.khmer
                                  ? 'គ្មានប័ណ្ណបើកបរ ឬព័ត៌មានបន្ថែមទេ។ ចុច "កែសម្រួល" ដើម្បីបំពេញ។'
                                  : 'No driver license or notes added. Tap "Edit" to enrich profile.',
                              style: const TextStyle(fontSize: 11, color: Color(0xFF94A3B8)),
                            ),
                          ),
                        ],
                      ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // Rental History Section Title
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    _t('customer_details'),
                    style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 13, color: Color(0xFF0F172A)),
                  ),
                  Text(
                    '${rentals.length} ${store.language == AppLanguage.khmer ? "កំណត់ត្រា" : "records"}',
                    style: const TextStyle(fontSize: 11, color: Color(0xFF64748B)),
                  ),
                ],
              ),
              const SizedBox(height: 8),

              // Rental History List
              Expanded(
                child: rentals.isEmpty
                    ? Center(
                        child: Text(
                          _t('no_bookings_history'),
                          style: const TextStyle(color: Color(0xFF94A3B8), fontSize: 12),
                        ),
                      )
                    : ListView.separated(
                        itemCount: rentals.length,
                        separatorBuilder: (_, __) => const SizedBox(height: 8),
                        itemBuilder: (context, idx) {
                          final r = rentals[idx];
                          final vehicle = store.vehicle(r.vehicleId);
                          final now = DateTime.now();
                          final status = r.status(now).toLowerCase();

                          Color statusColor;
                          String statusText;
                          if (status == 'active') {
                            statusColor = AppColors.brandEmerald;
                            statusText = store.language == AppLanguage.khmer ? 'កំពុងជួល' : 'Active';
                          } else if (status == 'upcoming') {
                            statusColor = const Color(0xFF2563EB);
                            statusText = store.language == AppLanguage.khmer ? 'ការកក់ទុក' : 'Upcoming';
                          } else if (status == 'overdue') {
                            statusColor = AppColors.brandRed;
                            statusText = store.language == AppLanguage.khmer ? 'ហួសកំណត់' : 'Overdue';
                          } else {
                            statusColor = const Color(0xFF64748B);
                            statusText = store.language == AppLanguage.khmer ? 'បានប្រគល់' : 'Returned';
                          }

                          return Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(color: const Color(0xFFE2E8F0)),
                            ),
                            child: Row(
                              children: [
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(6),
                                  child: SizedBox(
                                    width: 44,
                                    height: 32,
                                    child: SmartImage(
                                      imageSource: vehicle.imageUrl,
                                      fallback: Container(
                                        color: const Color(0xFFF1F5F9),
                                        child: const Icon(Icons.directions_car, size: 20, color: Color(0xFF64748B)),
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        children: [
                                          Text(
                                            vehicle.name,
                                            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Color(0xFF0F172A)),
                                          ),
                                          const SizedBox(width: 6),
                                          Container(
                                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
                                            decoration: BoxDecoration(
                                              color: statusColor.withAlpha(20),
                                              borderRadius: BorderRadius.circular(4),
                                            ),
                                            child: Text(
                                              statusText,
                                              style: TextStyle(color: statusColor, fontSize: 9, fontWeight: FontWeight.bold),
                                            ),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 2),
                                      Text(
                                        '${formattedDate(r.start)} ➔ ${formattedDate(r.end)} • ${money(r.dailyCents)}/d',
                                        style: const TextStyle(fontSize: 11, color: Color(0xFF64748B)),
                                      ),
                                    ],
                                  ),
                                ),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.end,
                                  children: [
                                    Text(
                                      money(r.totalCents),
                                      style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 13, color: Color(0xFF0F172A)),
                                    ),
                                    Text(
                                      r.balanceCents == 0
                                          ? (store.language == AppLanguage.khmer ? 'បានទូទាត់ពេញ' : 'Paid in Full')
                                          : '${store.language == AppLanguage.khmer ? "ជំពាក់" : "Bal:"} ${money(r.balanceCents)}',
                                      style: TextStyle(
                                        fontSize: 10,
                                        fontWeight: FontWeight.w600,
                                        color: r.balanceCents == 0 ? AppColors.brandEmerald : AppColors.brandRed,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          );
                        },
                      ),
              ),

              const Divider(height: 24),
              // Bottom Action Bar: Delete, Edit, Close
              Wrap(
                alignment: WrapAlignment.spaceBetween,
                crossAxisAlignment: WrapCrossAlignment.center,
                spacing: 8,
                runSpacing: 8,
                children: [
                  TextButton.icon(
                    style: TextButton.styleFrom(foregroundColor: AppColors.brandRed),
                    icon: const Icon(Icons.delete_outline_rounded, size: 18),
                    label: Text(_t('delete_customer')),
                    onPressed: () async {
                      if (activeCount > 0) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text(_t('cannot_delete_active_customer'))),
                        );
                        return;
                      }

                      final confirmed = await showDialog<bool>(
                        context: context,
                        builder: (ctx) => AlertDialog(
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                          title: Text(_t('delete_customer')),
                          content: Text(_t('confirm_delete_customer')),
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
                        await store.deleteCustomer(customer.id);
                        onUpdated();
                        if (context.mounted) {
                          Navigator.of(context).pop();
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text(_t('customer_deleted'))),
                          );
                        }
                      }
                    },
                  ),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    crossAxisAlignment: WrapCrossAlignment.center,
                    children: [
                      OutlinedButton.icon(
                        onPressed: () async {
                          final updated = await showDialog<bool>(
                            context: context,
                            builder: (_) => CustomerFormDialog(store: store, customer: customer),
                          );
                          if (updated == true) {
                            onUpdated();
                            if (context.mounted) Navigator.of(context).pop();
                          }
                        },
                        icon: const Icon(Icons.edit_outlined, size: 16),
                        label: Text(_t('edit_customer')),
                      ),
                      FilledButton(
                        style: FilledButton.styleFrom(backgroundColor: const Color(0xFF0F172A)),
                        onPressed: () => Navigator.of(context).pop(),
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

  Widget _buildMetricCard({
    required String label,
    required String value,
    required IconData icon,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: color.withAlpha(15),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: color.withAlpha(40)),
      ),
      child: Row(
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  value,
                  style: TextStyle(fontWeight: FontWeight.w900, fontSize: 14, color: color),
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  label,
                  style: const TextStyle(fontSize: 10, color: Color(0xFF64748B), fontWeight: FontWeight.w600),
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 16, color: const Color(0xFF64748B)),
        const SizedBox(width: 8),
        Text(
          '$label: ',
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 11, color: Color(0xFF475569)),
        ),
        Expanded(
          child: Text(
            value,
            style: const TextStyle(fontSize: 11, color: Color(0xFF0F172A), fontWeight: FontWeight.w600),
          ),
        ),
      ],
    );
  }
}
