import 'package:flutter/material.dart';
import '../../../../store.dart';
import '../../../shared/app_colors.dart';

class CategoryAnalyticsCard extends StatelessWidget {
  final RentalStore store;
  final ValueChanged<String> onSelectCategory;

  const CategoryAnalyticsCard({
    super.key,
    required this.store,
    required this.onSelectCategory,
  });

  IconData _categoryIcon(String category) {
    switch (category.toLowerCase()) {
      case 'suv':
        return Icons.directions_car_filled_rounded;
      case 'hypercar':
      case 'sports':
        return Icons.speed_rounded;
      case 'electric':
        return Icons.electric_car_rounded;
      case 'luxury':
        return Icons.diamond_outlined;
      case 'sedan':
      case 'car':
        return Icons.directions_car_rounded;
      case 'concept':
        return Icons.auto_awesome_rounded;
      default:
        return Icons.category_rounded;
    }
  }

  Color _categoryColor(String category) {
    switch (category.toLowerCase()) {
      case 'suv':
        return const Color(0xFFE50914);
      case 'hypercar':
        return const Color(0xFFD97706);
      case 'electric':
        return const Color(0xFF10B981);
      case 'luxury':
        return const Color(0xFF8B5CF6);
      case 'sports':
        return const Color(0xFFF43F5E);
      case 'car':
      case 'sedan':
        return const Color(0xFF0284C7);
      default:
        return const Color(0xFF6B7280);
    }
  }

  @override
  Widget build(BuildContext context) {
    final s = store;
    final categories = s.categories.where((c) => c != 'All').toList();
    final vehicles = s.vehicles;

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
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 16),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: const Color(0xFFEFF6FF),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(Icons.grid_view_rounded, color: Color(0xFF2563EB), size: 20),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        s.t('category_analytics_title'),
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w900,
                          color: AppColors.textDark,
                          letterSpacing: -0.3,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        s.t('category_analytics_subtitle'),
                        style: const TextStyle(fontSize: 12, color: AppColors.textMuted),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const Divider(height: 1, color: Color(0xFFF3F4F6)),
          Padding(
            padding: const EdgeInsets.all(20),
            child: LayoutBuilder(
              builder: (context, constraints) {
                final isWide = constraints.maxWidth >= 720;
                final crossAxisCount = isWide ? 3 : (constraints.maxWidth >= 480 ? 2 : 1);

                return Wrap(
                  spacing: 16,
                  runSpacing: 16,
                  children: categories.map((cat) {
                    final catVehicles = vehicles.where((v) => v.type.toLowerCase() == cat.toLowerCase()).toList();
                    final count = catVehicles.length;
                    final avail = catVehicles.where((v) => s.vehicleStatus(v) == 'Available').length;
                    final active = catVehicles.where((v) => s.vehicleStatus(v) == 'Active' || s.vehicleStatus(v) == 'Overdue').length;
                    final avgRate = count > 0
                        ? (catVehicles.fold<int>(0, (sum, v) => sum + v.dailyCents) / count / 100).round()
                        : 0;
                    final totalMsrp = catVehicles.fold<int>(0, (sum, v) => sum + v.purchasePrice);
                    final brands = catVehicles.map((v) => v.brand.toUpperCase()).toSet().toList();
                    final color = _categoryColor(cat);

                    final itemWidth = crossAxisCount == 1
                        ? constraints.maxWidth
                        : (constraints.maxWidth - (crossAxisCount - 1) * 16) / crossAxisCount;

                    return InkWell(
                      onTap: () => onSelectCategory(cat),
                      borderRadius: BorderRadius.circular(14),
                      child: Container(
                        width: itemWidth,
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF9FAFB),
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(color: const Color(0xFFE5E7EB)),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(7),
                                  decoration: BoxDecoration(
                                    color: color.withAlpha(25),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Icon(_categoryIcon(cat), color: color, size: 18),
                                ),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: Text(
                                    cat,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.w800,
                                      fontSize: 15,
                                      color: AppColors.textDark,
                                    ),
                                  ),
                                ),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                  decoration: BoxDecoration(
                                    color: color.withAlpha(20),
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  child: Text(
                                    '$count',
                                    style: TextStyle(
                                      color: color,
                                      fontWeight: FontWeight.w900,
                                      fontSize: 12,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Expanded(
                                  child: Text(
                                    '${s.t('avg_rate')}:',
                                    style: const TextStyle(fontSize: 12, color: AppColors.textMuted),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  '\$$avgRate / day',
                                  style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.textDark),
                                ),
                              ],
                            ),
                            const SizedBox(height: 4),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Expanded(
                                  child: Text(
                                    '${s.t('asset_valuation')}:',
                                    style: const TextStyle(fontSize: 12, color: AppColors.textMuted),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  '\$${totalMsrp.toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]},')}',
                                  style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.brandRed),
                                ),
                              ],
                            ),
                            const SizedBox(height: 4),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Expanded(
                                  child: Text(
                                    '${s.t('available')}:',
                                    style: const TextStyle(fontSize: 12, color: AppColors.textMuted),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  '$avail avail • $active ${s.t('booked')}',
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                    color: avail > 0 ? const Color(0xFF047857) : Colors.red,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 10),
                            if (brands.isNotEmpty)
                              Wrap(
                                spacing: 4,
                                runSpacing: 4,
                                children: brands.take(3).map((b) => Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(4),
                                    border: Border.all(color: const Color(0xFFE5E7EB)),
                                  ),
                                  child: Text(
                                    b,
                                    style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: Color(0xFF4B5563)),
                                  ),
                                )).toList(),
                              )
                            else
                              const Text('No vehicles assigned', style: TextStyle(fontSize: 11, color: Colors.grey)),
                          ],
                        ),
                      ),
                    );
                  }).toList(),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
