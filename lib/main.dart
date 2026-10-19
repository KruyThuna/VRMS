import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'models.dart';
import 'smart_image.dart';
import 'store.dart';
import 'storefront.dart';
import 'src/shared/app_theme.dart';
import 'src/shared/app_colors.dart';
import 'src/screens/admin/widgets/post_vehicle_dialog.dart';
import 'src/screens/admin/widgets/brand_breakdown_table.dart';
import 'src/screens/admin/widgets/category_analytics_card.dart';
import 'src/screens/admin/widgets/customer_form_dialog.dart';
import 'src/screens/admin/widgets/customer_details_dialog.dart';
import 'src/screens/admin/widgets/booking_form_dialog.dart';
import 'src/screens/admin/widgets/booking_details_dialog.dart';
import 'src/screens/admin/widgets/payment_form_dialog.dart';
import 'src/screens/admin/widgets/payment_details_dialog.dart';
import 'src/screens/admin/widgets/return_vehicle_dialog.dart';
import 'src/localization/app_language.dart';
import 'src/localization/language_selector_widget.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  try {
    final prefs = await SharedPreferences.getInstance();
    final store = RentalStore(prefs);
    runApp(DriveLineApp(store: store));
  } catch (_) {
    runApp(
      const MaterialApp(
        home: Scaffold(
          body: Center(
            child: Padding(
              padding: EdgeInsets.all(32),
              child: Text(
                'Unable to initialize storage. Please check browser permissions and reload.',
                textAlign: TextAlign.center,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class DriveLineApp extends StatelessWidget {
  final RentalStore store;

  const DriveLineApp({super.key, required this.store});

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: store,
      builder: (context, _) {
        return MaterialApp(
          title: store.t('app_title'),
          debugShowCheckedModeBanner: false,
          theme: AppTheme.lightTheme,
          home: Storefront(
            store: store,
            managementBuilder: (_) => RentalHome(store: store),
          ),
        );
      },
    );
  }
}

class RentalHome extends StatefulWidget {
  final RentalStore store;

  const RentalHome({super.key, required this.store});

  @override
  State<RentalHome> createState() => _RentalHomeState();
}

class _RentalHomeState extends State<RentalHome> {
  int page = 0;
  String query = '';
  bool busy = false;
  String selectedBrand = 'All';
  String selectedCategory = 'All';
  String selectedStatus = 'All';
  String selectedBookingStatus = 'All';
  String selectedReturnStatus = 'All';
  String selectedPaymentStatus = 'All';

  RentalStore get s => widget.store;

  static const Color brandRed = Color(0xFFE50914);
  static const Color brandEmerald = Color(0xFF10B981);
  static const Color darkBg = Color(0xFF0B0F19);
  static const Color cardBorder = Color(0xFFE5E7EB);

  List<String> get names => [
        s.t('dashboard'),
        s.t('fleet_products'),
        s.t('hero_banners'),
        s.t('categories_brand'),
        s.t('customers'),
        s.t('bookings'),
        s.t('return_car'),
        s.t('payments'),
      ];

  static const icons = [
    Icons.space_dashboard_outlined,
    Icons.directions_car_outlined,
    Icons.view_carousel_outlined,
    Icons.category_outlined,
    Icons.people_alt_outlined,
    Icons.calendar_month_outlined,
    Icons.assignment_return_outlined,
    Icons.account_balance_wallet_outlined,
  ];

  @override
  void initState() {
    super.initState();
    s.addListener(refresh);
  }

  @override
  void dispose() {
    s.removeListener(refresh);
    super.dispose();
  }

  void refresh() {
    if (mounted) setState(() {});
  }

  void message(String text) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(text),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  Future<bool> save(Future<void> Function() change) async {
    if (busy) return false;
    setState(() => busy = true);
    try {
      await change();
      return true;
    } catch (_) {
      if (mounted) message('Could not save changes. Check storage.');
      return false;
    } finally {
      if (mounted) setState(() => busy = false);
    }
  }

  void go(int value, {String? brand, String? category}) => setState(() {
        page = value;
        query = '';
        if (brand != null) selectedBrand = brand;
        if (category != null) selectedCategory = category;
      });

  bool matches(String value) =>
      value.toLowerCase().contains(query.toLowerCase());

  @override
  Widget build(BuildContext context) {
    final wide = MediaQuery.sizeOf(context).width >= 960;

    return Scaffold(
      backgroundColor: const Color(0xFFF9FAFB),
      appBar: AppBar(
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: brandRed,
                borderRadius: BorderRadius.circular(6),
              ),
              child: const Icon(Icons.tune, color: Colors.white, size: 16),
            ),
            const SizedBox(width: 10),
            Flexible(
              child: Text(
                '${s.agencyConfig.companyName} • ${s.t('admin_workspace')}',
                style:
                    const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
            child: LanguageSelectorWidget(
              currentLanguage: s.language,
              onLanguageChanged: (lang) => setState(() => s.setLanguage(lang)),
            ),
          ),
          if (wide)
            OutlinedButton.icon(
              style: OutlinedButton.styleFrom(
                foregroundColor: Colors.white,
                side: const BorderSide(color: Colors.white38),
              ),
              onPressed: () => Navigator.pop(context),
              icon: const Icon(Icons.storefront, size: 16),
              label: Text(s.t('back_to_storefront')),
            )
          else
            IconButton(
              tooltip: s.t('back_to_storefront'),
              icon: const Icon(Icons.storefront, color: Colors.white),
              onPressed: () => Navigator.pop(context),
            ),
          const SizedBox(width: 8),
        ],
      ),
      drawer: wide ? null : Drawer(child: SafeArea(child: navigation())),
      body: Row(
        children: [
          if (wide) SizedBox(width: 250, child: navigation()),
          Expanded(
            child: AbsorbPointer(
              absorbing: busy,
              child: ListView(
                padding: EdgeInsets.all(wide ? 32 : 16),
                children: [
                  Wrap(
                    alignment: WrapAlignment.spaceBetween,
                    crossAxisAlignment: WrapCrossAlignment.center,
                    spacing: 12,
                    runSpacing: 12,
                    children: [
                      Text(
                        names[page],
                        style: const TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.w900,
                          color: darkBg,
                          letterSpacing: -0.5,
                        ),
                      ),
                      if (page == 1)
                        FilledButton.icon(
                          style: FilledButton.styleFrom(
                            backgroundColor: brandRed,
                            padding: const EdgeInsets.symmetric(
                                horizontal: 18, vertical: 14),
                          ),
                          onPressed: () => postProductDialog(),
                          icon: const Icon(Icons.add_circle_outline, size: 18),
                          label: Text(s.t('post_new_vehicle'),
                              style:
                                  const TextStyle(fontWeight: FontWeight.bold)),
                        ),
                      if (page == 2)
                        FilledButton.icon(
                          style: FilledButton.styleFrom(
                            backgroundColor: brandEmerald,
                            padding: const EdgeInsets.symmetric(
                                horizontal: 18, vertical: 14),
                          ),
                          onPressed: () => postBannerDialog(),
                          icon: const Icon(Icons.add_photo_alternate_outlined,
                              size: 18),
                          label: Text(s.t('post_new_banner'),
                              style:
                                  const TextStyle(fontWeight: FontWeight.bold)),
                        ),
                      if (page == 3)
                        FilledButton.icon(
                          style: FilledButton.styleFrom(
                            backgroundColor: darkBg,
                            padding: const EdgeInsets.symmetric(
                                horizontal: 18, vertical: 14),
                          ),
                          onPressed: () => addCategoryDialog(),
                          icon: const Icon(Icons.add, size: 18),
                          label: Text(s.t('add_category'),
                              style:
                                  const TextStyle(fontWeight: FontWeight.bold)),
                        ),
                      if (page == 4)
                        FilledButton.icon(
                          style:
                              FilledButton.styleFrom(backgroundColor: brandRed),
                          onPressed: addCustomer,
                          icon: const Icon(Icons.add, size: 18),
                          label: Text(s.t('add_customer')),
                        ),
                      if (page == 5)
                        FilledButton.icon(
                          style:
                              FilledButton.styleFrom(backgroundColor: brandRed),
                          onPressed: addBooking,
                          icon: const Icon(Icons.add, size: 18),
                          label: Text(s.t('new_booking')),
                        ),
                      if (page == 6)
                        FilledButton.icon(
                          style: FilledButton.styleFrom(
                            backgroundColor: AppColors.brandEmerald,
                            padding: const EdgeInsets.symmetric(
                                horizontal: 18, vertical: 12),
                          ),
                          onPressed: () => _openQuickReturnSelector(),
                          icon: const Icon(Icons.assignment_turned_in_rounded, size: 18),
                          label: Text(
                            s.t('quick_return_action'),
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ),
                      if (page == 7)
                        FilledButton.icon(
                          style: FilledButton.styleFrom(
                            backgroundColor: AppColors.brandEmerald,
                            padding: const EdgeInsets.symmetric(
                                horizontal: 18, vertical: 12),
                          ),
                          onPressed: () => recordPaymentDialog(),
                          icon: const Icon(Icons.add_card_rounded, size: 18),
                          label: Text(
                            s.t('record_new_payment'),
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  if (busy)
                    const Padding(
                        padding: EdgeInsets.only(bottom: 16),
                        child: LinearProgressIndicator()),
                  if (page != 0 && page != 1 && page != 3) ...[
                    TextField(
                      key: ValueKey(page),
                      onChanged: (v) => setState(() => query = v),
                      decoration: InputDecoration(
                        prefixIcon: const Icon(Icons.search),
                        hintText: page == 4
                            ? s.t('search_customers')
                            : (page == 5
                                ? s.t('search_bookings')
                                : (page == 6
                                    ? s.t('search_returns')
                                    : (page == 7
                                        ? s.t('search_payments')
                                        : 'Search ${names[page].toLowerCase()}...'))),
                      ),
                    ),
                    const SizedBox(height: 16),
                  ],
                  if (page == 0) dashboard(),
                  if (page == 1) vehicles(),
                  if (page == 2) banners(),
                  if (page == 3) categoriesAndBrand(),
                  if (page == 4) customers(),
                  if (page == 5) bookings(),
                  if (page == 6) returnsHub(),
                  if (page == 7) payments(),
                  const SizedBox(height: 40),
                  const Center(
                    child: Text(
                      'DriveLine Workspace • Real-time storage synced with website storefront.',
                      style: TextStyle(fontSize: 12, color: Colors.grey),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget navigation() => Material(
        color: Colors.white,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Padding(
              padding: EdgeInsets.fromLTRB(24, 24, 24, 12),
              child: Text(
                'MANAGEMENT HUB',
                style: TextStyle(
                  letterSpacing: 1.5,
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey,
                ),
              ),
            ),
            for (int i = 0; i < names.length; i++)
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 3),
                child: ListTile(
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10)),
                  selected: page == i,
                  selectedTileColor: const Color(0xFFFEE2E2),
                  selectedColor: brandRed,
                  leading:
                      Icon(icons[i], color: page == i ? brandRed : Colors.grey),
                  title: Text(
                    names[i],
                    style: TextStyle(
                      fontWeight: page == i ? FontWeight.bold : FontWeight.w600,
                      color: page == i ? brandRed : darkBg,
                    ),
                  ),
                  trailing: (i == 6)
                      ? (s.overdueRentalsCount > 0
                          ? Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 7, vertical: 2),
                              decoration: BoxDecoration(
                                color: const Color(0xFFDC2626),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Text(
                                '${s.overdueRentalsCount}',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            )
                          : (s.activeRentalsCount > 0
                              ? Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 7, vertical: 2),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFF10B981),
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: Text(
                                    '${s.activeRentalsCount}',
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 10,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                )
                              : null))
                      : null,
                  onTap: () {
                    go(i);
                    if (MediaQuery.sizeOf(context).width < 960) {
                      Navigator.pop(context);
                    }
                  },
                ),
              ),
          ],
        ),
      );

  Widget panel(Widget child) => Container(
        margin: const EdgeInsets.only(bottom: 16),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: cardBorder),
        ),
        child: child,
      );

  Widget badge(String label) {
    final color = ['Available', 'Returned', 'Paid', 'Active'].contains(label)
        ? Colors.teal
        : ['Overdue', 'Maintenance', 'Inactive'].contains(label)
            ? brandRed
            : const Color(0xFF2563EB);
    return Chip(
      label: Text(label,
          style: TextStyle(
              fontSize: 11, color: color, fontWeight: FontWeight.bold)),
      backgroundColor: color.withAlpha(25),
      side: BorderSide.none,
      visualDensity: VisualDensity.compact,
    );
  }

  Widget empty([String text = 'No records found.']) => panel(
        Padding(
          padding: const EdgeInsets.all(24),
          child: Center(
            child: Text(text, style: const TextStyle(color: Colors.grey)),
          ),
        ),
      );

  Widget dashboard() {
    final available = s.availableCount;
    final active = s.activeRentalsCount;
    final collected = s.totalCollectedCents;
    final due = s.totalDueCents;
    final totalMsrp =
        s.vehicles.fold<int>(0, (sum, v) => sum + v.purchasePrice);
    final activeBanners = s.banners.where((b) => b.active).length;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Executive Telemetry KPIs
        Wrap(
          spacing: 16,
          runSpacing: 16,
          children: [
            _kpiCard(
                s.t('available_fleet'),
                '$available / ${s.vehicles.length}',
                Icons.directions_car_rounded,
                const Color(0xFF10B981)),
            _kpiCard(
                s.t('active_banners'),
                '$activeBanners / ${s.banners.length}',
                Icons.view_carousel_rounded,
                const Color(0xFF3B82F6)),
            _kpiCard(s.t('active_rentals'), '$active', Icons.key_rounded,
                const Color(0xFFF59E0B)),
            _kpiCard(s.t('revenue_collected_kpi'), money(collected),
                Icons.payments_rounded, const Color(0xFF10B981)),
            _kpiCard(s.t('pending_balance_kpi'), money(due),
                Icons.pending_actions_rounded, const Color(0xFFEF4444)),
            _kpiCard(
                s.t('inventory_summary'),
                '\$${totalMsrp.toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]},')}',
                Icons.account_balance_rounded,
                const Color(0xFF8B5CF6)),
          ],
        ),
        const SizedBox(height: 24),

        // Overdue Alert Banner (if any)
        if (s.overdueRentalsCount > 0) ...[
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
            decoration: BoxDecoration(
              color: const Color(0xFFFEF2F2),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: const Color(0xFFFCA5A5)),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: const BoxDecoration(
                    color: Color(0xFFFEE2E2),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.warning_amber_rounded,
                      color: Color(0xFFDC2626), size: 22),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        s.t('overdue_banner_alert'),
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w800,
                          color: Color(0xFF991B1B),
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        '${s.overdueRentalsCount} ${s.t('overdue_banner_desc')}',
                        style: const TextStyle(
                          fontSize: 12,
                          color: Color(0xFFB91C1C),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                FilledButton.tonal(
                  style: FilledButton.styleFrom(
                    backgroundColor: const Color(0xFFDC2626),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  ),
                  onPressed: () => go(6),
                  child: Text(
                    s.language == AppLanguage.khmer ? 'ប្រគល់រថយន្ត' : 'Process Returns',
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 18),
        ],

        // Quick Operations Panel
        panel(
          Wrap(
            alignment: WrapAlignment.spaceBetween,
            crossAxisAlignment: WrapCrossAlignment.center,
            spacing: 16,
            runSpacing: 12,
            children: [
              ConstrainedBox(
                constraints: const BoxConstraints(minWidth: 280),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      s.t('quick_operations'),
                      style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: darkBg),
                    ),
                    const SizedBox(height: 2),
                    Text(s.t('quick_operations_sub'),
                        style:
                            const TextStyle(color: Colors.grey, fontSize: 13)),
                  ],
                ),
              ),
              Wrap(
                spacing: 10,
                runSpacing: 8,
                children: [
                  FilledButton.icon(
                    style: FilledButton.styleFrom(
                        backgroundColor: brandRed,
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 12)),
                    onPressed: () => postProductDialog(),
                    icon: const Icon(Icons.add, size: 18),
                    label: Text(s.t('new_fleet_product'),
                        style: const TextStyle(fontWeight: FontWeight.bold)),
                  ),
                  FilledButton.icon(
                    style: FilledButton.styleFrom(
                        backgroundColor: brandEmerald,
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 12)),
                    onPressed: () => postBannerDialog(),
                    icon: const Icon(Icons.photo_size_select_actual_outlined,
                        size: 18),
                    label: Text(s.t('post_new_banner'),
                        style: const TextStyle(fontWeight: FontWeight.bold)),
                  ),
                  OutlinedButton.icon(
                    style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 12)),
                    onPressed: addBooking,
                    icon: const Icon(Icons.calendar_today, size: 16),
                    label: Text(s.t('new_booking'),
                        style: const TextStyle(fontWeight: FontWeight.bold)),
                  ),
                  FilledButton.icon(
                    style: FilledButton.styleFrom(
                        backgroundColor: const Color(0xFFD97706),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 12)),
                    onPressed: () => go(6),
                    icon: const Icon(Icons.assignment_return_outlined, size: 18),
                    label: Text(s.t('return_car'),
                        style: const TextStyle(fontWeight: FontWeight.bold)),
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),

        // Brand Performance Breakdown Table
        BrandBreakdownTable(
          store: s,
          onSelectBrand: (brand) {
            go(1, brand: brand);
          },
        ),
        const SizedBox(height: 24),

        // Category Distribution & Analytics
        CategoryAnalyticsCard(
          store: s,
          onSelectCategory: (cat) {
            go(1, category: cat);
          },
        ),
        const SizedBox(height: 24),

        // Live Banners & Bookings Stream
        Text(s.t('hero_banners'),
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        const SizedBox(height: 12),
        if (s.banners.isEmpty)
          empty('No banners configured.')
        else
          ...s.banners.take(3).map(_bannerMiniRow),
        const SizedBox(height: 20),
        Text(s.t('bookings'),
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        const SizedBox(height: 14),
        if (s.rentals.isEmpty)
          empty('No reservations found.')
        else
          ...s.rentals.reversed.take(5).map(rentalCard),
      ],
    );
  }

  Widget _kpiCard(String label, String value, IconData icon,
      [Color accentColor = brandRed]) {
    return Container(
      width: 200,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: cardBorder),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(6),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  label,
                  style: const TextStyle(
                      color: Colors.grey,
                      fontSize: 12,
                      fontWeight: FontWeight.w600),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: accentColor.withAlpha(25),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, color: accentColor, size: 18),
              ),
            ],
          ),
          const SizedBox(height: 10),
          FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerLeft,
            child: Text(
              value,
              style: const TextStyle(
                  fontSize: 22, fontWeight: FontWeight.w900, color: darkBg),
            ),
          ),
        ],
      ),
    );
  }

  Color _getBrandColor(String brand) {
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

  Widget _specPill(String text) {
    if (text.trim().isEmpty || text.trim().toLowerCase() == 'null') return const SizedBox.shrink();
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
      decoration: BoxDecoration(
        color: const Color(0xFFF9FAFB),
        borderRadius: BorderRadius.circular(5),
        border: Border.all(color: const Color(0xFFE5E7EB)),
      ),
      child: Text(
        text,
        style: const TextStyle(
            fontSize: 10,
            fontWeight: FontWeight.w600,
            color: Color(0xFF374151)),
      ),
    );
  }

  Widget vehicles() {
    final allBrands =
        s.vehicles.map((v) => v.brand.toUpperCase()).toSet().toList()..sort();
    final categories = s.categories;

    final filtered = s.vehicles.where((v) {
      if (selectedBrand != 'All' &&
          v.brand.toUpperCase() != selectedBrand.toUpperCase()) {
        return false;
      }
      if (selectedCategory != 'All' &&
          v.type.toLowerCase() != selectedCategory.toLowerCase()) {
        return false;
      }
      if (selectedStatus != 'All') {
        final status = s.vehicleStatus(v);
        if (selectedStatus == 'Available' && status != 'Available')
          return false;
        if (selectedStatus == 'Rented' &&
            status != 'Rented' &&
            status != 'Active' &&
            status != 'Overdue') return false;
        if (selectedStatus == 'Maintenance' && !v.maintenance) return false;
      }
      if (query.isNotEmpty) {
        return matches(
            '${v.name} ${v.brand} ${v.plate} ${v.type} ${v.engine} ${v.horsepower} ${s.vehicleStatus(v)}');
      }
      return true;
    }).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Dedicated Fleet Control & Filter Bar
        panel(
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextField(
                onChanged: (v) => setState(() => query = v),
                decoration: InputDecoration(
                  prefixIcon: const Icon(Icons.search, size: 20),
                  hintText: s.t('search_fleet_hint'),
                  filled: true,
                  fillColor: const Color(0xFFF9FAFB),
                  contentPadding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: const BorderSide(color: Color(0xFFE5E7EB))),
                  enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: const BorderSide(color: Color(0xFFE5E7EB))),
                ),
              ),
              const SizedBox(height: 14),
              // Brand Filter Chips
              Wrap(
                spacing: 8,
                runSpacing: 8,
                crossAxisAlignment: WrapCrossAlignment.center,
                children: [
                  Text('${s.t('brand')}:',
                      style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textMuted)),
                  ChoiceChip(
                    label: Text(s.t('all_brands'),
                        style: const TextStyle(
                            fontSize: 11, fontWeight: FontWeight.bold)),
                    selected: selectedBrand == 'All',
                    selectedColor: const Color(0xFFFEE2E2),
                    onSelected: (sel) => setState(() => selectedBrand = 'All'),
                  ),
                  for (final b in allBrands)
                    ChoiceChip(
                      label: Text(b,
                          style: const TextStyle(
                              fontSize: 11, fontWeight: FontWeight.bold)),
                      selected: selectedBrand == b,
                      selectedColor: const Color(0xFFFEE2E2),
                      onSelected: (sel) =>
                          setState(() => selectedBrand = sel ? b : 'All'),
                    ),
                ],
              ),
              const SizedBox(height: 8),
              // Category Filter Chips
              Wrap(
                spacing: 8,
                runSpacing: 8,
                crossAxisAlignment: WrapCrossAlignment.center,
                children: [
                  Text('${s.t('category_name')}:',
                      style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textMuted)),
                  for (final cat in categories)
                    ChoiceChip(
                      label: Text(cat == 'All' ? s.t('all_categories') : cat,
                          style: const TextStyle(
                              fontSize: 11, fontWeight: FontWeight.bold)),
                      selected: selectedCategory == cat,
                      selectedColor: const Color(0xFFEFF6FF),
                      onSelected: (sel) =>
                          setState(() => selectedCategory = sel ? cat : 'All'),
                    ),
                ],
              ),
              const SizedBox(height: 8),
              // Status Filter Chips
              Wrap(
                spacing: 8,
                runSpacing: 8,
                crossAxisAlignment: WrapCrossAlignment.center,
                children: [
                  Text('${s.t('status_filter')}:',
                      style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textMuted)),
                  ChoiceChip(
                    label: Text(s.t('all_status'),
                        style: const TextStyle(
                            fontSize: 11, fontWeight: FontWeight.bold)),
                    selected: selectedStatus == 'All',
                    selectedColor: const Color(0xFFECFDF5),
                    onSelected: (sel) => setState(() => selectedStatus = 'All'),
                  ),
                  ChoiceChip(
                    label: Text(s.t('status_available'),
                        style: const TextStyle(
                            fontSize: 11, fontWeight: FontWeight.bold)),
                    selected: selectedStatus == 'Available',
                    selectedColor: const Color(0xFFECFDF5),
                    onSelected: (sel) => setState(
                        () => selectedStatus = sel ? 'Available' : 'All'),
                  ),
                  ChoiceChip(
                    label: Text(s.t('status_rented'),
                        style: const TextStyle(
                            fontSize: 11, fontWeight: FontWeight.bold)),
                    selected: selectedStatus == 'Rented',
                    selectedColor: const Color(0xFFEFF6FF),
                    onSelected: (sel) =>
                        setState(() => selectedStatus = sel ? 'Rented' : 'All'),
                  ),
                  ChoiceChip(
                    label: Text(s.t('status_maintenance'),
                        style: const TextStyle(
                            fontSize: 11, fontWeight: FontWeight.bold)),
                    selected: selectedStatus == 'Maintenance',
                    selectedColor: const Color(0xFFFEF2F2),
                    onSelected: (sel) => setState(
                        () => selectedStatus = sel ? 'Maintenance' : 'All'),
                  ),
                  if (selectedBrand != 'All' ||
                      selectedCategory != 'All' ||
                      selectedStatus != 'All' ||
                      query.isNotEmpty)
                    TextButton.icon(
                      style: TextButton.styleFrom(foregroundColor: brandRed),
                      onPressed: () => setState(() {
                        selectedBrand = 'All';
                        selectedCategory = 'All';
                        selectedStatus = 'All';
                        query = '';
                      }),
                      icon: const Icon(Icons.clear_all, size: 16),
                      label: Text(s.t('reset_filters'),
                          style: const TextStyle(
                              fontSize: 11, fontWeight: FontWeight.bold)),
                    ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 8),

        // Count indicator
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 6),
          child: Text(
            s.language == AppLanguage.khmer
                ? 'បង្ហាញ ${filtered.length} នៃរថយន្តសរុប ${s.vehicles.length}'
                : 'Showing ${filtered.length} of ${s.vehicles.length} fleet products',
            style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: AppColors.textMuted),
          ),
        ),

        if (filtered.isEmpty)
          empty('No vehicles match your search or filter.')
        else
          ...filtered.map(_buildFleetProductCard),
      ],
    );
  }

  Widget _buildFleetProductCard(Vehicle v) {
    final status = s.vehicleStatus(v);
    final color = _getBrandColor(v.brand);

    return panel(
      LayoutBuilder(
        builder: (context, constraints) {
          final isNarrow = constraints.maxWidth < 650;
          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: SizedBox(
                      width: isNarrow ? 80 : 120,
                      height: isNarrow ? 65 : 80,
                      child: SmartImage(
                        imageSource: v.imageUrl,
                        fit: BoxFit.cover,
                        fallback: Container(
                          color: const Color(0xFFF3F4F6),
                          child: const Icon(Icons.directions_car,
                              color: darkBg, size: 30),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Wrap(
                          spacing: 8,
                          runSpacing: 4,
                          crossAxisAlignment: WrapCrossAlignment.center,
                          children: [
                            Text(
                              v.name,
                              style: const TextStyle(
                                  fontWeight: FontWeight.w900,
                                  fontSize: 16,
                                  color: darkBg),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 8, vertical: 2),
                              decoration: BoxDecoration(
                                color: color.withAlpha(25),
                                borderRadius: BorderRadius.circular(6),
                                border: Border.all(color: color.withAlpha(120)),
                              ),
                              child: Text(
                                v.brand.toUpperCase(),
                                style: TextStyle(
                                    color: color,
                                    fontSize: 10,
                                    fontWeight: FontWeight.w800),
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 8, vertical: 2),
                              decoration: BoxDecoration(
                                color: const Color(0xFFF3F4F6),
                                borderRadius: BorderRadius.circular(6),
                                border:
                                    Border.all(color: const Color(0xFFE5E7EB)),
                              ),
                              child: Text(
                                v.type,
                                style: const TextStyle(
                                    color: Color(0xFF4B5563),
                                    fontSize: 10,
                                    fontWeight: FontWeight.bold),
                              ),
                            ),
                            Text(
                              '${v.year} • ${v.plate}',
                              style: const TextStyle(
                                  color: Colors.grey, fontSize: 12),
                            ),
                            if (v.isFeatured ||
                                s.banners.any(
                                    (b) => b.vehicleId == v.id && b.active))
                              Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 7, vertical: 2),
                                decoration: BoxDecoration(
                                  color: const Color(0xFF10B981).withAlpha(30),
                                  borderRadius: BorderRadius.circular(6),
                                  border: Border.all(
                                      color: const Color(0xFF10B981)),
                                ),
                                child: Text(
                                  s.t('banner_hero_badge'),
                                  style: const TextStyle(
                                      color: Color(0xFF047857),
                                      fontSize: 9,
                                      fontWeight: FontWeight.w800),
                                ),
                              ),
                          ],
                        ),
                        const SizedBox(height: 6),
                        Wrap(
                          spacing: 6,
                          runSpacing: 4,
                          children: [
                            _specPill(v.engine),
                            _specPill(v.horsepower),
                            _specPill(v.topSpeed),
                            _specPill(v.acceleration),
                            _specPill(v.transmission),
                            _specPill('${v.seats} ${s.t('seats')}'),
                          ],
                        ),
                      ],
                    ),
                  ),
                  if (!isNarrow) ...[
                    const SizedBox(width: 14),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          '${money(v.dailyCents)} / day',
                          style: const TextStyle(
                              fontWeight: FontWeight.w900,
                              fontSize: 16,
                              color: darkBg),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          'Asset Value \$${v.purchasePrice.toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]},')}',
                          style: const TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                              color: AppColors.brandRed),
                        ),
                        const SizedBox(height: 6),
                        badge(status),
                      ],
                    ),
                  ],
                  const SizedBox(width: 8),
                  PopupMenuButton<String>(
                    icon: const Icon(Icons.more_vert),
                    onSelected: (action) async {
                      if (action == 'edit') {
                        postProductDialog(existing: v);
                      } else if (action == 'banner') {
                        await save(() async {
                          final safeBrand = (v.brand.isNotEmpty && v.brand != 'null') ? v.brand : 'DRIVELINE';
                          final safeEngine = (v.engine.isNotEmpty && v.engine != 'null') ? v.engine : '2.0L TURBO';
                          final safeHp = (v.horsepower.isNotEmpty && v.horsepower != 'null') ? v.horsepower : '250 HP';
                          final safeAccel = (v.acceleration.isNotEmpty && v.acceleration != 'null') ? v.acceleration : '6.5s';
                          final safeTrans = (v.transmission.isNotEmpty && v.transmission != 'null') ? v.transmission : 'Automatic';
                          final safeSeats = v.seats > 0 ? v.seats : 5;
                          final b = BannerItem(
                            id: s.newId('B'),
                            tagline: (v.tagline.isNotEmpty && v.tagline != 'null')
                                ? v.tagline
                                : 'EXCLUSIVE FLEET',
                            title: (v.name.isNotEmpty && v.name != 'null') ? v.name.toUpperCase() : 'EXCLUSIVE VEHICLE',
                            subtitle:
                                '$safeBrand Luxury ${v.type} • $safeEngine',
                            vehicleId: v.id,
                            priceText:
                                '${money(v.dailyCents)} / DAY • FULL INSURANCE',
                            specChips: [
                              safeEngine,
                              '$safeHp · $safeAccel',
                              safeTrans,
                              '$safeSeats SEATS',
                            ],
                            badgeText: safeBrand,
                            badgeColorValue: 0xFF10B981,
                            active: true,
                            imageUrl: (v.imageUrl != null && v.imageUrl!.isNotEmpty && v.imageUrl != 'null') ? v.imageUrl : null,
                          );
                          await s.addBanner(b);
                        });
                        message('Promoted ${v.name} to Hero Banners!');
                      } else if (action == 'maintenance') {
                        if (!v.maintenance &&
                            s.rentals.any(
                                (r) => r.vehicleId == v.id && !r.returned)) {
                          message(
                              'Cannot mark maintenance with active bookings.');
                          return;
                        }
                        await save(() =>
                            s.commit(() => v.maintenance = !v.maintenance));
                        message(v.maintenance
                            ? '${v.name} is now marked under Maintenance.'
                            : '${v.name} is now Ready and Available.');
                      } else if (action == 'delete') {
                        final ok = await showDialog<bool>(
                          context: context,
                          builder: (ctx) => AlertDialog(
                            title: Text('Delete ${v.name}?'),
                            content: const Text(
                                'Are you sure you want to remove this vehicle from the fleet?'),
                            actions: [
                              TextButton(
                                  onPressed: () => Navigator.pop(ctx, false),
                                  child: Text(s.t('cancel'))),
                              FilledButton(
                                style: FilledButton.styleFrom(
                                    backgroundColor: brandRed),
                                onPressed: () => Navigator.pop(ctx, true),
                                child: Text(s.t('delete')),
                              ),
                            ],
                          ),
                        );
                        if (ok == true) {
                          await save(() => s.deleteVehicle(v.id));
                          message('Removed ${v.name} from inventory.');
                        }
                      }
                    },
                    itemBuilder: (ctx) => [
                      PopupMenuItem(
                        value: 'edit',
                        child: Row(
                          children: [
                            const Icon(Icons.edit_note,
                                size: 18, color: Color(0xFF2563EB)),
                            const SizedBox(width: 8),
                            Text(s.t('edit_product')),
                          ],
                        ),
                      ),
                      PopupMenuItem(
                        value: 'banner',
                        child: Row(
                          children: [
                            const Icon(Icons.star_rounded,
                                size: 18, color: Colors.amber),
                            const SizedBox(width: 8),
                            Text(s.t('feature_on_banner')),
                          ],
                        ),
                      ),
                      PopupMenuItem(
                        value: 'maintenance',
                        child: Row(
                          children: [
                            Icon(Icons.build_circle_outlined,
                                size: 18,
                                color: v.maintenance
                                    ? Colors.teal
                                    : Colors.orange),
                            const SizedBox(width: 8),
                            Text(v.maintenance
                                ? s.t('mark_ready')
                                : s.t('mark_maintenance')),
                          ],
                        ),
                      ),
                      PopupMenuItem(
                        value: 'delete',
                        child: Row(
                          children: [
                            const Icon(Icons.delete_outline,
                                size: 18, color: Colors.red),
                            const SizedBox(width: 8),
                            Text(s.t('delete_product')),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              if (isNarrow) ...[
                const SizedBox(height: 10),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      '${money(v.dailyCents)} / day • Asset Value \$${v.purchasePrice}',
                      style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 13,
                          color: darkBg),
                    ),
                    badge(status),
                  ],
                ),
              ],
            ],
          );
        },
      ),
    );
  }

  Widget _bannerMiniRow(BannerItem b) {
    return panel(
      Row(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: Color(b.badgeColorValue).withAlpha(30),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Color(b.badgeColorValue)),
            ),
            child: Text(
              b.tagline,
              style: TextStyle(
                color: Color(b.badgeColorValue),
                fontWeight: FontWeight.bold,
                fontSize: 11,
              ),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(b.title,
                    style: const TextStyle(
                        fontWeight: FontWeight.bold, fontSize: 16)),
                Text(b.subtitle,
                    style: const TextStyle(color: Colors.grey, fontSize: 12)),
              ],
            ),
          ),
          Text(b.priceText,
              style:
                  const TextStyle(fontWeight: FontWeight.w700, fontSize: 12)),
          const SizedBox(width: 14),
          badge(b.active ? 'Active' : 'Inactive'),
        ],
      ),
    );
  }

  Widget banners() {
    final list = s.banners
        .where((b) => matches('${b.title} ${b.tagline} ${b.subtitle}'))
        .toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (list.isEmpty)
          empty(
              'No banners created yet. Click "Post New Hero Banner" to add one.'),
        ...list.map(
          (b) {
            final vehicle =
                s.vehicles.where((v) => v.id == b.vehicleId).firstOrNull;
            final bannerImg = (b.imageUrl != null && b.imageUrl!.isNotEmpty)
                ? b.imageUrl!
                : (vehicle?.imageUrl ?? '');

            return panel(
              LayoutBuilder(
                builder: (context, constraints) {
                  final isWide = constraints.maxWidth > 700;
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 10, vertical: 4),
                                decoration: BoxDecoration(
                                  color: Color(b.badgeColorValue).withAlpha(35),
                                  borderRadius: BorderRadius.circular(6),
                                  border: Border.all(
                                      color: Color(b.badgeColorValue)),
                                ),
                                child: Text(
                                  b.badgeText,
                                  style: TextStyle(
                                    color: Color(b.badgeColorValue),
                                    fontSize: 10,
                                    fontWeight: FontWeight.w800,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 10),
                              Text(
                                b.tagline,
                                style: const TextStyle(
                                  fontStyle: FontStyle.italic,
                                  fontWeight: FontWeight.w700,
                                  fontSize: 12,
                                  color: Colors.black87,
                                ),
                              ),
                            ],
                          ),
                          Row(
                            children: [
                              badge(b.active ? 'Active on Web' : 'Inactive'),
                              const SizedBox(width: 8),
                              Switch(
                                value: b.active,
                                onChanged: (val) =>
                                    save(() => s.toggleBannerActive(b.id)),
                              ),
                            ],
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      if (isWide)
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Left: Title, subtitle, price, specs
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    b.title,
                                    style: const TextStyle(
                                      fontSize: 22,
                                      fontWeight: FontWeight.w900,
                                      color: darkBg,
                                    ),
                                  ),
                                  Text(b.subtitle,
                                      style: const TextStyle(
                                          color: Colors.black87, fontSize: 13)),
                                  const SizedBox(height: 8),
                                  Text('Highlight: ${b.priceText}',
                                      style: const TextStyle(
                                          fontWeight: FontWeight.w800,
                                          color: Color(0xFF047857),
                                          fontSize: 13)),
                                  const SizedBox(height: 10),
                                  Wrap(
                                    spacing: 6,
                                    runSpacing: 6,
                                    children: b.specChips
                                        .map((sc) => Container(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                      horizontal: 8,
                                                      vertical: 4),
                                              decoration: BoxDecoration(
                                                color: const Color(0xFFF3F4F6),
                                                borderRadius:
                                                    BorderRadius.circular(6),
                                                border: Border.all(
                                                    color: const Color(
                                                        0xFFE5E7EB)),
                                              ),
                                              child: Text(sc,
                                                  style: const TextStyle(
                                                      fontSize: 11,
                                                      fontWeight:
                                                          FontWeight.w600)),
                                            ))
                                        .toList(),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 20),
                            // Right: Car Model Image
                            ClipRRect(
                              borderRadius: BorderRadius.circular(12),
                              child: Container(
                                width: 220,
                                height: 130,
                                decoration: BoxDecoration(
                                  color: const Color(0xFFF1F5F9),
                                  border: Border.all(
                                      color: const Color(0xFFE2E8F0)),
                                ),
                                child: SmartImage(
                                  imageSource: bannerImg,
                                  fit: BoxFit.cover,
                                  fallback: const Center(
                                    child: Icon(Icons.directions_car,
                                        size: 40, color: Colors.grey),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        )
                      else ...[
                        ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: Container(
                            height: 160,
                            width: double.infinity,
                            decoration: BoxDecoration(
                              color: const Color(0xFFF1F5F9),
                              border:
                                  Border.all(color: const Color(0xFFE2E8F0)),
                            ),
                            child: SmartImage(
                              imageSource: bannerImg,
                              fit: BoxFit.cover,
                              fallback: const Center(
                                child: Icon(Icons.directions_car,
                                    size: 40, color: Colors.grey),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 10),
                        Text(
                          b.title,
                          style: const TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.w900,
                            color: darkBg,
                          ),
                        ),
                        Text(b.subtitle,
                            style: const TextStyle(
                                color: Colors.black87, fontSize: 13)),
                        const SizedBox(height: 8),
                        Text('Highlight: ${b.priceText}',
                            style: const TextStyle(
                                fontWeight: FontWeight.w800,
                                color: Color(0xFF047857),
                                fontSize: 13)),
                        const SizedBox(height: 10),
                        Wrap(
                          spacing: 6,
                          runSpacing: 6,
                          children: b.specChips
                              .map((sc) => Container(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 8, vertical: 4),
                                    decoration: BoxDecoration(
                                      color: const Color(0xFFF3F4F6),
                                      borderRadius: BorderRadius.circular(6),
                                      border: Border.all(
                                          color: const Color(0xFFE5E7EB)),
                                    ),
                                    child: Text(sc,
                                        style: const TextStyle(
                                            fontSize: 11,
                                            fontWeight: FontWeight.w600)),
                                  ))
                              .toList(),
                        ),
                      ],
                      const SizedBox(height: 12),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          OutlinedButton.icon(
                            onPressed: () => postBannerDialog(existing: b),
                            icon: const Icon(Icons.edit, size: 16),
                            label: const Text('Edit Banner'),
                          ),
                          const SizedBox(width: 8),
                          IconButton(
                            color: Colors.redAccent,
                            icon: const Icon(Icons.delete_outline),
                            onPressed: () async {
                              final ok = await showDialog<bool>(
                                context: context,
                                builder: (ctx) => AlertDialog(
                                  title: Text('Delete Banner "${b.title}"?'),
                                  actions: [
                                    TextButton(
                                        onPressed: () =>
                                            Navigator.pop(ctx, false),
                                        child: const Text('Cancel')),
                                    FilledButton(
                                      style: FilledButton.styleFrom(
                                          backgroundColor: brandRed),
                                      onPressed: () => Navigator.pop(ctx, true),
                                      child: const Text('Delete'),
                                    ),
                                  ],
                                ),
                              );
                              if (ok == true) {
                                await save(() => s.deleteBanner(b.id));
                                message('Deleted banner.');
                              }
                            },
                          ),
                        ],
                      ),
                    ],
                  );
                },
              ),
            );
          },
        ),
      ],
    );
  }

  Widget categoriesAndBrand() {
    return _AgencyBrandSettingsTab(
      store: s,
      onSave: (config) async {
        await save(() => s.updateAgencyConfig(config));
        message('Agency branding, logo, and contact settings saved!');
      },
      onAddCategory: () => addCategoryDialog(),
      onDeleteCategory: (cat) async {
        await save(() => s.deleteCategory(cat));
        message('Deleted category "$cat".');
      },
    );
  }

  Future<void> addCategoryDialog() async {
    final ctrl = TextEditingController();
    final res = await showDialog<String>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Add Vehicle Category'),
        content: TextField(
          controller: ctrl,
          autofocus: true,
          decoration: const InputDecoration(
            labelText: 'Category Name (e.g. Concept, Armored, Sports)',
          ),
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: darkBg),
            onPressed: () => Navigator.pop(ctx, ctrl.text.trim()),
            child: const Text('Add'),
          ),
        ],
      ),
    );
    if (res != null && res.isNotEmpty) {
      await save(() => s.addCategory(res));
      message('Added category "$res".');
    }
  }

  Widget customers() {
    final list = s.customers
        .where((c) => matches(
            '${c.name} ${c.phone} ${c.email} ${c.licenseNumber} ${c.address} ${c.notes}'))
        .toList();

    final totalCust = s.customers.length;
    final activeRenters =
        s.customers.where((c) => s.customerActiveRentals(c.id) > 0).length;
    final totalCustSpend =
        s.customers.fold<int>(0, (sum, c) => sum + s.customerTotalSpend(c.id));

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // KPI Telemetry Header for Customers
        Row(
          children: [
            Expanded(
              child: _buildCustomerKpiCard(
                title: s.t('total_customers'),
                value: '$totalCust',
                icon: Icons.people_alt_rounded,
                color: const Color(0xFF0F172A),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildCustomerKpiCard(
                title: s.t('active_renters'),
                value: '$activeRenters',
                icon: Icons.directions_car_filled_rounded,
                color: AppColors.brandEmerald,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildCustomerKpiCard(
                title: s.t('total_spent'),
                value: money(totalCustSpend),
                icon: Icons.account_balance_wallet_rounded,
                color: brandRed,
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),

        if (list.isEmpty) empty(s.t('no_customers_found')),

        ...list.map(
          (c) {
            final customerRentals = s.rentalsForCustomer(c.id);
            final activeCount = s.customerActiveRentals(c.id);
            final totalSpent = s.customerTotalSpend(c.id);

            return Container(
              margin: const EdgeInsets.only(bottom: 12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: const Color(0xFFE2E8F0)),
                boxShadow: [
                  BoxShadow(
                      color: Colors.black.withAlpha(5),
                      blurRadius: 10,
                      offset: const Offset(0, 3)),
                ],
              ),
              child: Material(
                color: Colors.transparent,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16)),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      // Avatar
                      CircleAvatar(
                        radius: 24,
                        backgroundColor: const Color(0xFFFEE2E2),
                        foregroundColor: brandRed,
                        child: Text(
                          c.name.isNotEmpty
                              ? c.name.substring(0, 1).toUpperCase()
                              : '?',
                          style: const TextStyle(
                              fontWeight: FontWeight.w900, fontSize: 18),
                        ),
                      ),
                      const SizedBox(width: 14),

                      // Customer Info
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Flexible(
                                  child: Text(
                                    c.name,
                                    style: const TextStyle(
                                        fontWeight: FontWeight.w900,
                                        fontSize: 15,
                                        color: Color(0xFF0F172A)),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 7, vertical: 2),
                                  decoration: BoxDecoration(
                                    color: activeCount > 0
                                        ? AppColors.brandEmerald.withAlpha(25)
                                        : const Color(0xFFF1F5F9),
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  child: Text(
                                    activeCount > 0
                                        ? (s.language == AppLanguage.khmer
                                            ? 'កំពុងជួល'
                                            : 'Renting')
                                        : (s.language == AppLanguage.khmer
                                            ? 'ទំនេរ'
                                            : 'Idle'),
                                    style: TextStyle(
                                      fontSize: 10,
                                      fontWeight: FontWeight.bold,
                                      color: activeCount > 0
                                          ? AppColors.brandEmerald
                                          : const Color(0xFF64748B),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 3),
                            Text(
                              '${c.phone}${c.email.isNotEmpty ? " • ${c.email}" : ""}',
                              style: const TextStyle(
                                  fontSize: 12,
                                  color: Color(0xFF64748B),
                                  fontWeight: FontWeight.w500),
                            ),
                            if (c.licenseNumber.isNotEmpty ||
                                c.address.isNotEmpty) ...[
                              const SizedBox(height: 6),
                              Wrap(
                                spacing: 6,
                                runSpacing: 4,
                                children: [
                                  if (c.licenseNumber.isNotEmpty)
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 6, vertical: 2),
                                      decoration: BoxDecoration(
                                        color: const Color(0xFFEFF6FF),
                                        borderRadius: BorderRadius.circular(4),
                                        border: Border.all(
                                            color: const Color(0xFFBFDBFE)),
                                      ),
                                      child: Text(
                                        'DL: ${c.licenseNumber}',
                                        style: const TextStyle(
                                            fontSize: 10,
                                            fontWeight: FontWeight.w700,
                                            color: Color(0xFF1D4ED8)),
                                      ),
                                    ),
                                  if (c.address.isNotEmpty)
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 6, vertical: 2),
                                      decoration: BoxDecoration(
                                        color: const Color(0xFFF8FAFC),
                                        borderRadius: BorderRadius.circular(4),
                                        border: Border.all(
                                            color: const Color(0xFFE2E8F0)),
                                      ),
                                      child: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          const Icon(Icons.location_on_outlined,
                                              size: 10,
                                              color: Color(0xFF64748B)),
                                          const SizedBox(width: 2),
                                          Text(
                                            c.address,
                                            style: const TextStyle(
                                                fontSize: 10,
                                                color: Color(0xFF475569)),
                                          ),
                                        ],
                                      ),
                                    ),
                                ],
                              ),
                            ],
                          ],
                        ),
                      ),
                      const SizedBox(width: 12),

                      // Metrics Column
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8, vertical: 3),
                            decoration: BoxDecoration(
                              color: const Color(0xFFF8FAFC),
                              borderRadius: BorderRadius.circular(8),
                              border:
                                  Border.all(color: const Color(0xFFE2E8F0)),
                            ),
                            child: Text(
                              '${customerRentals.length} ${s.language == AppLanguage.khmer ? "ការកក់" : "bookings"}',
                              style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 11,
                                  color: Color(0xFF0F172A)),
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            money(totalSpent),
                            style: const TextStyle(
                                fontSize: 11,
                                color: Color(0xFF64748B),
                                fontWeight: FontWeight.w600),
                          ),
                        ],
                      ),
                      const SizedBox(width: 10),

                      // CRUD Actions: View History, Edit, Delete
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: const Icon(Icons.visibility_outlined,
                                size: 18, color: Color(0xFF2563EB)),
                            tooltip: s.t('customer_details'),
                            onPressed: () => viewCustomerDetails(c),
                          ),
                          IconButton(
                            icon: const Icon(Icons.edit_outlined,
                                size: 18, color: Color(0xFF475569)),
                            tooltip: s.t('edit_customer'),
                            onPressed: () => editCustomer(c),
                          ),
                          IconButton(
                            icon: const Icon(Icons.delete_outline_rounded,
                                size: 18, color: Color(0xFFEF4444)),
                            tooltip: s.t('delete_customer'),
                            onPressed: () => deleteCustomer(c),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _buildCustomerKpiCard({
    required String title,
    required String value,
    required IconData icon,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withAlpha(5),
              blurRadius: 10,
              offset: const Offset(0, 2)),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withAlpha(20),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  value,
                  style: TextStyle(
                      fontWeight: FontWeight.w900, fontSize: 16, color: color),
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  title,
                  style: const TextStyle(
                      fontSize: 11,
                      color: Color(0xFF64748B),
                      fontWeight: FontWeight.w600),
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget bookings() {
    final list = s.rentals.reversed.where((r) {
      if (selectedBookingStatus != 'All') {
        final status = r.status(DateTime.now());
        if (selectedBookingStatus == 'Active' && status != 'Active')
          return false;
        if (selectedBookingStatus == 'Upcoming' && status != 'Upcoming')
          return false;
        if (selectedBookingStatus == 'Returned' && !r.returned) return false;
        if (selectedBookingStatus == 'Overdue' && status != 'Overdue')
          return false;
        if (selectedBookingStatus == 'Unpaid' && r.balanceCents <= 0)
          return false;
      }
      if (query.isNotEmpty) {
        return matches(
            '${r.id} ${s.vehicle(r.vehicleId).name} ${s.customer(r.customerId).name} ${r.status(DateTime.now())}');
      }
      return true;
    }).toList();

    final isKhmer = s.language == AppLanguage.khmer;
    final totalBookings = s.rentals.length;
    final activeCount = s.activeRentalsCount;
    final returnedCount = s.returnedRentalsCount;
    final totalRevenue = s.totalRentalRevenueCents;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // KPI Summary Cards Header
        LayoutBuilder(
          builder: (context, constraints) {
            final isSmall = constraints.maxWidth < 640;
            return Wrap(
              spacing: 12,
              runSpacing: 12,
              children: [
                SizedBox(
                  width: isSmall
                      ? constraints.maxWidth
                      : (constraints.maxWidth - 36) / 4,
                  child: _buildCustomerKpiCard(
                    title: s.t('total_bookings'),
                    value: '$totalBookings',
                    icon: Icons.receipt_long_rounded,
                    color: const Color(0xFF0F172A),
                  ),
                ),
                SizedBox(
                  width: isSmall
                      ? constraints.maxWidth
                      : (constraints.maxWidth - 36) / 4,
                  child: _buildCustomerKpiCard(
                    title: s.t('active_rentals'),
                    value: '$activeCount',
                    icon: Icons.key_rounded,
                    color: AppColors.brandEmerald,
                  ),
                ),
                SizedBox(
                  width: isSmall
                      ? constraints.maxWidth
                      : (constraints.maxWidth - 36) / 4,
                  child: _buildCustomerKpiCard(
                    title: s.t('returned_bookings'),
                    value: '$returnedCount',
                    icon: Icons.assignment_turned_in_rounded,
                    color: const Color(0xFF3B82F6),
                  ),
                ),
                SizedBox(
                  width: isSmall
                      ? constraints.maxWidth
                      : (constraints.maxWidth - 36) / 4,
                  child: _buildCustomerKpiCard(
                    title: s.t('revenue_collected'),
                    value: money(totalRevenue),
                    icon: Icons.account_balance_wallet_rounded,
                    color: brandRed,
                  ),
                ),
              ],
            );
          },
        ),
        const SizedBox(height: 16),

        // Filter status chips
        Wrap(
          spacing: 8,
          runSpacing: 8,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: [
            Text('${s.t('status_filter')}:',
                style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textMuted)),
            ChoiceChip(
              label: Text(s.t('all_status'),
                  style: const TextStyle(
                      fontSize: 11, fontWeight: FontWeight.bold)),
              selected: selectedBookingStatus == 'All',
              selectedColor: const Color(0xFFECFDF5),
              onSelected: (sel) =>
                  setState(() => selectedBookingStatus = 'All'),
            ),
            ChoiceChip(
              label: Text(isKhmer ? 'កំពុងជួល' : 'Active',
                  style: const TextStyle(
                      fontSize: 11, fontWeight: FontWeight.bold)),
              selected: selectedBookingStatus == 'Active',
              selectedColor: const Color(0xFFECFDF5),
              onSelected: (sel) => setState(
                  () => selectedBookingStatus = sel ? 'Active' : 'All'),
            ),
            ChoiceChip(
              label: Text(isKhmer ? 'ជិតមកដល់' : 'Upcoming',
                  style: const TextStyle(
                      fontSize: 11, fontWeight: FontWeight.bold)),
              selected: selectedBookingStatus == 'Upcoming',
              selectedColor: const Color(0xFFEFF6FF),
              onSelected: (sel) => setState(
                  () => selectedBookingStatus = sel ? 'Upcoming' : 'All'),
            ),
            ChoiceChip(
              label: Text(isKhmer ? 'បានប្រគល់រួច' : 'Returned',
                  style: const TextStyle(
                      fontSize: 11, fontWeight: FontWeight.bold)),
              selected: selectedBookingStatus == 'Returned',
              selectedColor: const Color(0xFFF1F5F9),
              onSelected: (sel) => setState(
                  () => selectedBookingStatus = sel ? 'Returned' : 'All'),
            ),
            ChoiceChip(
              label: Text(isKhmer ? 'ហួសកាលកំណត់' : 'Overdue',
                  style: const TextStyle(
                      fontSize: 11, fontWeight: FontWeight.bold)),
              selected: selectedBookingStatus == 'Overdue',
              selectedColor: const Color(0xFFFEF2F2),
              onSelected: (sel) => setState(
                  () => selectedBookingStatus = sel ? 'Overdue' : 'All'),
            ),
            ChoiceChip(
              label: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(isKhmer ? 'នៅសល់ជំពាក់' : 'Unpaid Due',
                      style: const TextStyle(
                          fontSize: 11, fontWeight: FontWeight.bold)),
                  if (s.balanceDueRentalsCount > 0) ...[
                    const SizedBox(width: 4),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
                      decoration: BoxDecoration(
                        color: const Color(0xFFD97706),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        '${s.balanceDueRentalsCount}',
                        style: const TextStyle(
                          fontSize: 9,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ],
                ],
              ),
              selected: selectedBookingStatus == 'Unpaid',
              selectedColor: const Color(0xFFFEF3C7),
              onSelected: (sel) => setState(
                  () => selectedBookingStatus = sel ? 'Unpaid' : 'All'),
            ),
            if (selectedBookingStatus != 'All' || query.isNotEmpty)
              TextButton.icon(
                style: TextButton.styleFrom(foregroundColor: brandRed),
                onPressed: () => setState(() {
                  selectedBookingStatus = 'All';
                  query = '';
                }),
                icon: const Icon(Icons.clear_all, size: 16),
                label: Text(s.t('reset_filters'),
                    style: const TextStyle(
                        fontSize: 11, fontWeight: FontWeight.bold)),
              ),
          ],
        ),
        const SizedBox(height: 14),

        if (list.isEmpty) empty(s.t('no_bookings_found')),
        ...list.map(rentalCard),
      ],
    );
  }

  Widget rentalCard(Rental r) {
    final v = s.vehicle(r.vehicleId);
    final c = s.customer(r.customerId);
    final now = DateTime.now();
    final status = r.status(now);
    final isKhmer = s.language == AppLanguage.khmer;

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
        if (r.balanceCents > 0) {
          statusColor = const Color(0xFFD97706);
          statusLabel = isKhmer ? 'បានប្រគល់ • នៅសល់ជំពាក់' : 'Returned (Debt Due)';
        } else {
          statusColor = const Color(0xFF64748B);
          statusLabel = isKhmer ? 'បានប្រគល់រួច' : 'Returned';
        }
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: cardBorder),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(6),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Row 1: Vehicle & Status Badges
          Row(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: Container(
                  width: 84,
                  height: 58,
                  decoration: BoxDecoration(
                    color: const Color(0xFFF1F5F9),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: const Color(0xFFE2E8F0)),
                  ),
                  child: SmartImage(
                    imageSource: v.imageUrl,
                    fit: BoxFit.cover,
                    fallback: const Center(
                      child: Icon(Icons.directions_car_filled_rounded,
                          size: 26, color: Color(0xFF0F172A)),
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
                          fontSize: 17,
                          fontWeight: FontWeight.w900,
                          color: Color(0xFF0F172A)),
                    ),
                    Text(
                      '${v.brand.toUpperCase()} • ${v.type} • Plate: ${v.plate}',
                      style: const TextStyle(
                          fontSize: 12, color: AppColors.textMuted),
                    ),
                  ],
                ),
              ),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: statusColor.withAlpha(25),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: statusColor.withAlpha(80)),
                ),
                child: Text(
                  statusLabel,
                  style: TextStyle(
                    color: statusColor,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Row 2: Customer info, Booking ID & Dates
          Wrap(
            spacing: 12,
            runSpacing: 6,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.person_outline_rounded,
                      size: 16, color: Color(0xFF64748B)),
                  const SizedBox(width: 6),
                  Text(
                    c.name,
                    style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF334155)),
                  ),
                ],
              ),
              Container(
                  width: 4,
                  height: 4,
                  decoration: const BoxDecoration(
                      color: Colors.grey, shape: BoxShape.circle)),
              Text(
                r.id,
                style: const TextStyle(
                    fontSize: 12,
                    fontFamily: 'monospace',
                    color: Color(0xFF64748B)),
              ),
              Container(
                  width: 4,
                  height: 4,
                  decoration: const BoxDecoration(
                      color: Colors.grey, shape: BoxShape.circle)),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.calendar_month_outlined,
                      size: 15, color: Color(0xFF64748B)),
                  const SizedBox(width: 6),
                  Text(
                    '${dateLabel(r.start)} → ${dateLabel(r.end)} (${r.days} ${isKhmer ? "ថ្ងៃ" : "Days"})',
                    style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF475569)),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Row 3: Financial metrics
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: BoxDecoration(
              color: const Color(0xFFF8FAFC),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: const Color(0xFFE2E8F0)),
            ),
            child: Wrap(
              alignment: WrapAlignment.spaceBetween,
              crossAxisAlignment: WrapCrossAlignment.center,
              spacing: 12,
              runSpacing: 8,
              children: [
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text('${s.t('total')}: ',
                        style: const TextStyle(
                            fontSize: 12, color: AppColors.textMuted)),
                    Text(money(r.totalCents),
                        style: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF0F172A))),
                  ],
                ),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text('${s.t('paid_deposit')}: ',
                        style: const TextStyle(
                            fontSize: 12, color: AppColors.textMuted)),
                    Text(money(r.paidCents),
                        style: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.bold,
                            color: AppColors.brandEmerald)),
                  ],
                ),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text('${s.t('balance_due')}: ',
                        style: const TextStyle(
                            fontSize: 12, color: AppColors.textMuted)),
                    Text(
                      money(r.balanceCents),
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w900,
                        color: r.balanceCents == 0
                            ? AppColors.brandEmerald
                            : AppColors.brandRed,
                      ),
                    ),
                  ],
                ),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: r.balanceCents == 0
                        ? AppColors.brandEmerald.withAlpha(20)
                        : AppColors.brandAmber.withAlpha(20),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    r.balanceCents == 0
                        ? (isKhmer ? 'បានបង់ពេញ' : 'PAID')
                        : (isKhmer ? 'នៅសល់ប្រាក់' : 'DUE'),
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      color: r.balanceCents == 0
                          ? AppColors.brandEmerald
                          : AppColors.brandAmber,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),

          // Row 4: Action Buttons (View Details, Edit, Record Payment, Return Car, Delete)
          Wrap(
            spacing: 8,
            runSpacing: 8,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              // View Details
              FilledButton.tonalIcon(
                style: FilledButton.styleFrom(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8)),
                ),
                onPressed: () => showDialog(
                  context: context,
                  builder: (_) => BookingDetailsDialog(
                    store: s,
                    rental: r,
                    onUpdated: () => setState(() {}),
                  ),
                ),
                icon: const Icon(Icons.remove_red_eye_outlined, size: 16),
                label: Text(s.t('view_details'),
                    style: const TextStyle(
                        fontSize: 12, fontWeight: FontWeight.bold)),
              ),

              // Edit Booking
              OutlinedButton.icon(
                style: OutlinedButton.styleFrom(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8)),
                ),
                onPressed: () async {
                  final updated = await showDialog<bool>(
                    context: context,
                    builder: (_) => BookingFormDialog(store: s, rental: r),
                  );
                  if (updated == true) setState(() {});
                },
                icon: const Icon(Icons.edit_outlined, size: 16),
                label: Text(s.t('edit_booking'),
                    style: const TextStyle(
                        fontSize: 12, fontWeight: FontWeight.bold)),
              ),

              // Record Payment (if balance > 0)
              if (r.balanceCents > 0)
                FilledButton.icon(
                  style: FilledButton.styleFrom(
                    backgroundColor: AppColors.brandEmerald,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 14, vertical: 10),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8)),
                  ),
                  onPressed: () => recordPayment(r),
                  icon: const Icon(Icons.payment_rounded, size: 16),
                  label: Text(s.t('record_payment'),
                      style: const TextStyle(
                          fontSize: 12, fontWeight: FontWeight.bold)),
                ),

              // Return Car (if not returned)
              if (!r.returned)
                OutlinedButton.icon(
                  style: OutlinedButton.styleFrom(
                    foregroundColor: (r.balanceCents > 0 || status == 'Overdue')
                        ? const Color(0xFFD97706)
                        : AppColors.brandEmerald,
                    side: BorderSide(
                      color: (r.balanceCents > 0 || status == 'Overdue')
                          ? const Color(0xFFF59E0B)
                          : AppColors.brandEmerald,
                    ),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 14, vertical: 10),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8)),
                  ),
                  onPressed: () => returnRental(r),
                  icon: Icon(
                    (r.balanceCents > 0 || status == 'Overdue')
                        ? Icons.assignment_return_rounded
                        : Icons.assignment_turned_in_outlined,
                    size: 16,
                  ),
                  label: Text(
                    (status == 'Overdue' && r.balanceCents > 0)
                        ? (isKhmer ? 'ប្រគល់រថយន្ត (ហួស & ជំពាក់)' : 'Return Car (Overdue & Due)')
                        : (status == 'Overdue')
                            ? (isKhmer ? 'ប្រគល់រថយន្ត (ហួសកំណត់)' : 'Return Car (Overdue)')
                            : (r.balanceCents > 0)
                                ? (isKhmer ? 'ប្រគល់រថយន្ត (នៅសល់ប្រាក់)' : 'Return Car (Balance Due)')
                                : s.t('return_vehicle'),
                    style: const TextStyle(
                        fontSize: 12, fontWeight: FontWeight.bold),
                  ),
                ),

              // Settle Remaining Debt (if already returned but has balance > 0)
              if (r.returned && r.balanceCents > 0)
                FilledButton.tonalIcon(
                  style: FilledButton.styleFrom(
                    foregroundColor: const Color(0xFFB45309),
                    backgroundColor: const Color(0xFFFEF3C7),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 14, vertical: 10),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8)),
                  ),
                  onPressed: () => recordPayment(r),
                  icon: const Icon(Icons.handshake_outlined, size: 16),
                  label: Text(s.t('settle_debt'),
                      style: const TextStyle(
                          fontSize: 12, fontWeight: FontWeight.bold)),
                ),

              // Delete Booking
              IconButton(
                icon: const Icon(Icons.delete_outline_rounded,
                    color: AppColors.brandRed, size: 20),
                tooltip: s.t('delete_booking'),
                onPressed: () async {
                  if (!r.returned && status == 'Active') {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                          content: Text(s.t('cannot_delete_active_booking'))),
                    );
                    return;
                  }

                  final confirmed = await showDialog<bool>(
                    context: context,
                    builder: (ctx) => AlertDialog(
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16)),
                      title: Text(s.t('delete_booking')),
                      content: Text(s.t('confirm_delete_booking')),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(ctx, false),
                          child: Text(s.t('cancel')),
                        ),
                        FilledButton(
                          style: FilledButton.styleFrom(
                              backgroundColor: AppColors.brandRed),
                          onPressed: () => Navigator.pop(ctx, true),
                          child: Text(s.t('delete')),
                        ),
                      ],
                    ),
                  );

                  if (confirmed == true) {
                    await s.deleteRental(r.id);
                    setState(() {});
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text(s.t('booking_deleted'))),
                      );
                    }
                  }
                },
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget returnsHub() {
    final now = DateTime.now();

    final list = s.rentals.reversed.where((r) {
      final status = r.status(now);
      if (selectedReturnStatus == 'Overdue') {
        if (status != 'Overdue') return false;
      } else if (selectedReturnStatus == 'Unpaid') {
        if (r.balanceCents <= 0) return false;
      } else if (selectedReturnStatus == 'Returned') {
        if (!r.returned) return false;
      } else {
        // 'All': by default, prioritize vehicles currently out on rent (active & overdue), unless search query is active
        if (query.isEmpty && r.returned) return false;
      }

      if (query.isNotEmpty) {
        final v = s.vehicle(r.vehicleId);
        final c = s.customer(r.customerId);
        return matches(
            '${r.id} ${v.name} ${v.plate} ${v.brand} ${c.name} ${c.phone} $status');
      }
      return true;
    }).toList();

    final activeCount = s.activeRentalsCount;
    final overdueCount = s.overdueRentalsCount;
    final unpaidBalanceCount = s.balanceDueRentalsCount;
    final returnedCount = s.returnedRentalsCount;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // KPI Summary Cards Header
        LayoutBuilder(
          builder: (context, constraints) {
            final isSmall = constraints.maxWidth < 640;
            return Wrap(
              spacing: 12,
              runSpacing: 12,
              children: [
                SizedBox(
                  width: isSmall
                      ? constraints.maxWidth
                      : (constraints.maxWidth - 36) / 4,
                  child: _buildCustomerKpiCard(
                    title: s.t('awaiting_return'),
                    value: '$activeCount',
                    icon: Icons.directions_car_rounded,
                    color: const Color(0xFF0F172A),
                  ),
                ),
                SizedBox(
                  width: isSmall
                      ? constraints.maxWidth
                      : (constraints.maxWidth - 36) / 4,
                  child: _buildCustomerKpiCard(
                    title: s.t('overdue_only'),
                    value: '$overdueCount',
                    icon: Icons.warning_amber_rounded,
                    color: AppColors.brandRed,
                  ),
                ),
                SizedBox(
                  width: isSmall
                      ? constraints.maxWidth
                      : (constraints.maxWidth - 36) / 4,
                  child: _buildCustomerKpiCard(
                    title: s.t('unpaid_only'),
                    value: '$unpaidBalanceCount',
                    icon: Icons.account_balance_wallet_rounded,
                    color: const Color(0xFFD97706),
                  ),
                ),
                SizedBox(
                  width: isSmall
                      ? constraints.maxWidth
                      : (constraints.maxWidth - 36) / 4,
                  child: _buildCustomerKpiCard(
                    title: s.t('returned_history'),
                    value: '$returnedCount',
                    icon: Icons.assignment_turned_in_rounded,
                    color: const Color(0xFF3B82F6),
                  ),
                ),
              ],
            );
          },
        ),
        const SizedBox(height: 16),

        // Filter status chips
        Wrap(
          spacing: 8,
          runSpacing: 8,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: [
            Text('${s.t('status_filter')}:',
                style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textMuted)),
            ChoiceChip(
              label: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(s.t('all_returns'),
                      style: const TextStyle(
                          fontSize: 11, fontWeight: FontWeight.bold)),
                  if (activeCount > 0) ...[
                    const SizedBox(width: 4),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
                      decoration: BoxDecoration(
                        color: const Color(0xFF0F172A),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        '$activeCount',
                        style: const TextStyle(
                            fontSize: 9,
                            fontWeight: FontWeight.bold,
                            color: Colors.white),
                      ),
                    ),
                  ],
                ],
              ),
              selected: selectedReturnStatus == 'All',
              selectedColor: const Color(0xFFECFDF5),
              onSelected: (sel) => setState(() => selectedReturnStatus = 'All'),
            ),
            ChoiceChip(
              label: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(s.t('overdue_only'),
                      style: const TextStyle(
                          fontSize: 11, fontWeight: FontWeight.bold)),
                  if (overdueCount > 0) ...[
                    const SizedBox(width: 4),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
                      decoration: BoxDecoration(
                        color: AppColors.brandRed,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        '$overdueCount',
                        style: const TextStyle(
                            fontSize: 9,
                            fontWeight: FontWeight.bold,
                            color: Colors.white),
                      ),
                    ),
                  ],
                ],
              ),
              selected: selectedReturnStatus == 'Overdue',
              selectedColor: const Color(0xFFFEF2F2),
              onSelected: (sel) => setState(
                  () => selectedReturnStatus = sel ? 'Overdue' : 'All'),
            ),
            ChoiceChip(
              label: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(s.t('unpaid_only'),
                      style: const TextStyle(
                          fontSize: 11, fontWeight: FontWeight.bold)),
                  if (unpaidBalanceCount > 0) ...[
                    const SizedBox(width: 4),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
                      decoration: BoxDecoration(
                        color: const Color(0xFFD97706),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        '$unpaidBalanceCount',
                        style: const TextStyle(
                            fontSize: 9,
                            fontWeight: FontWeight.bold,
                            color: Colors.white),
                      ),
                    ),
                  ],
                ],
              ),
              selected: selectedReturnStatus == 'Unpaid',
              selectedColor: const Color(0xFFFEF3C7),
              onSelected: (sel) => setState(
                  () => selectedReturnStatus = sel ? 'Unpaid' : 'All'),
            ),
            ChoiceChip(
              label: Text(s.t('returned_history'),
                  style: const TextStyle(
                      fontSize: 11, fontWeight: FontWeight.bold)),
              selected: selectedReturnStatus == 'Returned',
              selectedColor: const Color(0xFFEFF6FF),
              onSelected: (sel) => setState(
                  () => selectedReturnStatus = sel ? 'Returned' : 'All'),
            ),
            if (selectedReturnStatus != 'All' || query.isNotEmpty)
              TextButton.icon(
                style: TextButton.styleFrom(foregroundColor: brandRed),
                onPressed: () => setState(() {
                  selectedReturnStatus = 'All';
                  query = '';
                }),
                icon: const Icon(Icons.clear_all, size: 16),
                label: Text(s.t('reset_filters'),
                    style: const TextStyle(
                        fontSize: 11, fontWeight: FontWeight.bold)),
              ),
          ],
        ),
        const SizedBox(height: 14),

        if (list.isEmpty) empty(s.t('no_returns_matching')),
        ...list.map(_returnCarCard),
      ],
    );
  }

  Widget _returnCarCard(Rental r) {
    final v = s.vehicle(r.vehicleId);
    final c = s.customer(r.customerId);
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final endDate = DateTime(r.end.year, r.end.month, r.end.day);
    final isOverdue = !r.returned && today.isAfter(endDate);
    final overdueDays = isOverdue ? today.difference(endDate).inDays : 0;
    final isKhmer = s.language == AppLanguage.khmer;

    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isOverdue ? const Color(0xFFFCA5A5) : cardBorder,
          width: isOverdue ? 1.5 : 1.0,
        ),
        boxShadow: [
          BoxShadow(
            color: isOverdue ? Colors.red.withAlpha(12) : Colors.black.withAlpha(6),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header: Vehicle info, plate, and status badges
          Row(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: Container(
                  width: 84,
                  height: 58,
                  decoration: BoxDecoration(
                    color: const Color(0xFFF1F5F9),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: const Color(0xFFE2E8F0)),
                  ),
                  child: SmartImage(
                    imageSource: v.imageUrl,
                    fit: BoxFit.cover,
                    fallback: const Center(
                      child: Icon(Icons.directions_car_filled_rounded,
                          size: 26, color: Color(0xFF0F172A)),
                    ),
                  ),
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
                            v.name,
                            style: const TextStyle(
                                fontSize: 17,
                                fontWeight: FontWeight.w900,
                                color: Color(0xFF0F172A)),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        if (isOverdue) ...[
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                            decoration: BoxDecoration(
                              color: const Color(0xFFFEF2F2),
                              borderRadius: BorderRadius.circular(6),
                              border: Border.all(color: const Color(0xFFF87171)),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(Icons.warning_amber_rounded, size: 12, color: Color(0xFFDC2626)),
                                const SizedBox(width: 3),
                                Text(
                                  '$overdueDays ${isKhmer ? "ថ្ងៃហួសកំណត់" : "Days Overdue!"}',
                                  style: const TextStyle(
                                    fontSize: 10,
                                    fontWeight: FontWeight.bold,
                                    color: Color(0xFFDC2626),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ],
                    ),
                    Text(
                      '${v.brand.toUpperCase()} • ${v.type} • Plate: ${v.plate}',
                      style: const TextStyle(fontSize: 12, color: AppColors.textMuted),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: r.returned
                      ? (r.balanceCents > 0
                          ? const Color(0xFFFEF3C7)
                          : const Color(0xFFF1F5F9))
                      : (isOverdue
                          ? const Color(0xFFFEF2F2)
                          : const Color(0xFFECFDF5)),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: r.returned
                        ? (r.balanceCents > 0 ? const Color(0xFFF59E0B) : const Color(0xFFCBD5E1))
                        : (isOverdue ? const Color(0xFFF87171) : const Color(0xFFA7F3D0)),
                  ),
                ),
                child: Text(
                  r.returned
                      ? (r.balanceCents > 0
                          ? (isKhmer ? 'បានប្រគល់ • នៅសល់ជំពាក់' : 'Returned (Debt Due)')
                          : (isKhmer ? 'បានប្រគល់រួច' : 'Returned'))
                      : (isOverdue
                          ? (isKhmer ? 'ហួសកាលកំណត់' : 'Overdue')
                          : (isKhmer ? 'កំពុងជួល' : 'Active')),
                  style: TextStyle(
                    color: r.returned
                        ? (r.balanceCents > 0 ? const Color(0xFFD97706) : const Color(0xFF64748B))
                        : (isOverdue ? const Color(0xFFDC2626) : const Color(0xFF059669)),
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Customer, booking ID, dates
          Wrap(
            spacing: 12,
            runSpacing: 6,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.person_outline_rounded, size: 16, color: Color(0xFF64748B)),
                  const SizedBox(width: 6),
                  Text(
                    c.name,
                    style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Color(0xFF334155)),
                  ),
                ],
              ),
              Text(
                '• ${c.phone}',
                style: const TextStyle(fontSize: 12, color: Color(0xFF64748B)),
              ),
              Text(
                '• Booking: ${r.id}',
                style: const TextStyle(fontSize: 12, fontFamily: 'monospace', color: Color(0xFF64748B)),
              ),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.calendar_month_outlined, size: 15, color: Color(0xFF64748B)),
                  const SizedBox(width: 6),
                  Text(
                    '${dateLabel(r.start)} → ${dateLabel(r.end)} (${r.days} ${isKhmer ? "ថ្ងៃ" : "Days"})',
                    style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Color(0xFF475569)),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Financial metrics bar
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: BoxDecoration(
              color: const Color(0xFFF8FAFC),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: const Color(0xFFE2E8F0)),
            ),
            child: Wrap(
              alignment: WrapAlignment.spaceBetween,
              crossAxisAlignment: WrapCrossAlignment.center,
              spacing: 12,
              runSpacing: 8,
              children: [
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text('${s.t('total')}: ', style: const TextStyle(fontSize: 12, color: AppColors.textMuted)),
                    Text(money(r.totalCents),
                        style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Color(0xFF0F172A))),
                  ],
                ),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text('${s.t('paid_deposit')}: ', style: const TextStyle(fontSize: 12, color: AppColors.textMuted)),
                    Text(money(r.paidCents),
                        style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: AppColors.brandEmerald)),
                  ],
                ),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text('${s.t('balance_due')}: ', style: const TextStyle(fontSize: 12, color: AppColors.textMuted)),
                    Text(
                      money(r.balanceCents),
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w900,
                        color: r.balanceCents == 0 ? AppColors.brandEmerald : AppColors.brandRed,
                      ),
                    ),
                  ],
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: r.balanceCents == 0
                        ? AppColors.brandEmerald.withAlpha(20)
                        : const Color(0xFFF59E0B).withAlpha(20),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    r.balanceCents == 0
                        ? (isKhmer ? 'បានបង់ពេញ' : 'PAID')
                        : (isKhmer ? 'នៅសល់ប្រាក់ជំពាក់' : 'UNPAID DUE'),
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      color: r.balanceCents == 0 ? AppColors.brandEmerald : const Color(0xFFD97706),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),

          // Primary Return / Settle Actions
          Wrap(
            spacing: 8,
            runSpacing: 8,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              if (!r.returned)
                FilledButton.icon(
                  style: FilledButton.styleFrom(
                    backgroundColor: (r.balanceCents > 0 || isOverdue)
                        ? const Color(0xFFD97706)
                        : AppColors.brandEmerald,
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                  onPressed: () => returnRental(r),
                  icon: const Icon(Icons.assignment_turned_in_rounded, size: 18),
                  label: Text(
                    isOverdue && r.balanceCents > 0
                        ? (isKhmer ? 'ប្រគល់រថយន្ត (ហួស & ជំពាក់)' : 'Check-In & Return (Overdue & Due)')
                        : isOverdue
                            ? (isKhmer ? 'ប្រគល់រថយន្ត (ហួសកាលកំណត់)' : 'Check-In & Return (Overdue)')
                            : r.balanceCents > 0
                                ? (isKhmer ? 'ប្រគល់រថយន្ត (នៅសល់ប្រាក់)' : 'Check-In & Return (Balance Due)')
                                : (isKhmer ? 'ត្រួតពិនិត្យ & ប្រគល់រថយន្ត' : 'Check-In & Return Vehicle'),
                    style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                  ),
                ),
              if (r.returned && r.balanceCents > 0)
                FilledButton.tonalIcon(
                  style: FilledButton.styleFrom(
                    foregroundColor: const Color(0xFFB45309),
                    backgroundColor: const Color(0xFFFEF3C7),
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                  onPressed: () => recordPayment(r),
                  icon: const Icon(Icons.payments_rounded, size: 18),
                  label: Text(
                    isKhmer
                        ? 'ទូទាត់បំណុលនៅសល់ (${money(r.balanceCents)})'
                        : 'Settle Debt Due (${money(r.balanceCents)})',
                    style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                  ),
                ),
              OutlinedButton.icon(
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                ),
                onPressed: () => showDialog(
                  context: context,
                  builder: (_) => BookingDetailsDialog(
                    store: s,
                    rental: r,
                    onUpdated: () => setState(() {}),
                  ),
                ),
                icon: const Icon(Icons.description_outlined, size: 16),
                label: Text(s.t('booking_details'),
                    style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Future<void> _openQuickReturnSelector() async {
    final active = s.rentals.where((r) => !r.returned).toList();
    if (active.isEmpty) {
      message(s.language == AppLanguage.khmer
          ? 'មិនមានរថយន្តកំពុងជួលនៅក្រៅទេ គ្រប់រថយន្តស្ថិតក្នុងស្តុក។'
          : 'All rental vehicles are currently checked into showroom inventory.');
      return;
    }
    if (active.length == 1) {
      await returnRental(active.first);
      return;
    }
    final selected = await showModalBottomSheet<Rental>(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  s.t('quick_return_action'),
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 12),
                Flexible(
                  child: ListView.separated(
                    shrinkWrap: true,
                    itemCount: active.length,
                    separatorBuilder: (_, __) => const Divider(height: 1),
                    itemBuilder: (ctx, idx) {
                      final r = active[idx];
                      final v = s.vehicle(r.vehicleId);
                      final c = s.customer(r.customerId);
                      final isOverdue = DateTime.now().isAfter(r.end);
                      return ListTile(
                        leading: CircleAvatar(
                          backgroundColor: isOverdue ? const Color(0xFFFEF2F2) : const Color(0xFFF1F5F9),
                          child: Icon(
                            isOverdue ? Icons.warning_amber_rounded : Icons.directions_car_rounded,
                            color: isOverdue ? const Color(0xFFDC2626) : const Color(0xFF0F172A),
                          ),
                        ),
                        title: Text('${v.name} (${v.plate})', style: const TextStyle(fontWeight: FontWeight.bold)),
                        subtitle: Text('${c.name} • ${r.id} • ${money(r.balanceCents)} Due'),
                        trailing: const Icon(Icons.chevron_right),
                        onTap: () => Navigator.pop(ctx, r),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
    if (selected != null) {
      await returnRental(selected);
    }
  }

  Widget payments() {
    final list = s.rentals.reversed.where((r) {
      if (selectedPaymentStatus != 'All') {
        if (selectedPaymentStatus == 'Paid' && r.balanceCents > 0) return false;
        if (selectedPaymentStatus == 'Partial' &&
            (r.paidCents == 0 || r.balanceCents == 0)) return false;
        if (selectedPaymentStatus == 'Unpaid' && r.paidCents > 0) return false;
      }
      if (query.isNotEmpty) {
        final v = s.vehicle(r.vehicleId);
        final c = s.customer(r.customerId);
        return matches(
            '${r.id} ${c.name} ${c.phone} ${v.brand} ${v.name} ${v.plate} ${r.notes}');
      }
      return true;
    }).toList();

    final totalBilled = s.totalRentalBilledCents;
    final totalCollected = s.totalRentalRevenueCents;
    final totalReceivables = s.totalRentalReceivablesCents;
    final fullyPaidCount = s.fullyPaidRentalsCount;
    final partialCount = s.partialPaidRentalsCount;
    final unpaidCount = s.unpaidRentalsCount;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // KPI Summary Cards Header
        LayoutBuilder(
          builder: (context, constraints) {
            final isSmall = constraints.maxWidth < 640;
            return Wrap(
              spacing: 12,
              runSpacing: 12,
              children: [
                SizedBox(
                  width: isSmall
                      ? constraints.maxWidth
                      : (constraints.maxWidth - 36) / 4,
                  child: _buildCustomerKpiCard(
                    title: s.t('total_billed'),
                    value: money(totalBilled),
                    icon: Icons.receipt_long_rounded,
                    color: const Color(0xFF0F172A),
                  ),
                ),
                SizedBox(
                  width: isSmall
                      ? constraints.maxWidth
                      : (constraints.maxWidth - 36) / 4,
                  child: _buildCustomerKpiCard(
                    title: s.t('total_collected'),
                    value: money(totalCollected),
                    icon: Icons.account_balance_wallet_rounded,
                    color: AppColors.brandEmerald,
                  ),
                ),
                SizedBox(
                  width: isSmall
                      ? constraints.maxWidth
                      : (constraints.maxWidth - 36) / 4,
                  child: _buildCustomerKpiCard(
                    title: s.t('total_receivables'),
                    value: money(totalReceivables),
                    icon: Icons.pending_actions_rounded,
                    color: totalReceivables > 0
                        ? AppColors.brandRed
                        : const Color(0xFF64748B),
                  ),
                ),
                SizedBox(
                  width: isSmall
                      ? constraints.maxWidth
                      : (constraints.maxWidth - 36) / 4,
                  child: _buildCustomerKpiCard(
                    title: s.t('fully_paid'),
                    value: '$fullyPaidCount / ${s.rentals.length}',
                    icon: Icons.verified_rounded,
                    color: const Color(0xFF3B82F6),
                  ),
                ),
              ],
            );
          },
        ),
        const SizedBox(height: 16),

        // Filter chips & quick reset
        Wrap(
          spacing: 8,
          runSpacing: 8,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: [
            Text(
              '${s.t('status_filter')}:',
              style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textMuted),
            ),
            ChoiceChip(
              label: Text(s.t('filter_all'),
                  style: const TextStyle(
                      fontSize: 11, fontWeight: FontWeight.bold)),
              selected: selectedPaymentStatus == 'All',
              selectedColor: const Color(0xFFF1F5F9),
              onSelected: (sel) =>
                  setState(() => selectedPaymentStatus = 'All'),
            ),
            ChoiceChip(
              label: Text(
                '${s.t('filter_paid')} ($fullyPaidCount)',
                style:
                    const TextStyle(fontSize: 11, fontWeight: FontWeight.bold),
              ),
              selected: selectedPaymentStatus == 'Paid',
              selectedColor: const Color(0xFFECFDF5),
              onSelected: (sel) =>
                  setState(() => selectedPaymentStatus = sel ? 'Paid' : 'All'),
            ),
            ChoiceChip(
              label: Text(
                '${s.t('filter_partial')} ($partialCount)',
                style:
                    const TextStyle(fontSize: 11, fontWeight: FontWeight.bold),
              ),
              selected: selectedPaymentStatus == 'Partial',
              selectedColor: const Color(0xFFFFFBEB),
              onSelected: (sel) => setState(
                  () => selectedPaymentStatus = sel ? 'Partial' : 'All'),
            ),
            ChoiceChip(
              label: Text(
                '${s.t('filter_unpaid')} ($unpaidCount)',
                style:
                    const TextStyle(fontSize: 11, fontWeight: FontWeight.bold),
              ),
              selected: selectedPaymentStatus == 'Unpaid',
              selectedColor: const Color(0xFFFEF2F2),
              onSelected: (sel) => setState(
                  () => selectedPaymentStatus = sel ? 'Unpaid' : 'All'),
            ),
            if (selectedPaymentStatus != 'All' || query.isNotEmpty)
              TextButton.icon(
                style: TextButton.styleFrom(foregroundColor: brandRed),
                onPressed: () => setState(() {
                  selectedPaymentStatus = 'All';
                  query = '';
                }),
                icon: const Icon(Icons.clear_all, size: 16),
                label: Text(s.t('reset_filters'),
                    style: const TextStyle(
                        fontSize: 11, fontWeight: FontWeight.bold)),
              ),
          ],
        ),
        const SizedBox(height: 14),

        if (list.isEmpty) empty(s.t('no_payments_found')),
        ...list.map(paymentCard),
      ],
    );
  }

  Widget paymentCard(Rental r) {
    final v = s.vehicle(r.vehicleId);
    final c = s.customer(r.customerId);
    final isKhmer = s.language == AppLanguage.khmer;
    final total = r.totalCents;
    final paid = r.paidCents;
    final balance = r.balanceCents;
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
            : (isKhmer ? 'មិនទាន់ទូទាត់' : 'Unpaid');

    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: cardBorder),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(6),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Row 1: Vehicle Photo, Name & Status Badge
          Row(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: Container(
                  width: 84,
                  height: 58,
                  decoration: BoxDecoration(
                    color: const Color(0xFFF1F5F9),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: const Color(0xFFE2E8F0)),
                  ),
                  child: SmartImage(
                    imageSource: v.imageUrl,
                    fit: BoxFit.cover,
                    fallback: const Center(
                      child: Icon(Icons.directions_car_filled_rounded,
                          size: 26, color: Color(0xFF0F172A)),
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
                      '${v.brand.toUpperCase()} ${v.name}',
                      style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w900,
                          color: Color(0xFF0F172A)),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '${c.name} • ${c.phone} • Booking: ${r.id}',
                      style: const TextStyle(
                          fontSize: 12, color: AppColors.textMuted),
                    ),
                  ],
                ),
              ),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: statusColor.withAlpha(25),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: statusColor.withAlpha(80)),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      isPaid
                          ? Icons.check_circle_rounded
                          : (isPartial
                              ? Icons.timelapse_rounded
                              : Icons.pending_rounded),
                      size: 13,
                      color: statusColor,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      statusLabel,
                      style: TextStyle(
                        color: statusColor,
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),

          // Row 2: Financial Progress & Balances
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFFF8FAFC),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const Color(0xFFE2E8F0)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    RichText(
                      text: TextSpan(
                        children: [
                          TextSpan(
                            text: '${isKhmer ? "តម្លៃសរុប" : "Total"}: ',
                            style: const TextStyle(
                                color: Color(0xFF64748B), fontSize: 12),
                          ),
                          TextSpan(
                            text: money(total),
                            style: const TextStyle(
                              color: Color(0xFF0F172A),
                              fontWeight: FontWeight.bold,
                              fontSize: 13,
                            ),
                          ),
                        ],
                      ),
                    ),
                    RichText(
                      text: TextSpan(
                        children: [
                          TextSpan(
                            text: '${isKhmer ? "បានបង់" : "Paid"}: ',
                            style: const TextStyle(
                                color: Color(0xFF64748B), fontSize: 12),
                          ),
                          TextSpan(
                            text: money(paid),
                            style: const TextStyle(
                              color: AppColors.brandEmerald,
                              fontWeight: FontWeight.bold,
                              fontSize: 13,
                            ),
                          ),
                        ],
                      ),
                    ),
                    RichText(
                      text: TextSpan(
                        children: [
                          TextSpan(
                            text: '${isKhmer ? "នៅសល់" : "Balance"}: ',
                            style: const TextStyle(
                                color: Color(0xFF64748B), fontSize: 12),
                          ),
                          TextSpan(
                            text: money(balance),
                            style: TextStyle(
                              color: balance > 0
                                  ? AppColors.brandRed
                                  : const Color(0xFF64748B),
                              fontWeight: FontWeight.w900,
                              fontSize: 13,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: LinearProgressIndicator(
                    value: progress,
                    minHeight: 6,
                    backgroundColor: const Color(0xFFE2E8F0),
                    valueColor: AlwaysStoppedAnimation<Color>(
                      isPaid ? AppColors.brandEmerald : AppColors.brandAmber,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),

          // Row 3: Action Buttons (Receipt, Record Payment, Edit, Reset)
          Wrap(
            spacing: 8,
            runSpacing: 8,
            alignment: WrapAlignment.end,
            children: [
              // View Receipt / Invoice
              OutlinedButton.icon(
                style: OutlinedButton.styleFrom(
                  foregroundColor: const Color(0xFF0F172A),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8)),
                ),
                onPressed: () => viewPaymentDetails(r),
                icon: const Icon(Icons.receipt_rounded, size: 15),
                label: Text(
                  isKhmer ? 'វិក្កយបត្រ' : 'Receipt & Invoice',
                  style: const TextStyle(
                      fontSize: 11, fontWeight: FontWeight.bold),
                ),
              ),

              // Record Payment (if balance > 0)
              if (balance > 0)
                FilledButton.icon(
                  style: FilledButton.styleFrom(
                    backgroundColor: AppColors.brandEmerald,
                    padding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8)),
                  ),
                  onPressed: () => recordPaymentDialog(rental: r),
                  icon: const Icon(Icons.add_card_rounded, size: 15),
                  label: Text(
                    isKhmer ? '+ បង់ប្រាក់' : '+ Pay',
                    style: const TextStyle(
                        fontSize: 11, fontWeight: FontWeight.bold),
                  ),
                ),

              // Quick Full Settle (if balance > 0)
              if (balance > 0)
                FilledButton.tonal(
                  style: FilledButton.styleFrom(
                    backgroundColor: AppColors.brandEmerald.withAlpha(25),
                    foregroundColor: AppColors.brandEmerald,
                    padding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8)),
                  ),
                  onPressed: () async {
                    await s.settleRentalPayment(r.id);
                    setState(() {});
                    message(s.t('payment_recorded_success'));
                  },
                  child: Text(
                    isKhmer ? 'ទូទាត់ពេញ' : 'Settle Full',
                    style: const TextStyle(
                        fontSize: 11, fontWeight: FontWeight.bold),
                  ),
                ),

              // Edit Payment
              OutlinedButton.icon(
                style: OutlinedButton.styleFrom(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8)),
                ),
                onPressed: () => recordPaymentDialog(rental: r, isEdit: true),
                icon: const Icon(Icons.edit_outlined, size: 14),
                label: Text(s.t('edit'), style: const TextStyle(fontSize: 11)),
              ),

              // Reset / Refund Payment
              if (paid > 0)
                IconButton(
                  icon: const Icon(Icons.refresh_rounded,
                      color: AppColors.brandRed, size: 18),
                  tooltip: s.t('reset_payment'),
                  onPressed: () async {
                    final confirmed = await showDialog<bool>(
                      context: context,
                      builder: (ctx) => AlertDialog(
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16)),
                        title: Text(s.t('reset_payment')),
                        content: Text(s.t('confirm_reset_payment')),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.pop(ctx, false),
                            child: Text(s.t('cancel')),
                          ),
                          FilledButton(
                            style: FilledButton.styleFrom(
                                backgroundColor: AppColors.brandRed),
                            onPressed: () => Navigator.pop(ctx, true),
                            child:
                                Text(isKhmer ? 'កំណត់ឡើងវិញ' : 'Reset to \$0'),
                          ),
                        ],
                      ),
                    );
                    if (confirmed == true) {
                      await s.resetRentalPayment(r.id);
                      setState(() {});
                      message(isKhmer
                          ? 'បានកំណត់ការទូទាត់ឡើងវិញជា \$0'
                          : 'Payment reset to \$0');
                    }
                  },
                ),
            ],
          ),
        ],
      ),
    );
  }

  Future<void> recordPaymentDialog(
      {Rental? rental, bool isEdit = false}) async {
    await showDialog<void>(
      context: context,
      builder: (_) => PaymentFormDialog(
        store: s,
        preselectedRental: rental,
        isEdit: isEdit,
        onSaved: () => setState(() {}),
      ),
    );
  }

  Future<void> viewPaymentDetails(Rental r) async {
    await showDialog<void>(
      context: context,
      builder: (_) => PaymentDetailsDialog(
        store: s,
        rental: r,
        onUpdated: () => setState(() {}),
      ),
    );
  }

  Future<void> postProductDialog({Vehicle? existing}) async {
    await showDialog<void>(
      context: context,
      builder: (ctx) => PostVehicleDialog(
        store: s,
        existing: existing,
        onMessage: message,
      ),
    );
  }

  Future<void> postBannerDialog({BannerItem? existing}) async {
    final isEdit = existing != null;
    final tagCtrl =
        TextEditingController(text: existing?.tagline ?? 'ONE STEP AHEAD');
    final titleCtrl = TextEditingController(text: existing?.title ?? 'TIGGO 9');
    final subCtrl = TextEditingController(
        text: existing?.subtitle ??
            'Chery Flagship Luxury 7-Seat Intelligent AWD SUV');
    final priceCtrl = TextEditingController(
        text: existing?.priceText ?? '\$55 / DAY • FULL INSURANCE');
    final badgeCtrl =
        TextEditingController(text: existing?.badgeText ?? 'ONE STEP AHEAD');
    final c1Ctrl = TextEditingController(
        text: existing?.specChips.isNotEmpty == true
            ? existing!.specChips[0]
            : '2.0L TGDI TURBO · 261 HP');
    final c2Ctrl = TextEditingController(
        text: existing != null && existing.specChips.length > 1
            ? existing.specChips[1]
            : '8-SPEED AT · INTELLIGENT AWD');
    final c3Ctrl = TextEditingController(
        text: existing != null && existing.specChips.length > 2
            ? existing.specChips[2]
            : 'CDC SUSPENSION');
    final c4Ctrl = TextEditingController(
        text: existing != null && existing.specChips.length > 3
            ? existing.specChips[3]
            : '7-SEAT LUXURY');
    String? selectedVehicleId = existing?.vehicleId ??
        (s.vehicles.isNotEmpty ? s.vehicles.first.id : null);
    String? imageUrl = existing?.imageUrl;
    bool active = existing?.active ?? true;

    await showDialog<void>(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, update) => AlertDialog(
          title: Text(isEdit ? 'Edit Hero Banner' : 'Post New Hero Banner',
              style: const TextStyle(fontWeight: FontWeight.bold)),
          content: SizedBox(
            width: 540,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  ImageUploadPickerField(
                    initialValue: imageUrl,
                    label: 'Hero Banner Background Image',
                    presets: const [
                      (
                        label: 'Chery Tiggo 9 Flagship',
                        url: 'assets/images/tiggo9_banner.png'
                      ),
                      (
                        label: 'Hypercar Speed',
                        url:
                            'https://images.unsplash.com/photo-1617788138017-80ad40651399?w=1200&q=80'
                      ),
                      (
                        label: 'Electric Vision',
                        url:
                            'https://images.unsplash.com/photo-1560958089-b8a1929cea89?w=1200&q=80'
                      ),
                      (
                        label: 'Offroad SUV',
                        url:
                            'https://images.unsplash.com/photo-1533473359331-0135ef1b58bf?w=1200&q=80'
                      ),
                    ],
                    onChanged: (val) => imageUrl = val,
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      Expanded(
                          child: TextField(
                              controller: tagCtrl,
                              decoration: const InputDecoration(
                                  labelText:
                                      'Slanted Tagline (e.g. ONE STEP AHEAD)'))),
                      const SizedBox(width: 10),
                      Expanded(
                          child: TextField(
                              controller: badgeCtrl,
                              decoration: const InputDecoration(
                                  labelText:
                                      'Top Badge Text (e.g. CHERY FLAGSHIP)'))),
                    ],
                  ),
                  const SizedBox(height: 10),
                  TextField(
                      controller: titleCtrl,
                      decoration: const InputDecoration(
                          labelText: 'Giant Model Headline (e.g. TIGGO 9)')),
                  const SizedBox(height: 10),
                  TextField(
                      controller: subCtrl,
                      decoration: const InputDecoration(
                          labelText: 'Subtitle Description')),
                  const SizedBox(height: 10),
                  TextField(
                      controller: priceCtrl,
                      decoration: const InputDecoration(
                          labelText:
                              'Price Tag (e.g. \$55 / DAY • FULL INSURANCE)')),
                  const SizedBox(height: 14),
                  DropdownButtonFormField<String>(
                    initialValue: selectedVehicleId,
                    decoration: const InputDecoration(
                        labelText: 'Link to Inventory Vehicle'),
                    items: s.vehicles
                        .map((v) =>
                            DropdownMenuItem(value: v.id, child: Text(v.name)))
                        .toList(),
                    onChanged: (v) => update(() => selectedVehicleId = v),
                  ),
                  const SizedBox(height: 14),
                  const Text('4 Floating Spec Badges',
                      style:
                          TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Expanded(
                          child: TextField(
                              controller: c1Ctrl,
                              decoration:
                                  const InputDecoration(labelText: 'Chip 1'))),
                      const SizedBox(width: 8),
                      Expanded(
                          child: TextField(
                              controller: c2Ctrl,
                              decoration:
                                  const InputDecoration(labelText: 'Chip 2'))),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Expanded(
                          child: TextField(
                              controller: c3Ctrl,
                              decoration:
                                  const InputDecoration(labelText: 'Chip 3'))),
                      const SizedBox(width: 8),
                      Expanded(
                          child: TextField(
                              controller: c4Ctrl,
                              decoration:
                                  const InputDecoration(labelText: 'Chip 4'))),
                    ],
                  ),
                  const SizedBox(height: 12),
                  SwitchListTile(
                    contentPadding: EdgeInsets.zero,
                    title: const Text('Active on Live Website Storefront',
                        style: TextStyle(fontWeight: FontWeight.bold)),
                    value: active,
                    activeThumbColor: brandEmerald,
                    onChanged: (v) => update(() => active = v),
                  ),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
                onPressed: () => Navigator.pop(ctx),
                child: const Text('Cancel')),
            FilledButton(
              style: FilledButton.styleFrom(backgroundColor: brandEmerald),
              onPressed: () async {
                final b = BannerItem(
                  id: isEdit ? existing.id : s.newId('B'),
                  tagline: tagCtrl.text.trim().isEmpty
                      ? 'ONE STEP AHEAD'
                      : tagCtrl.text.trim(),
                  title: titleCtrl.text.trim().isEmpty
                      ? 'TIGGO 9'
                      : titleCtrl.text.trim(),
                  subtitle: subCtrl.text.trim(),
                  priceText: priceCtrl.text.trim(),
                  vehicleId: selectedVehicleId,
                  imageUrl: imageUrl,
                  badgeText: badgeCtrl.text.trim().isEmpty
                      ? 'ONE STEP AHEAD'
                      : badgeCtrl.text.trim(),
                  badgeColorValue: 0xFF10B981,
                  specChips: [
                    c1Ctrl.text.trim(),
                    c2Ctrl.text.trim(),
                    c3Ctrl.text.trim(),
                    c4Ctrl.text.trim(),
                  ],
                  active: active,
                );

                if (isEdit) {
                  await save(() => s.updateBanner(b));
                  message('Updated banner "${b.title}"!');
                } else {
                  await save(() => s.addBanner(b));
                  message('Posted new banner "${b.title}" to Website!');
                }
                if (ctx.mounted) Navigator.pop(ctx);
              },
              child: Text(isEdit ? 'Save Banner' : 'Publish Banner'),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> addCustomer() async {
    final added = await showDialog<bool>(
      context: context,
      builder: (_) => CustomerFormDialog(store: s),
    );
    if (added == true) {
      setState(() {});
      message(s.t('customer_saved'));
    }
  }

  Future<void> editCustomer(Customer c) async {
    final updated = await showDialog<bool>(
      context: context,
      builder: (_) => CustomerFormDialog(store: s, customer: c),
    );
    if (updated == true) {
      setState(() {});
      message(s.t('customer_saved'));
    }
  }

  Future<void> deleteCustomer(Customer c) async {
    final activeCount = s.customerActiveRentals(c.id);
    if (activeCount > 0) {
      message(s.t('cannot_delete_active_customer'));
      return;
    }

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(s.t('delete_customer')),
        content: Text(s.t('confirm_delete_customer')),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text(s.t('cancel')),
          ),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: brandRed),
            onPressed: () => Navigator.pop(ctx, true),
            child: Text(s.t('delete')),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      await save(() => s.deleteCustomer(c.id));
      message(s.t('customer_deleted'));
    }
  }

  Future<void> viewCustomerDetails(Customer c) async {
    await showDialog(
      context: context,
      builder: (_) => CustomerDetailsDialog(
        store: s,
        customer: c,
        onUpdated: () => setState(() {}),
      ),
    );
  }

  Future<void> recordPayment(Rental r) async {
    final v = await form(
      'Record Payment • Balance: ${money(r.balanceCents)}',
      ['Amount (USD)'],
      validate: (v) {
        final amt = parseMoney(v[0]);
        return (amt == null || amt <= 0 || amt > r.balanceCents)
            ? 'Enter valid amount <= balance.'
            : null;
      },
    );
    if (v != null)
      await save(() => s.commit(() => r.paidCents += parseMoney(v[0])!));
  }

  Future<void> returnRental(Rental r) async {
    final updated = await showDialog<bool>(
      context: context,
      builder: (ctx) => ReturnVehicleDialog(
        store: s,
        rental: r,
        onUpdated: () => setState(() {}),
      ),
    );
    if (updated == true) {
      setState(() {});
    }
  }

  Future<void> addBooking() async {
    final updated = await showDialog<bool>(
      context: context,
      builder: (_) => BookingFormDialog(store: s),
    );
    if (updated == true) {
      setState(() {});
    }
  }

  Future<List<String>?> form(
    String title,
    List<String> labels, {
    String? Function(List<String>)? validate,
  }) async {
    final controllers = labels.map((_) => TextEditingController()).toList();
    String? error;

    final result = await showDialog<List<String>>(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, update) => AlertDialog(
          title:
              Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
          content: SizedBox(
            width: 440,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  for (int i = 0; i < labels.length; i++)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 14),
                      child: TextField(
                        controller: controllers[i],
                        decoration: InputDecoration(labelText: labels[i]),
                      ),
                    ),
                  if (error != null)
                    Text(error!,
                        style: const TextStyle(
                            color: Colors.red, fontWeight: FontWeight.bold)),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
                onPressed: () => Navigator.pop(ctx),
                child: const Text('Cancel')),
            FilledButton(
              style: FilledButton.styleFrom(backgroundColor: brandRed),
              onPressed: () {
                final values = controllers.map((c) => c.text.trim()).toList();
                final problem = values.any((v) => v.isEmpty)
                    ? 'Complete all fields.'
                    : validate?.call(values);
                if (problem != null) {
                  update(() => error = problem);
                } else {
                  Navigator.pop(ctx, values);
                }
              },
              child: const Text('Save'),
            ),
          ],
        ),
      ),
    );

    Future<void>.delayed(const Duration(milliseconds: 400), () {
      for (final c in controllers) {
        c.dispose();
      }
    });

    return result;
  }
}

// ---------------------------------------------------------------------------
// AGENCY BRAND & CATEGORY SETTINGS TAB WITH LOGO UPLOAD
// ---------------------------------------------------------------------------

class _AgencyBrandSettingsTab extends StatefulWidget {
  final RentalStore store;
  final ValueChanged<AgencyConfig> onSave;
  final VoidCallback onAddCategory;
  final ValueChanged<String> onDeleteCategory;

  const _AgencyBrandSettingsTab({
    required this.store,
    required this.onSave,
    required this.onAddCategory,
    required this.onDeleteCategory,
  });

  @override
  State<_AgencyBrandSettingsTab> createState() =>
      _AgencyBrandSettingsTabState();
}

class _AgencyBrandSettingsTabState extends State<_AgencyBrandSettingsTab> {
  late TextEditingController _nameCtrl;
  late TextEditingController _sloganCtrl;
  late TextEditingController _phoneCtrl;
  late TextEditingController _emailCtrl;
  late TextEditingController _addrCtrl;
  String? _logoUrl;

  @override
  void initState() {
    super.initState();
    final cfg = widget.store.agencyConfig;
    _nameCtrl = TextEditingController(text: cfg.companyName);
    _sloganCtrl = TextEditingController(text: cfg.companySlogan);
    _phoneCtrl = TextEditingController(text: cfg.phone);
    _emailCtrl = TextEditingController(text: cfg.email);
    _addrCtrl = TextEditingController(text: cfg.address);
    _logoUrl = cfg.logoUrl;
  }

  @override
  void didUpdateWidget(covariant _AgencyBrandSettingsTab oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.store.agencyConfig != oldWidget.store.agencyConfig) {
      final cfg = widget.store.agencyConfig;
      _nameCtrl.text = cfg.companyName;
      _sloganCtrl.text = cfg.companySlogan;
      _phoneCtrl.text = cfg.phone;
      _emailCtrl.text = cfg.email;
      _addrCtrl.text = cfg.address;
      _logoUrl = cfg.logoUrl;
    }
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _sloganCtrl.dispose();
    _phoneCtrl.dispose();
    _emailCtrl.dispose();
    _addrCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final s = widget.store;
    const Color brandRed = Color(0xFFE50914);
    const Color darkBg = Color(0xFF0B0F19);
    const Color cardBorder = Color(0xFFE5E7EB);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Category Manager Section
        Container(
          padding: const EdgeInsets.all(24),
          margin: const EdgeInsets.only(bottom: 20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: cardBorder),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Dynamic Storefront Categories',
                          style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: darkBg)),
                      Text(
                          'Categories update in real-time on the public website.',
                          style: TextStyle(color: Colors.grey, fontSize: 12)),
                    ],
                  ),
                  FilledButton.icon(
                    style: FilledButton.styleFrom(backgroundColor: darkBg),
                    onPressed: widget.onAddCategory,
                    icon: const Icon(Icons.add, size: 16),
                    label: const Text('New Category'),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Wrap(
                spacing: 10,
                runSpacing: 10,
                children: s.categories
                    .map(
                      (cat) => Chip(
                        label: Text(cat,
                            style:
                                const TextStyle(fontWeight: FontWeight.bold)),
                        backgroundColor: cat == 'All'
                            ? const Color(0xFFF3F4F6)
                            : const Color(0xFFFEE2E2),
                        deleteIcon: cat == 'All'
                            ? null
                            : const Icon(Icons.close, size: 16),
                        onDeleted: cat == 'All'
                            ? null
                            : () => widget.onDeleteCategory(cat),
                      ),
                    )
                    .toList(),
              ),
            ],
          ),
        ),

        // Brand & Agency Identity Customizer
        Container(
          padding: const EdgeInsets.all(24),
          margin: const EdgeInsets.only(bottom: 20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: cardBorder),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Agency Branding & Identity Customizer',
                  style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: darkBg)),
              const Text(
                  'Upload company logo, update brand name, slogan, and contact info across the entire website.',
                  style: TextStyle(color: Colors.grey, fontSize: 12)),
              const SizedBox(height: 20),

              // Logo Uploader & Live Preview
              ImageUploadPickerField(
                initialValue: _logoUrl,
                label:
                    'Agency Logo / Brand Icon (Upload from Device or Paste URL)',
                presets: const [
                  (
                    label: 'Chery Flagship Shield',
                    url: 'assets/images/tiggo9_banner.png'
                  ),
                  (
                    label: 'Luxury Emblem',
                    url:
                        'https://images.unsplash.com/photo-1617814076367-b759c7d7e738?auto=format&fit=crop&w=400&q=80'
                  ),
                  (
                    label: 'Cyber Fleet',
                    url:
                        'https://images.unsplash.com/photo-1503376780353-7e6692767b70?auto=format&fit=crop&w=400&q=80'
                  ),
                ],
                onChanged: (val) {
                  setState(() => _logoUrl = val);
                },
              ),
              const SizedBox(height: 14),

              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _nameCtrl,
                      decoration: const InputDecoration(
                          labelText: 'Company / Brand Name'),
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: TextField(
                      controller: _sloganCtrl,
                      decoration: const InputDecoration(
                          labelText: 'Brand Slogan (e.g. CAR AGENCY)'),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _phoneCtrl,
                      decoration: const InputDecoration(
                          labelText: 'Contact Phone Number'),
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: TextField(
                      controller: _emailCtrl,
                      decoration: const InputDecoration(
                          labelText: 'Contact Email Address'),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),
              TextField(
                controller: _addrCtrl,
                decoration: const InputDecoration(
                    labelText: 'Showroom Location / Address'),
              ),
              const SizedBox(height: 20),
              FilledButton.icon(
                style: FilledButton.styleFrom(
                  backgroundColor: brandRed,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
                ),
                onPressed: () {
                  final config = AgencyConfig(
                    companyName: _nameCtrl.text.trim().isEmpty
                        ? 'DriveLine'
                        : _nameCtrl.text.trim(),
                    companySlogan: _sloganCtrl.text.trim().isEmpty
                        ? 'CAR AGENCY'
                        : _sloganCtrl.text.trim(),
                    phone: _phoneCtrl.text.trim().isEmpty
                        ? '+92 300 1234567'
                        : _phoneCtrl.text.trim(),
                    email: _emailCtrl.text.trim().isEmpty
                        ? 'info@driveline.pk'
                        : _emailCtrl.text.trim(),
                    address: _addrCtrl.text.trim().isEmpty
                        ? 'Lahore, Pakistan'
                        : _addrCtrl.text.trim(),
                    logoUrl: _logoUrl,
                  );
                  widget.onSave(config);
                },
                icon: const Icon(Icons.check, size: 18),
                label: const Text('Save Agency Settings',
                    style: TextStyle(fontWeight: FontWeight.bold)),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
