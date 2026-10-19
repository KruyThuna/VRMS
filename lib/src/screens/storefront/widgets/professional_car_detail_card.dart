import 'package:flutter/material.dart';
import '../../../models/vehicle.dart';
import '../../../models/formatters.dart';
import '../../../shared/app_colors.dart';
import '../../../shared/smart_image.dart';
import '../../../shared/vehicle_art.dart';
import '../../../localization/app_language.dart';
import '../../../localization/app_translations.dart';

class ProfessionalCarDetailCard extends StatelessWidget {
  final Vehicle vehicle;
  final bool isInCart;
  final bool isAvailable;
  final String? vehicleStatus;
  final VoidCallback onAddToCart;
  final VoidCallback onClose;
  final AppLanguage language;

  const ProfessionalCarDetailCard({
    super.key,
    required this.vehicle,
    this.isInCart = false,
    this.isAvailable = true,
    this.vehicleStatus,
    required this.onAddToCart,
    required this.onClose,
    this.language = AppLanguage.english,
  });

  String _t(String key) => AppTranslations.tr(key, language);

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.sizeOf(context).width;
    final isHorizontal = screenWidth >= 780;
    final resolvedStatus = vehicleStatus ?? (vehicle.maintenance ? 'Maintenance' : 'Available');
    final isMaintenance = resolvedStatus == 'Maintenance' || vehicle.maintenance;
    final isRented = resolvedStatus == 'Rented' || (!isAvailable && !isMaintenance);

    final String? resolvedImage = (vehicle.imageUrl != null && vehicle.imageUrl!.trim().isNotEmpty && vehicle.imageUrl!.trim().toLowerCase() != 'null')
        ? vehicle.imageUrl!.trim()
        : (vehicle.id == 'v_tiggo9' || vehicle.name.toLowerCase().contains('tiggo')
            ? 'assets/images/tiggo9_banner.png'
            : (vehicle.id == 'v0' || vehicle.name.toLowerCase().contains('bugatti')
                ? 'https://images.unsplash.com/photo-1617788138017-80ad40651399?w=1200&q=80'
                : (vehicle.id == 'v5' || vehicle.name.toLowerCase().contains('tesla')
                    ? 'https://images.unsplash.com/photo-1560958089-b8a1929cea89?w=1200&q=80'
                    : (vehicle.id == 'v6' || vehicle.name.toLowerCase().contains('bmw')
                        ? 'https://images.unsplash.com/photo-1555215695-3004980ad54e?w=1200&q=80'
                        : null))));

    final safeBrand = (vehicle.brand.isNotEmpty && vehicle.brand.toLowerCase() != 'null') ? vehicle.brand : 'DRIVELINE';
    final safeType = (vehicle.type.isNotEmpty && vehicle.type.toLowerCase() != 'null') ? vehicle.type.toUpperCase() : 'CAR';

    return Center(
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxWidth: isHorizontal ? 960 : 520,
          maxHeight: isHorizontal ? 680 : 880,
        ),
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: AppColors.lightBorder),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withAlpha(40),
                blurRadius: 36,
                offset: const Offset(0, 12),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Top Header with Close Button
                Padding(
                  padding: const EdgeInsets.fromLTRB(24, 16, 16, 12),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF3F4F6),
                          borderRadius: BorderRadius.circular(6),
                          border: Border.all(color: const Color(0xFFE5E7EB)),
                        ),
                        child: Text(
                          '$safeBrand • $safeType',
                          style: const TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w800,
                            color: Color(0xFF4B5563),
                            letterSpacing: 0.5,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: isMaintenance
                              ? const Color(0xFFFEF3C7)
                              : (isRented ? const Color(0xFFFFE4E6) : const Color(0xFFD1FAE5)),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Container(
                              width: 6,
                              height: 6,
                              decoration: BoxDecoration(
                                color: isMaintenance
                                    ? const Color(0xFFD97706)
                                    : (isRented ? const Color(0xFFE11D48) : const Color(0xFF059669)),
                                shape: BoxShape.circle,
                              ),
                            ),
                            const SizedBox(width: 5),
                            Text(
                              isMaintenance
                                  ? _t('in_maintenance')
                                  : (isRented ? _t('stock_badge_rented') : _t('available_for_booking')),
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                                color: isMaintenance
                                    ? const Color(0xFF92400E)
                                    : (isRented ? const Color(0xFF9F1239) : const Color(0xFF065F46)),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const Spacer(),
                      IconButton(
                        style: IconButton.styleFrom(
                          backgroundColor: const Color(0xFFF3F4F6),
                          padding: const EdgeInsets.all(8),
                        ),
                        icon: const Icon(Icons.close_rounded, size: 20, color: Color(0xFF4B5563)),
                        tooltip: _t('close'),
                        onPressed: onClose,
                      ),
                    ],
                  ),
                ),

                const Divider(color: AppColors.lightBorder, height: 1),

                // Main Content Body (Horizontal 2-Column or Vertical Stack)
                Flexible(
                  child: isHorizontal
                      ? Row(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            // LEFT COLUMN: Showcase & Booking Callout
                            Expanded(
                              flex: 5,
                              child: Padding(
                                padding: const EdgeInsets.fromLTRB(24, 20, 16, 20),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.stretch,
                                  children: [
                                    // Vehicle Title
                                    Text(
                                      vehicle.name.isNotEmpty && vehicle.name.toLowerCase() != 'null' ? vehicle.name : 'Vehicle',
                                      style: const TextStyle(
                                        fontSize: 24,
                                        fontWeight: FontWeight.w900,
                                        color: Color(0xFF111827),
                                        letterSpacing: -0.5,
                                      ),
                                    ),
                                    const SizedBox(height: 2),
                                    Text(
                                      (vehicle.tagline.isNotEmpty && vehicle.tagline.toLowerCase() != 'null') ? vehicle.tagline : _t('flagship_luxury'),
                                      style: const TextStyle(
                                        fontSize: 11,
                                        fontWeight: FontWeight.w600,
                                        color: Color(0xFF6B7280),
                                      ),
                                    ),
                                    const SizedBox(height: 14),

                                    // Studio Showcase Stage
                                    Expanded(
                                      child: Container(
                                        decoration: BoxDecoration(
                                          gradient: const LinearGradient(
                                            begin: Alignment.topCenter,
                                            end: Alignment.bottomCenter,
                                            colors: [Color(0xFF0F172A), Color(0xFF1E293B)],
                                          ),
                                          borderRadius: BorderRadius.circular(16),
                                          border: Border.all(color: const Color(0xFF334155)),
                                          boxShadow: [
                                            BoxShadow(
                                              color: Colors.black.withAlpha(50),
                                              blurRadius: 16,
                                              offset: const Offset(0, 4),
                                            ),
                                          ],
                                        ),
                                        child: ClipRRect(
                                          borderRadius: BorderRadius.circular(16),
                                          child: Stack(
                                            alignment: Alignment.center,
                                            children: [
                                              // Vehicle photo from banner / post
                                              Positioned.fill(
                                                child: SmartImage(
                                                  imageSource: resolvedImage,
                                                  fit: BoxFit.cover,
                                                  fallback: VehicleArt(
                                                    type: vehicle.type,
                                                    color: Colors.white,
                                                  ),
                                                ),
                                              ),
                                              // Subtle gradient overlay to ensure badges pop
                                              Positioned.fill(
                                                child: DecoratedBox(
                                                  decoration: BoxDecoration(
                                                    gradient: LinearGradient(
                                                      begin: Alignment.topCenter,
                                                      end: Alignment.bottomCenter,
                                                      colors: [
                                                        Colors.black.withAlpha(60),
                                                        Colors.transparent,
                                                        Colors.black.withAlpha(100),
                                                      ],
                                                    ),
                                                  ),
                                                ),
                                              ),
                                              // 360° Studio Showcase Badge
                                              Positioned(
                                                top: 12,
                                                left: 12,
                                                child: Container(
                                                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                                                  decoration: BoxDecoration(
                                                    color: Colors.black.withAlpha(200),
                                                    borderRadius: BorderRadius.circular(20),
                                                    border: Border.all(color: const Color(0xFF38BDF8).withAlpha(180), width: 1.2),
                                                    boxShadow: [
                                                      BoxShadow(
                                                        color: const Color(0xFF0284C7).withAlpha(60),
                                                        blurRadius: 8,
                                                        offset: const Offset(0, 2),
                                                      ),
                                                    ],
                                                  ),
                                                  child: Row(
                                                    mainAxisSize: MainAxisSize.min,
                                                    children: [
                                                      const Icon(Icons.threed_rotation_rounded, size: 14, color: Color(0xFF38BDF8)),
                                                      const SizedBox(width: 6),
                                                      Text(
                                                        _t('studio_view_360'),
                                                        style: const TextStyle(
                                                          color: Colors.white,
                                                          fontSize: 10,
                                                          fontWeight: FontWeight.w900,
                                                          letterSpacing: 1.0,
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                              ),
                                              // MSRP Badge
                                              Positioned(
                                                bottom: 12,
                                                right: 12,
                                                child: Container(
                                                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                                                  decoration: BoxDecoration(
                                                    color: Colors.black.withAlpha(190),
                                                    borderRadius: BorderRadius.circular(8),
                                                    border: Border.all(color: Colors.white24),
                                                  ),
                                                  child: Text(
                                                    '${_t('security_deposit')}: \$${(vehicle.dailyCents * 3 ~/ 100).clamp(100, 500)} • ${_t('fully_insured')}',
                                                    style: const TextStyle(
                                                      fontSize: 11,
                                                      fontWeight: FontWeight.w800,
                                                      color: Colors.white,
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ),

                                    const SizedBox(height: 16),

                                    // Left Column Footer: Rate & Action Button
                                    Container(
                                      padding: const EdgeInsets.all(14),
                                      decoration: BoxDecoration(
                                        color: const Color(0xFFF9FAFB),
                                        borderRadius: BorderRadius.circular(16),
                                        border: Border.all(color: const Color(0xFFE5E7EB)),
                                      ),
                                      child: LayoutBuilder(
                                        builder: (context, c) {
                                          if (c.maxWidth < 500) {
                                            return Column(
                                              crossAxisAlignment: CrossAxisAlignment.stretch,
                                              children: [
                                                Row(
                                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                  children: [
                                                    Text(
                                                      _t('daily_rate'),
                                                      style: const TextStyle(fontSize: 10, color: Color(0xFF6B7280), fontWeight: FontWeight.bold),
                                                    ),
                                                    Row(
                                                      crossAxisAlignment: CrossAxisAlignment.baseline,
                                                      textBaseline: TextBaseline.alphabetic,
                                                      children: [
                                                        Text(
                                                          money(vehicle.dailyCents),
                                                          style: const TextStyle(
                                                            fontSize: 20,
                                                            fontWeight: FontWeight.w900,
                                                            color: AppColors.brandRed,
                                                          ),
                                                        ),
                                                        const SizedBox(width: 4),
                                                        Text(
                                                          _t('per_day'),
                                                          style: const TextStyle(fontSize: 11, color: Color(0xFF6B7280), fontWeight: FontWeight.bold),
                                                        ),
                                                      ],
                                                    ),
                                                  ],
                                                ),
                                                const SizedBox(height: 10),
                                                FilledButton.icon(
                                                  icon: Icon(
                                                    isInCart ? Icons.check_circle_rounded : Icons.add_shopping_cart_rounded,
                                                    size: 16,
                                                  ),
                                                  style: FilledButton.styleFrom(
                                                    backgroundColor: isInCart ? AppColors.brandEmerald : AppColors.brandRed,
                                                    foregroundColor: Colors.white,
                                                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                                                    elevation: 0,
                                                  ),
                                                  onPressed: onAddToCart,
                                                  label: Text(
                                                    isInCart ? _t('in_reservation_cart') : _t('add_to_cart'),
                                                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                                                  ),
                                                ),
                                              ],
                                            );
                                          }

                                          return Row(
                                            children: [
                                              Column(
                                                crossAxisAlignment: CrossAxisAlignment.start,
                                                children: [
                                                  Text(
                                                    _t('daily_rate'),
                                                    style: const TextStyle(fontSize: 10, color: Color(0xFF6B7280), fontWeight: FontWeight.bold),
                                                  ),
                                                  Row(
                                                    crossAxisAlignment: CrossAxisAlignment.baseline,
                                                    textBaseline: TextBaseline.alphabetic,
                                                    children: [
                                                      Text(
                                                        money(vehicle.dailyCents),
                                                        style: const TextStyle(
                                                          fontSize: 22,
                                                          fontWeight: FontWeight.w900,
                                                          color: AppColors.brandRed,
                                                        ),
                                                      ),
                                                      const SizedBox(width: 4),
                                                      Text(
                                                        _t('per_day'),
                                                        style: const TextStyle(fontSize: 11, color: Color(0xFF6B7280), fontWeight: FontWeight.bold),
                                                      ),
                                                    ],
                                                  ),
                                                ],
                                              ),
                                              const Spacer(),
                                              FilledButton.icon(
                                                icon: Icon(
                                                  !isAvailable
                                                      ? Icons.event_busy_rounded
                                                      : (isInCart ? Icons.check_circle_rounded : Icons.add_shopping_cart_rounded),
                                                  size: 16,
                                                ),
                                                style: FilledButton.styleFrom(
                                                  backgroundColor: !isAvailable
                                                      ? const Color(0xFFE11D48)
                                                      : (isInCart ? AppColors.brandEmerald : AppColors.brandRed),
                                                  foregroundColor: Colors.white,
                                                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                                                  elevation: 0,
                                                ),
                                                onPressed: onAddToCart,
                                                label: Text(
                                                  !isAvailable
                                                      ? _t('stock_badge_rented')
                                                      : (isInCart ? _t('in_reservation_cart') : _t('add_to_cart')),
                                                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                                                ),
                                              ),
                                            ],
                                          );
                                        },
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),

                            const VerticalDivider(color: AppColors.lightBorder, width: 1),

                            // RIGHT COLUMN: Specs, Highlights, Attributes & Guarantees
                            Expanded(
                              flex: 5,
                              child: SingleChildScrollView(
                                padding: const EdgeInsets.fromLTRB(20, 20, 24, 20),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.stretch,
                                  children: [
                                    _buildSectionHeader(_t('performance_specs'), AppColors.brandRed),
                                    const SizedBox(height: 10),
                                    Row(
                                      children: [
                                        _buildSpecTile(Icons.tune_rounded, _t('engine_upper'), vehicle.engine.isNotEmpty ? vehicle.engine : '2.0L TURBO'),
                                        const SizedBox(width: 8),
                                        _buildSpecTile(Icons.bolt_rounded, _t('power_upper'), vehicle.horsepower.isNotEmpty ? vehicle.horsepower : '250 HP'),
                                        const SizedBox(width: 8),
                                        _buildSpecTile(Icons.speed_rounded, _t('speed_upper'), vehicle.topSpeed.isNotEmpty ? vehicle.topSpeed : '220 KM/H'),
                                        const SizedBox(width: 8),
                                        _buildSpecTile(Icons.timer_outlined, _t('accel_upper'), vehicle.acceleration.isNotEmpty ? vehicle.acceleration : '6.5s'),
                                      ],
                                    ),

                                    const SizedBox(height: 16),

                                    _buildSectionHeader(_t('vehicle_attributes'), AppColors.darkBg),
                                    const SizedBox(height: 8),
                                    Row(
                                      children: [
                                        _buildAttributeChip(Icons.airline_seat_recline_extra_rounded, '${vehicle.seats} ${_t('seats')}'),
                                        const SizedBox(width: 6),
                                        _buildAttributeChip(Icons.settings_suggest_rounded, vehicle.transmission),
                                        const SizedBox(width: 6),
                                        _buildAttributeChip(Icons.local_gas_station_rounded, vehicle.fuel),
                                        const SizedBox(width: 6),
                                        _buildAttributeChip(Icons.calendar_today_rounded, '${_t('year_prefix')} ${vehicle.year}'),
                                      ],
                                    ),

                                    const SizedBox(height: 16),

                                    _buildSectionHeader(_t('design_tech_highlights'), const Color(0xFF2563EB)),
                                    const SizedBox(height: 8),
                                    for (final highlight in vehicle.designHighlights)
                                      Padding(
                                        padding: const EdgeInsets.only(bottom: 6),
                                        child: Container(
                                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
                                          decoration: BoxDecoration(
                                            color: const Color(0xFFF9FAFB),
                                            borderRadius: BorderRadius.circular(8),
                                            border: Border.all(color: const Color(0xFFE5E7EB)),
                                          ),
                                          child: Row(
                                            children: [
                                              const Icon(Icons.check_circle_rounded, color: AppColors.brandEmerald, size: 15),
                                              const SizedBox(width: 8),
                                              Expanded(
                                                child: Text(
                                                  highlight,
                                                  style: const TextStyle(
                                                    fontSize: 11,
                                                    fontWeight: FontWeight.w700,
                                                    color: Color(0xFF374151),
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),

                                    const SizedBox(height: 14),

                                    _buildSectionHeader(_t('rental_guarantees'), const Color(0xFF059669)),
                                    const SizedBox(height: 8),
                                    Container(
                                      padding: const EdgeInsets.all(10),
                                      decoration: BoxDecoration(
                                        color: const Color(0xFFF0FDF4),
                                        borderRadius: BorderRadius.circular(10),
                                        border: Border.all(color: const Color(0xFFBBF7D0)),
                                      ),
                                      child: Column(
                                        children: [
                                          _buildAssuranceRow(Icons.verified_user_outlined, _t('full_insurance_desc')),
                                          const SizedBox(height: 5),
                                          _buildAssuranceRow(Icons.cleaning_services_outlined, _t('sanitized_inspection')),
                                          const SizedBox(height: 5),
                                          _buildAssuranceRow(Icons.flight_takeoff_rounded, _t('free_vip_delivery')),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        )
                      : SingleChildScrollView(
                          // Vertical responsive fallback for small screens
                          padding: const EdgeInsets.all(20),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              Text(
                                vehicle.name,
                                style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w900, color: Color(0xFF111827)),
                              ),
                              const SizedBox(height: 12),
                              Container(
                                height: 200,
                                decoration: BoxDecoration(
                                  gradient: const LinearGradient(
                                    begin: Alignment.topCenter,
                                    end: Alignment.bottomCenter,
                                    colors: [Color(0xFF0F172A), Color(0xFF1E293B)],
                                  ),
                                  borderRadius: BorderRadius.circular(16),
                                  border: Border.all(color: const Color(0xFF334155)),
                                ),
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(16),
                                  child: Stack(
                                    alignment: Alignment.center,
                                    children: [
                                      Positioned.fill(
                                        child: SmartImage(
                                          imageSource: resolvedImage,
                                          fit: BoxFit.cover,
                                          fallback: VehicleArt(
                                            type: vehicle.type,
                                            color: Colors.white,
                                          ),
                                        ),
                                      ),
                                      Positioned(
                                        top: 10,
                                        left: 10,
                                        child: Container(
                                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                          decoration: BoxDecoration(
                                            color: Colors.black.withAlpha(200),
                                            borderRadius: BorderRadius.circular(20),
                                            border: Border.all(color: const Color(0xFF38BDF8).withAlpha(180)),
                                          ),
                                          child: Row(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              const Icon(Icons.threed_rotation_rounded, size: 13, color: Color(0xFF38BDF8)),
                                              const SizedBox(width: 4),
                                              Text(
                                                _t('studio_view_360'),
                                                style: const TextStyle(
                                                  color: Colors.white,
                                                  fontSize: 9,
                                                  fontWeight: FontWeight.w900,
                                                  letterSpacing: 0.8,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                      Positioned(
                                        bottom: 10,
                                        right: 10,
                                        child: Container(
                                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                          decoration: BoxDecoration(
                                            color: Colors.black.withAlpha(190),
                                            borderRadius: BorderRadius.circular(8),
                                            border: Border.all(color: Colors.white24),
                                          ),
                                          child: Text(
                                            '${_t('security_deposit')}: \$${(vehicle.dailyCents * 3 ~/ 100).clamp(100, 500)} • ${_t('fully_insured')}',
                                            style: const TextStyle(
                                              fontSize: 10,
                                              fontWeight: FontWeight.w800,
                                              color: Colors.white,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              const SizedBox(height: 16),
                              Row(
                                children: [
                                  _buildSpecTile(Icons.tune_rounded, _t('engine_upper'), vehicle.engine.isNotEmpty ? vehicle.engine : '2.0L TURBO'),
                                  const SizedBox(width: 6),
                                  _buildSpecTile(Icons.bolt_rounded, _t('power_upper'), vehicle.horsepower.isNotEmpty ? vehicle.horsepower : '250 HP'),
                                  const SizedBox(width: 6),
                                  _buildSpecTile(Icons.speed_rounded, _t('speed_upper'), vehicle.topSpeed.isNotEmpty ? vehicle.topSpeed : '220 KM/H'),
                                  const SizedBox(width: 6),
                                  _buildSpecTile(Icons.timer_outlined, _t('accel_upper'), vehicle.acceleration.isNotEmpty ? vehicle.acceleration : '6.5s'),
                                ],
                              ),
                              const SizedBox(height: 16),
                              FilledButton.icon(
                                icon: Icon(
                                  !isAvailable
                                      ? Icons.event_busy_rounded
                                      : (isInCart ? Icons.check_circle_rounded : Icons.add_shopping_cart_rounded),
                                  size: 16,
                                ),
                                style: FilledButton.styleFrom(
                                  backgroundColor: !isAvailable
                                      ? const Color(0xFFE11D48)
                                      : (isInCart ? AppColors.brandEmerald : AppColors.brandRed),
                                  padding: const EdgeInsets.symmetric(vertical: 14),
                                ),
                                onPressed: onAddToCart,
                                label: Text(
                                  !isAvailable
                                      ? '${_t('stock_badge_rented')} • ${_t('car_unavailable_dialog_title')}'
                                      : (isInCart
                                          ? '${_t('in_reservation_cart')} • ${money(vehicle.dailyCents)}/${_t('per_day')}'
                                          : '${_t('add_to_cart')} • ${money(vehicle.dailyCents)}/${_t('per_day')}'),
                                ),
                              ),
                            ],
                          ),
                        ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title, Color accent) {
    return Row(
      children: [
        Container(
          width: 3.5,
          height: 13,
          decoration: BoxDecoration(
            color: accent,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            title,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w800,
              color: Color(0xFF111827),
              letterSpacing: 0.2,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSpecTile(IconData icon, String label, String value) {
    final cleanValue = (value.trim().isEmpty || value.trim().toLowerCase() == 'null') ? 'N/A' : value.trim();
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
        decoration: BoxDecoration(
          color: const Color(0xFFF9FAFB),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: const Color(0xFFE5E7EB)),
        ),
        child: Column(
          children: [
            Icon(icon, size: 16, color: const Color(0xFF374151)),
            const SizedBox(height: 4),
            Text(
              label,
              style: const TextStyle(fontSize: 8, fontWeight: FontWeight.w800, color: Color(0xFF9CA3AF), letterSpacing: 0.5),
            ),
            const SizedBox(height: 2),
            Text(
              cleanValue,
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w900,
                color: Color(0xFF111827),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAttributeChip(IconData icon, String label) {
    final cleanLabel = (label.trim().isEmpty || label.trim().toLowerCase() == 'null') ? 'Standard' : label.trim();
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 7, horizontal: 4),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: const Color(0xFFE5E7EB)),
        ),
        child: Column(
          children: [
            Icon(icon, size: 15, color: const Color(0xFF4B5563)),
            const SizedBox(height: 3),
            Text(
              cleanLabel,
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(fontSize: 9, fontWeight: FontWeight.bold, color: Color(0xFF374151)),
            ),
          ],
        ),
      ),
    );
  }

  static Widget _buildAssuranceRow(IconData icon, String text) {
    return Row(
      children: [
        Icon(icon, size: 14, color: const Color(0xFF059669)),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            text,
            style: const TextStyle(fontSize: 10, color: Color(0xFF065F46), fontWeight: FontWeight.w600),
          ),
        ),
      ],
    );
  }
}
