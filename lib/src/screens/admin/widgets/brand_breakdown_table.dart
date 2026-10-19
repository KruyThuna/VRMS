import 'package:flutter/material.dart';
import '../../../../store.dart';
import '../../../../models.dart';
import '../../../shared/app_colors.dart';

class BrandBreakdownTable extends StatefulWidget {
  final RentalStore store;
  final ValueChanged<String> onSelectBrand;

  const BrandBreakdownTable({
    super.key,
    required this.store,
    required this.onSelectBrand,
  });

  @override
  State<BrandBreakdownTable> createState() => _BrandBreakdownTableState();
}

class _BrandBreakdownTableState extends State<BrandBreakdownTable> {
  String _filter = '';

  RentalStore get s => widget.store;

  Color _brandColor(String brand) {
    switch (brand.toUpperCase()) {
      case 'CHERY':
        return const Color(0xFFE50914);
      case 'TOYOTA':
        return const Color(0xFFDC2626);
      case 'BMW':
        return const Color(0xFF2563EB);
      case 'TESLA':
        return const Color(0xFF9333EA);
      case 'BUGATTI':
        return const Color(0xFFD97706);
      case 'HONDA':
        return const Color(0xFF0D9488);
      default:
        return const Color(0xFF4B5563);
    }
  }

  @override
  Widget build(BuildContext context) {
    final vehicles = s.vehicles;

    // Group vehicles by brand
    final Map<String, List<Vehicle>> brandGroups = {};
    for (final v in vehicles) {
      final b = v.brand.trim().toUpperCase().isEmpty ? 'UNKNOWN' : v.brand.trim().toUpperCase();
      brandGroups.putIfAbsent(b, () => []).add(v);
    }

    final brands = brandGroups.keys.where((b) {
      if (_filter.isEmpty) return true;
      return b.toLowerCase().contains(_filter.toLowerCase());
    }).toList()
      ..sort((a, b) => brandGroups[b]!.length.compareTo(brandGroups[a]!.length));

    final totalFleet = vehicles.length;
    final totalValuation = vehicles.fold<int>(0, (sum, v) => sum + v.purchasePrice);
    final totalAvailable = vehicles.where((v) => s.vehicleStatus(v) == 'Available').length;
    final totalActive = vehicles.where((v) => s.vehicleStatus(v) == 'Active' || s.vehicleStatus(v) == 'Overdue').length;

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE5E7EB)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(8),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Header Bar
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 14),
            child: LayoutBuilder(
              builder: (context, constraints) {
                final isNarrow = constraints.maxWidth < 620;
                final titleBlock = Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFEE2E2),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Icon(Icons.table_chart_rounded, color: AppColors.brandRed, size: 20),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            s.t('brand_breakdown_title'),
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w900,
                              color: AppColors.textDark,
                              letterSpacing: -0.3,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            s.t('brand_breakdown_subtitle'),
                            style: const TextStyle(fontSize: 12, color: AppColors.textMuted),
                          ),
                        ],
                      ),
                    ),
                  ],
                );

                final searchBox = SizedBox(
                  width: isNarrow ? double.infinity : 200,
                  height: 38,
                  child: TextField(
                    onChanged: (val) => setState(() => _filter = val),
                    style: const TextStyle(fontSize: 12),
                    decoration: InputDecoration(
                      hintText: s.t('filter_brand'),
                      prefixIcon: const Icon(Icons.search, size: 16, color: AppColors.textMuted),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 0),
                      filled: true,
                      fillColor: const Color(0xFFF9FAFB),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: const BorderSide(color: Color(0xFFE5E7EB)),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: const BorderSide(color: Color(0xFFE5E7EB)),
                      ),
                    ),
                  ),
                );

                if (isNarrow) {
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      titleBlock,
                      const SizedBox(height: 12),
                      searchBox,
                    ],
                  );
                }

                return Row(
                  children: [
                    Expanded(child: titleBlock),
                    const SizedBox(width: 16),
                    searchBox,
                  ],
                );
              },
            ),
          ),
          const Divider(height: 1, color: Color(0xFFF3F4F6)),

          if (brands.isEmpty)
            Padding(
              padding: const EdgeInsets.all(32),
              child: Center(
                child: Text(
                  s.t('no_brand_match'),
                  style: const TextStyle(color: AppColors.textMuted),
                ),
              ),
            )
          else
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: ConstrainedBox(
                constraints: const BoxConstraints(minWidth: 900),
                child: DataTable(
                  horizontalMargin: 20,
                  columnSpacing: 24,
                  headingRowHeight: 46,
                  dataRowMinHeight: 56,
                  dataRowMaxHeight: 64,
                  headingTextStyle: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFF6B7280),
                    letterSpacing: 0.5,
                  ),
                  columns: [
                    DataColumn(label: Text(s.t('brand').toUpperCase())),
                    DataColumn(label: Text(s.t('total_fleet').toUpperCase())),
                    DataColumn(label: Text(s.t('available_count').toUpperCase())),
                    DataColumn(label: Text(s.t('rented_count').toUpperCase())),
                    DataColumn(label: Text(s.t('utilization').toUpperCase())),
                    DataColumn(label: Text(s.t('asset_valuation').toUpperCase())),
                    DataColumn(label: Text(s.t('rate_range').toUpperCase())),
                    DataColumn(label: Text(s.t('action').toUpperCase())),
                  ],
                  rows: [
                    for (final b in brands) ...[
                      () {
                        final bList = brandGroups[b]!;
                        final count = bList.length;
                        final avail = bList.where((v) => s.vehicleStatus(v) == 'Available').length;
                        final active = bList.where((v) => s.vehicleStatus(v) == 'Active' || s.vehicleStatus(v) == 'Overdue').length;
                        final utilization = count > 0 ? (active / count * 100).round() : 0;
                        final msrp = bList.fold<int>(0, (sum, v) => sum + v.purchasePrice);
                        final rates = bList.map((v) => (v.dailyCents / 100).round()).toList()..sort();
                        final minRate = rates.first;
                        final maxRate = rates.last;
                        final rateStr = minRate == maxRate ? '\$$minRate / day' : '\$$minRate - \$$maxRate / day';
                        final cats = bList.map((v) => v.type).toSet().join(', ');

                        return DataRow(
                          cells: [
                            DataCell(
                              Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                    decoration: BoxDecoration(
                                      color: _brandColor(b).withAlpha(25),
                                      borderRadius: BorderRadius.circular(6),
                                      border: Border.all(color: _brandColor(b).withAlpha(120)),
                                    ),
                                    child: Text(
                                      b,
                                      style: TextStyle(
                                        color: _brandColor(b),
                                        fontWeight: FontWeight.w900,
                                        fontSize: 12,
                                        letterSpacing: 0.5,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    '($cats)',
                                    style: const TextStyle(fontSize: 11, color: AppColors.textMuted),
                                  ),
                                ],
                              ),
                            ),
                            DataCell(
                              Text(
                                '$count ${count > 1 ? "units" : "unit"}',
                                style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13),
                              ),
                            ),
                            DataCell(
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFECFDF5),
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: Text(
                                  '$avail ${s.t('available')}',
                                  style: const TextStyle(
                                    color: Color(0xFF047857),
                                    fontWeight: FontWeight.bold,
                                    fontSize: 11,
                                  ),
                                ),
                              ),
                            ),
                            DataCell(
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                decoration: BoxDecoration(
                                  color: active > 0 ? const Color(0xFFEFF6FF) : const Color(0xFFF3F4F6),
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: Text(
                                  '$active ${s.t('booked')}',
                                  style: TextStyle(
                                    color: active > 0 ? const Color(0xFF1D4ED8) : const Color(0xFF6B7280),
                                    fontWeight: FontWeight.bold,
                                    fontSize: 11,
                                  ),
                                ),
                              ),
                            ),
                            DataCell(
                              Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  SizedBox(
                                    width: 60,
                                    child: ClipRRect(
                                      borderRadius: BorderRadius.circular(3),
                                      child: LinearProgressIndicator(
                                        value: count > 0 ? active / count : 0.0,
                                        minHeight: 6,
                                        backgroundColor: const Color(0xFFE5E7EB),
                                        valueColor: AlwaysStoppedAnimation<Color>(
                                          utilization > 50 ? const Color(0xFF10B981) : const Color(0xFF3B82F6),
                                        ),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    '$utilization%',
                                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
                                  ),
                                ],
                              ),
                            ),
                            DataCell(
                              Text(
                                '\$${msrp.toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]},')}',
                                style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13, color: AppColors.textDark),
                              ),
                            ),
                            DataCell(
                              Text(
                                rateStr,
                                style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Color(0xFF374151)),
                              ),
                            ),
                            DataCell(
                              OutlinedButton.icon(
                                style: OutlinedButton.styleFrom(
                                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                                  side: const BorderSide(color: Color(0xFFD1D5DB)),
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                                ),
                                icon: const Icon(Icons.arrow_forward, size: 14),
                                label: Text(s.t('view_brand_fleet'), style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700)),
                                onPressed: () => widget.onSelectBrand(b),
                              ),
                            ),
                          ],
                        );
                      }(),
                    ],
                  ],
                ),
              ),
            ),

          // Total Summary Strip
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            decoration: const BoxDecoration(
              color: Color(0xFFF9FAFB),
              borderRadius: BorderRadius.vertical(bottom: Radius.circular(16)),
              border: Border(top: BorderSide(color: Color(0xFFE5E7EB))),
            ),
            child: Wrap(
              spacing: 24,
              runSpacing: 8,
              alignment: WrapAlignment.spaceBetween,
              crossAxisAlignment: WrapCrossAlignment.center,
              children: [
                Text(
                  '${s.t('total_fleet')}: $totalFleet ${totalFleet > 1 ? "vehicles" : "vehicle"} • ${brands.length} Brands active in showroom',
                  style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.textDark),
                ),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      '${s.t('inventory_summary')}: ',
                      style: const TextStyle(fontSize: 12, color: AppColors.textMuted),
                    ),
                    Text(
                      '\$${totalValuation.toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]},')}',
                      style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w900, color: AppColors.brandRed),
                    ),
                    const SizedBox(width: 14),
                    Text(
                      '• $totalAvailable ${s.t('available')} / $totalActive ${s.t('rented_count')}',
                      style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Color(0xFF047857)),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

