import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'models.dart';
import 'smart_image.dart';
import 'store.dart';
import 'src/localization/app_language.dart';
import 'src/localization/app_translations.dart';
import 'src/localization/language_selector_widget.dart';
import 'src/screens/cart/rental_cart_screen.dart';
import 'src/screens/storefront/widgets/professional_car_detail_card.dart';
import 'src/screens/storefront/widgets/professional_booking_date_dialog.dart';
import 'src/shared/vehicle_art.dart';
export 'src/shared/vehicle_art.dart';

class Storefront extends StatefulWidget {
  final RentalStore store;
  final WidgetBuilder managementBuilder;

  const Storefront(
      {super.key, required this.store, required this.managementBuilder});

  @override
  State<Storefront> createState() => _StorefrontState();
}

class _StorefrontState extends State<Storefront> {
  final _aboutKey = GlobalKey();
  final _carsKey = GlobalKey();
  final _servicesKey = GlobalKey();
  final _testimonialsKey = GlobalKey();
  final _contactKey = GlobalKey();

  final Set<String> _cart = {};
  final Set<String> _favorites = {};

  int _heroBannerIndex = 0;
  String _selectedCategory = 'All';
  String _selectedStockFilter = 'All'; // 'All', 'Available', 'Unavailable'
  late DateTime _from;
  late DateTime _to;
  Timer? _autoSlideTimer;

  // Contact Form Controllers
  final _contactName = TextEditingController();
  final _contactPhone = TextEditingController();
  final _contactEmail = TextEditingController();
  final _contactMessage = TextEditingController();
  String? _selectedInterestedCar;
  bool _formSubmitting = false;

  RentalStore get s => widget.store;

  // DriveLine Brand Color Tokens
  static const Color brandRed = Color(0xFFE50914);
  static const Color brandEmerald = Color(0xFF10B981);
  static const Color darkBg = Color(0xFF0B0F19);
  static const Color darkCard = Color(0xFF131A2A);
  static const Color textDark = Color(0xFF111827);
  static const Color textMuted = Color(0xFF6B7280);
  static const Color lightBorder = Color(0xFFE5E7EB);
  static const Color sectionLight = Color(0xFFF9FAFB);

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    _from = DateTime(now.year, now.month, now.day);
    _to = _from.add(const Duration(days: 2));
    s.addListener(_refresh);
    if (s.vehicles.isNotEmpty) {
      _selectedInterestedCar = s.vehicles.first.name;
    }
    _startAutoSlideTimer();
  }

  void _startAutoSlideTimer() {
    _autoSlideTimer?.cancel();
    _autoSlideTimer = Timer.periodic(const Duration(seconds: 8), (timer) {
      if (!mounted) return;
      final activeBanners = s.banners.where((b) => b.active).toList();
      if (activeBanners.length > 1) {
        setState(() {
          _heroBannerIndex = (_heroBannerIndex + 1) % activeBanners.length;
        });
      }
    });
  }

  void _toggleFavorite(String vehicleId) {
    setState(() {
      if (_favorites.contains(vehicleId)) {
        _favorites.remove(vehicleId);
      } else {
        _favorites.add(vehicleId);
      }
    });
  }

  void _bookTestDriveFor(Vehicle v) {
    setState(() {
      _selectedInterestedCar = v.name;
    });
    _scrollTo(_contactKey);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: darkBg,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        content: Row(
          children: [
            const Icon(Icons.speed, color: brandEmerald, size: 20),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                'Selected ${v.name} for Rental Reservation. Complete your inquiry below.',
                style: const TextStyle(
                    color: Colors.white, fontWeight: FontWeight.w600),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _autoSlideTimer?.cancel();
    _contactName.dispose();
    _contactPhone.dispose();
    _contactEmail.dispose();
    _contactMessage.dispose();
    s.removeListener(_refresh);
    super.dispose();
  }

  void _refresh() {
    if (mounted) setState(() {});
  }

  void _scrollTo(GlobalKey key) {
    if (key.currentContext != null) {
      Scrollable.ensureVisible(
        key.currentContext!,
        duration: const Duration(milliseconds: 600),
        curve: Curves.easeInOutCubic,
      );
    }
  }

  int get days =>
      DateTime.utc(_to.year, _to.month, _to.day)
          .difference(DateTime.utc(_from.year, _from.month, _from.day))
          .inDays +
      1;

  void _addToCart(Vehicle v) {
    if (!s.available(v, _from, _to)) {
      _showUnavailableDialog(v);
      return;
    }
    setState(() => _cart.add(v.id));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: darkBg,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        content: Row(
          children: [
            const Icon(Icons.check_circle, color: brandRed, size: 20),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                '${v.name} added to reservation cart.',
                style: const TextStyle(
                    color: Colors.white, fontWeight: FontWeight.w600),
              ),
            ),
          ],
        ),
        action: SnackBarAction(
          label: 'View Cart',
          textColor: brandRed,
          onPressed: _openCart,
        ),
      ),
    );
  }

  void _showUnavailableDialog(Vehicle v) {
    final status = s.vehicleStatus(v);
    final String reason = status == 'Maintenance'
        ? (s.language == AppLanguage.khmer
            ? 'កំពុងស្ថិតក្នុងការជួសជុលថែទាំ'
            : 'Currently undergoing maintenance / service')
        : (s.language == AppLanguage.khmer
            ? 'ត្រូវបានកក់ទុករួចហើយសម្រាប់កាលបរិច្ឆេទនេះ'
            : 'Currently booked by another customer for this period');

    showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        titlePadding: const EdgeInsets.fromLTRB(24, 24, 24, 8),
        contentPadding: const EdgeInsets.fromLTRB(24, 12, 24, 24),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: const BoxDecoration(
                color: Color(0xFFFEE2E2),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.car_repair_rounded, color: brandRed, size: 24),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                s.t('car_unavailable_dialog_title'),
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w900,
                  color: textDark,
                ),
              ),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFFF9FAFB),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: lightBorder),
              ),
              child: Row(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: SizedBox(
                      width: 60,
                      height: 42,
                      child: SmartImage(
                        imageSource: v.imageUrl,
                        fit: BoxFit.cover,
                        fallback: VehicleArt(type: v.type, color: darkBg),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          v.name,
                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                        ),
                        Text(
                          reason,
                          style: const TextStyle(color: brandRed, fontSize: 12, fontWeight: FontWeight.w600),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 14),
            Text(
              s.t('car_unavailable_dialog_desc'),
              style: const TextStyle(color: textMuted, fontSize: 13, height: 1.4),
            ),
            const SizedBox(height: 10),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: const Color(0xFFF3F4F6),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.date_range, size: 14, color: textMuted),
                  const SizedBox(width: 6),
                  Text(
                    '${dateLabel(_from)} - ${dateLabel(_to)}',
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: textDark),
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(s.t('cancel'), style: const TextStyle(color: textMuted)),
          ),
          OutlinedButton(
            onPressed: () {
              Navigator.pop(ctx);
              setState(() => _selectedStockFilter = 'Available');
            },
            child: Text(s.t('explore_available_fleet')),
          ),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: brandRed),
            onPressed: () {
              Navigator.pop(ctx);
              _pickDates();
            },
            child: Text(s.t('adjust_rental_dates')),
          ),
        ],
      ),
    );
  }

  Future<void> _pickDates() async {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final selected = await showProfessionalBookingDatePicker(
      context: context,
      initialStart: _from.isBefore(today) ? today : _from,
      initialEnd: _to.isBefore(today) ? today.add(const Duration(days: 2)) : _to,
      firstDate: today,
      language: s.language,
    );
    if (selected != null && mounted) {
      setState(() {
        _from = selected.start;
        _to = selected.end;
      });
    }
  }

  Future<void> _submitContactForm() async {
    final name = _contactName.text.trim();
    final phone = _contactPhone.text.trim();
    final email = _contactEmail.text.trim();
    final message = _contactMessage.text.trim();

    if (name.isEmpty || phone.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            s.language == AppLanguage.khmer
                ? 'សូមបញ្ចូលឈ្មោះ និងលេខទូរស័ព្ទរបស់អ្នក ដើម្បីកក់ការជួលរថយន្ត។'
                : 'Please enter your Name and Phone Number to reserve your rental vehicle.',
          ),
          backgroundColor: Colors.redAccent,
        ),
      );
      return;
    }

    setState(() => _formSubmitting = true);

    if (s.backendConnected) {
      await s.api.submitInquiry(
        name: name,
        phone: phone,
        email: email.isNotEmpty ? email : null,
        message: message.isNotEmpty ? message : null,
      );
    } else {
      await Future.delayed(const Duration(milliseconds: 500));
    }

    if (mounted) {
      setState(() {
        _formSubmitting = false;
        _contactName.clear();
        _contactPhone.clear();
        _contactEmail.clear();
        _contactMessage.clear();
      });
      showDialog(
        context: context,
        builder: (ctx) => AlertDialog(
          backgroundColor: darkBg,
          title: Text(s.t('test_drive_sent'),
              style: const TextStyle(
                  color: Colors.white, fontWeight: FontWeight.bold)),
          content: Text(
            s.t('thank_you_contact'),
            style: const TextStyle(color: Colors.white70),
          ),
          actions: [
            FilledButton(
              style: FilledButton.styleFrom(backgroundColor: brandRed),
              onPressed: () => Navigator.pop(ctx),
              child: Text(s.language == AppLanguage.khmer ? 'រួចរាល់' : 'Done'),
            ),
          ],
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    final isMobile = width < 1000;
    final isTablet = width >= 1000 && width < 1250;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: _buildNavBar(isMobile, width),
      drawer: isMobile ? _buildMobileDrawer() : null,
      body: SingleChildScrollView(
        child: Column(
          children: [
            _buildHeroSection(isMobile, isTablet),
            _buildTrustBar(isMobile),
            _buildFeaturedCarsSection(isMobile, isTablet),
            _buildAboutUsSection(isMobile),
            _buildServicesSection(isMobile),
            _buildTestimonialsSection(isMobile),
            _buildContactSection(isMobile),
            _buildFooter(isMobile),
          ],
        ),
      ),
    );
  }

  // -------------------------------------------------------------------------
  // 1. NAVIGATION BAR
  // -------------------------------------------------------------------------

  PreferredSizeWidget _buildNavBar(bool isMobile, [double screenWidth = 1200]) {
    return AppBar(
      elevation: 0,
      backgroundColor: darkBg,
      surfaceTintColor: Colors.transparent,
      centerTitle: false,
      title: FittedBox(
        fit: BoxFit.scaleDown,
        alignment: Alignment.centerLeft,
        child: _buildLogo(),
      ),
      actions: [
        if (!isMobile) ...[
          _navItem(s.t('home'), isSelected: true, onTap: () {}),
          _navItem(s.t('about'),
              isSelected: false, onTap: () => _scrollTo(_aboutKey)),
          _navItem(s.t('fleet'), isSelected: false, onTap: () => _scrollTo(_carsKey)),
          _navItem(s.t('services'),
              isSelected: false, onTap: () => _scrollTo(_servicesKey)),
          _navItem(s.t('testimonials'),
              isSelected: false, onTap: () => _scrollTo(_testimonialsKey)),
          _navItem(s.t('contact'),
              isSelected: false, onTap: () => _scrollTo(_contactKey)),
          const SizedBox(width: 4),
          IconButton(
            icon: const Icon(Icons.search, color: Colors.white70, size: 20),
            tooltip: s.t('search_inventory'),
            onPressed: () => _scrollTo(_carsKey),
          ),
          const SizedBox(width: 4),
        ],
        // Language Selector (Khmer / English)
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 10),
          child: LanguageSelectorWidget(
            currentLanguage: s.language,
            onLanguageChanged: (lang) => setState(() => s.setLanguage(lang)),
          ),
        ),
        // Admin Workspace Shortcut
        IconButton(
          icon: const Icon(Icons.dashboard_outlined,
              color: Colors.white70, size: 20),
          tooltip: s.t('admin_workspace'),
          onPressed: () => Navigator.push(
            context,
            MaterialPageRoute(builder: widget.managementBuilder),
          ),
        ),
        // Backend Sync Status Indicator
        IconButton(
          icon: Stack(
            clipBehavior: Clip.none,
            children: [
              Icon(
                s.backendConnected ? Icons.cloud_done_outlined : Icons.cloud_outlined,
                color: s.backendConnected ? const Color(0xFF10B981) : Colors.white70,
                size: 20,
              ),
              Positioned(
                right: -2,
                top: -2,
                child: Container(
                  width: 7,
                  height: 7,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: s.backendConnected ? const Color(0xFF10B981) : Colors.amber,
                  ),
                ),
              ),
            ],
          ),
          tooltip: s.backendConnected
              ? (s.language == AppLanguage.khmer
                  ? 'បានតភ្ជាប់ទៅ Spring Boot Backend (:8080)'
                  : 'Connected to VRMS Spring Boot Backend (:8080)')
              : (s.language == AppLanguage.khmer
                  ? 'ដំណើរការក្នុងទម្រង់ Local Storage (ចុចដើម្បីសាកល្បងតភ្ជាប់)'
                  : 'Local Storage Mode (Click to sync)'),
          onPressed: () async {
            final ok = await s.syncWithBackend();
            if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    ok
                        ? (s.language == AppLanguage.khmer
                            ? 'បានតភ្ជាប់ទៅ Spring Boot Backend (Port 8080) ដោយជោគជ័យ'
                            : 'Connected to Spring Boot Backend (Port 8080)')
                        : (s.language == AppLanguage.khmer
                            ? 'មិនអាចតភ្ជាប់ទៅ Backend បានទេ - កំពុងដំណើរការក្នុងទម្រង់ Local Storage'
                            : 'Backend offline - Running in Local Storage Mode'),
                  ),
                  backgroundColor: ok ? const Color(0xFF10B981) : Colors.amber.shade800,
                  duration: const Duration(seconds: 2),
                ),
              );
            }
          },
        ),
        // Cart icon button
        Stack(
          children: [
            IconButton(
              icon: const Icon(Icons.shopping_bag_outlined,
                  color: Colors.white, size: 20),
              tooltip: s.t('cart'),
              onPressed: _openCart,
            ),
            if (_cart.isNotEmpty)
              Positioned(
                top: 6,
                right: 6,
                child: Container(
                  padding: const EdgeInsets.all(4),
                  decoration: const BoxDecoration(
                      color: brandRed, shape: BoxShape.circle),
                  child: Text(
                    '${_cart.length}',
                    style: const TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                        fontWeight: FontWeight.bold),
                  ),
                ),
              ),
          ],
        ),
        if (screenWidth >= 1340) ...[
          const SizedBox(width: 6),
          // Red CTA pill button "Book a Test Drive"
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 10),
            child: FilledButton(
              style: FilledButton.styleFrom(
                backgroundColor: brandRed,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 14),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20)),
              ),
              onPressed: () => _scrollTo(_contactKey),
              child: Text(
                s.t('book_test_drive'),
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
              ),
            ),
          ),
        ],
        const SizedBox(width: 12),
      ],
    );
  }

  Widget _buildLogo({bool large = false}) {
    final companyName = s.agencyConfig.companyName;
    final companySlogan = s.agencyConfig.companySlogan;
    final logoUrl = s.agencyConfig.logoUrl;

    if (logoUrl != null && logoUrl.trim().isNotEmpty) {
      return Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            height: large ? 42 : 34,
            width: large ? 42 : 34,
            margin: const EdgeInsets.only(right: 10),
            decoration: BoxDecoration(
              color: Colors.white.withAlpha(15),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: brandRed.withAlpha(140), width: 1.5),
            ),
            child: SmartImage(
              imageSource: logoUrl,
              fit: BoxFit.cover,
              borderRadius: BorderRadius.circular(7),
              fallback:
                  const Icon(Icons.directions_car, color: brandRed, size: 20),
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                companyName,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: large ? 20 : 17,
                  fontWeight: FontWeight.w900,
                  letterSpacing: -0.5,
                ),
              ),
              Container(
                width: large ? 60 : 45,
                height: 2,
                color: brandRed,
              ),
              Text(
                companySlogan.toUpperCase(),
                style: TextStyle(
                  color: Colors.white54,
                  fontSize: large ? 8 : 6.5,
                  letterSpacing: 1.4,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ],
      );
    }

    String part1 = companyName;
    String part2 = '';
    if (companyName.contains(' ')) {
      final idx = companyName.indexOf(' ');
      part1 = companyName.substring(0, idx);
      part2 = companyName.substring(idx + 1);
    } else if (companyName.length > 5 && companyName.startsWith('Drive')) {
      part1 = 'Drive';
      part2 = companyName.substring(5);
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              part1,
              style: TextStyle(
                color: Colors.white,
                fontSize: large ? 24 : 20,
                fontWeight: FontWeight.w900,
                letterSpacing: -0.5,
              ),
            ),
            if (part2.isNotEmpty)
              Text(
                part2,
                style: TextStyle(
                  color: brandRed,
                  fontSize: large ? 24 : 20,
                  fontWeight: FontWeight.w900,
                  letterSpacing: -0.5,
                ),
              ),
          ],
        ),
        Container(
          width: large ? 75 : 55,
          height: 2,
          color: brandRed,
        ),
        Text(
          companySlogan.toUpperCase(),
          style: TextStyle(
            color: Colors.white54,
            fontSize: large ? 8 : 6.5,
            letterSpacing: 1.6,
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    );
  }

  Widget _navItem(String title,
      {required bool isSelected, required VoidCallback onTap}) {
    return TextButton(
      style: TextButton.styleFrom(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        minimumSize: Size.zero,
        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
      ),
      onPressed: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            title,
            style: TextStyle(
              color: isSelected ? brandRed : Colors.white70,
              fontSize: 13,
              fontWeight: isSelected ? FontWeight.w800 : FontWeight.w500,
            ),
          ),
          if (isSelected)
            Container(
              margin: const EdgeInsets.only(top: 2),
              height: 2,
              width: 16,
              color: brandRed,
            ),
        ],
      ),
    );
  }

  Widget _buildMobileDrawer() {
    return Drawer(
      backgroundColor: darkBg,
      child: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            _buildLogo(),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.white.withAlpha(12),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    s.language == AppLanguage.khmer ? 'ភាសា / Language' : 'Language / ភាសា',
                    style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 12,
                        fontWeight: FontWeight.bold),
                  ),
                  LanguageSelectorWidget(
                    currentLanguage: s.language,
                    onLanguageChanged: (lang) =>
                        setState(() => s.setLanguage(lang)),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            const Divider(color: Colors.white12),
            ListTile(
              title: Text(s.t('home'),
                  style:
                      const TextStyle(color: brandRed, fontWeight: FontWeight.bold)),
              onTap: () => Navigator.pop(context),
            ),
            ListTile(
              title: Text(s.t('about'), style: const TextStyle(color: Colors.white)),
              onTap: () {
                Navigator.pop(context);
                _scrollTo(_aboutKey);
              },
            ),
            ListTile(
              title: Text(s.t('fleet'), style: const TextStyle(color: Colors.white)),
              onTap: () {
                Navigator.pop(context);
                _scrollTo(_carsKey);
              },
            ),
            ListTile(
              title:
                  Text(s.t('services'), style: const TextStyle(color: Colors.white)),
              onTap: () {
                Navigator.pop(context);
                _scrollTo(_servicesKey);
              },
            ),
            ListTile(
              title: Text(s.t('testimonials'),
                  style: const TextStyle(color: Colors.white)),
              onTap: () {
                Navigator.pop(context);
                _scrollTo(_testimonialsKey);
              },
            ),
            ListTile(
              title:
                  Text(s.t('contact'), style: const TextStyle(color: Colors.white)),
              onTap: () {
                Navigator.pop(context);
                _scrollTo(_contactKey);
              },
            ),
            const Divider(color: Colors.white12),
            ListTile(
              leading:
                  const Icon(Icons.dashboard_customize, color: Colors.white70),
              title: Text(s.t('admin_management'),
                  style: const TextStyle(color: Colors.white)),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(context,
                    MaterialPageRoute(builder: widget.managementBuilder));
              },
            ),
          ],
        ),
      ),
    );
  }

  // -------------------------------------------------------------------------
  // 2. HERO SECTION (DYNAMIC ADMIN BANNERS & AUTO-SLIDING ENGINE)
  // -------------------------------------------------------------------------

  Widget _buildHeroSection(bool isMobile, bool isTablet) {
    final activeBanners = s.banners.where((b) => b.active).toList();
    final banners =
        activeBanners.isNotEmpty ? activeBanners : RentalStore.defaultBanners;
    final safeIndex = _heroBannerIndex >= banners.length ? 0 : _heroBannerIndex;
    final currentBanner = banners[safeIndex];

    final tiggo = s.vehicles.firstWhere(
      (v) => v.id == 'v_tiggo9' || v.name.contains('Tiggo'),
      orElse: () => RentalStore.tiggo9Vehicle,
    );

    return Container(
      width: double.infinity,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Color(0xFF070B14),
            Color(0xFF0F172A),
            Color(0xFF131D31),
            Color(0xFF0B0F19),
          ],
        ),
      ),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1320),
          child: Padding(
            padding: EdgeInsets.fromLTRB(
              isMobile ? 12 : 32,
              isMobile ? 16 : 24,
              isMobile ? 12 : 32,
              isMobile ? 24 : 40,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _buildHeroBannerSwitcher(isMobile, banners, safeIndex),
                const SizedBox(height: 16),
                AnimatedSwitcher(
                  duration: const Duration(milliseconds: 400),
                  switchInCurve: Curves.easeOutCubic,
                  switchOutCurve: Curves.easeInCubic,
                  child: currentBanner.id == 'b_tiggo9' ||
                          currentBanner.title.contains('TIGGO 9')
                      ? _buildTiggo9HeroBanner(isMobile, isTablet, tiggo)
                      : (currentBanner.id == 'b_supercars' ||
                              currentBanner.title.contains('DRIVELINE')
                          ? _buildClassicHeroBody(isMobile, isTablet)
                          : _buildCustomHeroBanner(
                              isMobile, isTablet, currentBanner)),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeroBannerSwitcher(
      bool isMobile, List<BannerItem> banners, int activeIndex) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                for (int i = 0; i < banners.length; i++) ...[
                  if (i > 0) const SizedBox(width: 8),
                  _bannerTabButton(
                    index: i,
                    selectedIndex: activeIndex,
                    icon: i == 0
                        ? Icons.star_rounded
                        : (i == 1
                            ? Icons.speed_rounded
                            : (i == 2
                                ? Icons.electric_bolt_rounded
                                : Icons.auto_awesome_rounded)),
                    title: banners[i].title,
                    subtitle: banners[i].badgeText,
                    badgeColor: Color(banners[i].badgeColorValue),
                  ),
                ],
              ],
            ),
          ),
        ),
        if (!isMobile) ...[
          const SizedBox(width: 16),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
            decoration: BoxDecoration(
              color: Colors.white.withAlpha(12),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: Colors.white12),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 8,
                  height: 8,
                  decoration: const BoxDecoration(
                    color: Color(0xFF10B981),
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  '${banners.length} ACTIVE BANNERS • AUTO ROTATING',
                  style: const TextStyle(
                    color: Colors.white70,
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 1.2,
                  ),
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }

  Widget _bannerTabButton({
    required int index,
    required int selectedIndex,
    required IconData icon,
    required String title,
    required String subtitle,
    required Color badgeColor,
  }) {
    final isSelected = selectedIndex == index;
    return InkWell(
      onTap: () {
        setState(() => _heroBannerIndex = index);
        _startAutoSlideTimer();
      },
      borderRadius: BorderRadius.circular(14),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? darkCard : Colors.transparent,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: isSelected ? badgeColor.withAlpha(200) : Colors.white10,
            width: isSelected ? 1.5 : 1,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: badgeColor.withAlpha(35),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ]
              : [],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon,
                size: 16, color: isSelected ? badgeColor : Colors.white60),
            const SizedBox(width: 8),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    color: isSelected ? Colors.white : Colors.white70,
                    fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
                    fontSize: 12,
                    letterSpacing: 0.5,
                  ),
                ),
                Text(
                  subtitle,
                  style: TextStyle(
                    color: isSelected ? badgeColor : Colors.white38,
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCustomHeroBanner(
      bool isMobile, bool isTablet, BannerItem banner) {
    final double bannerHeight = isMobile ? 480 : (isTablet ? 520 : 600);
    final Vehicle? linkedVehicle = banner.vehicleId != null
        ? s.vehicles.cast<Vehicle?>().firstWhere(
              (v) => v?.id == banner.vehicleId,
              orElse: () => null,
            )
        : null;

    final Color badgeColor = Color(banner.badgeColorValue);

    return Container(
      key: ValueKey('CustomBanner_${banner.id}'),
      width: double.infinity,
      height: bannerHeight,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: badgeColor.withAlpha(90),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: badgeColor.withAlpha(50),
            blurRadius: 32,
            spreadRadius: 2,
            offset: const Offset(0, 10),
          ),
          BoxShadow(
            color: Colors.black.withAlpha(190),
            blurRadius: 24,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: Stack(
          children: [
            // Background Image or Futuristic Gradient
            Positioned.fill(
              child: SmartImage(
                imageSource: banner.imageUrl,
                fit: BoxFit.cover,
                fallback: _buildFallbackBannerBg(badgeColor),
              ),
            ),

            // Dark gradient overlay for readability
            Positioned.fill(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    stops: const [0.0, 0.35, 0.7, 1.0],
                    colors: [
                      Colors.black.withAlpha(120),
                      Colors.transparent,
                      Colors.black.withAlpha(150),
                      Colors.black.withAlpha(240),
                    ],
                  ),
                ),
              ),
            ),

            // Top Badge
            Positioned(
              top: isMobile ? 16 : 24,
              left: isMobile ? 16 : 28,
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.black.withAlpha(180),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: badgeColor, width: 1.2),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.star, color: badgeColor, size: 14),
                    const SizedBox(width: 6),
                    Text(
                      banner.badgeText.toUpperCase(),
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: isMobile ? 10 : 12,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 1.2,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Floating Spec Chips (if any)
            if (!isMobile && banner.specChips.isNotEmpty)
              Positioned(
                top: 24,
                right: 28,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    for (final chip in banner.specChips)
                      Container(
                        margin: const EdgeInsets.only(bottom: 8),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: Colors.black.withAlpha(160),
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: badgeColor.withAlpha(140)),
                        ),
                        child: Text(
                          chip,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                  ],
                ),
              ),

            // Banner Title / Subtitle in center / upper body
            Positioned(
              top: isMobile ? 70 : 90,
              left: isMobile ? 16 : 28,
              right: isMobile ? 16 : 28,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    banner.tagline.toUpperCase(),
                    style: TextStyle(
                      color: badgeColor,
                      fontSize: isMobile ? 12 : 14,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 2,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    banner.title,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: isMobile ? 26 : 42,
                      fontWeight: FontWeight.w900,
                      letterSpacing: -0.5,
                      shadows: [
                        Shadow(
                            color: Colors.black.withAlpha(180),
                            blurRadius: 14,
                            offset: const Offset(0, 4)),
                      ],
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    banner.subtitle,
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: isMobile ? 12 : 15,
                      fontWeight: FontWeight.w500,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),

            // Bottom HUD with Actions
            Positioned(
              left: isMobile ? 12 : 24,
              right: isMobile ? 12 : 24,
              bottom: isMobile ? 12 : 24,
              child: Container(
                padding: EdgeInsets.symmetric(
                  horizontal: isMobile ? 14 : 22,
                  vertical: isMobile ? 12 : 16,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xFF0F172A).withAlpha(235),
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(color: Colors.white24, width: 1.2),
                  boxShadow: [
                    BoxShadow(
                        color: Colors.black.withAlpha(160),
                        blurRadius: 20,
                        offset: const Offset(0, 8)),
                  ],
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            banner.title,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                          Text(
                            banner.priceText.isNotEmpty
                                ? banner.priceText
                                : 'Exclusive Special Offer',
                            style: TextStyle(
                              color: badgeColor,
                              fontWeight: FontWeight.w900,
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 12),
                    if (linkedVehicle != null) ...[
                      OutlinedButton.icon(
                        style: OutlinedButton.styleFrom(
                          foregroundColor: Colors.white,
                          side: BorderSide(color: badgeColor),
                          padding: EdgeInsets.symmetric(
                              horizontal: isMobile ? 10 : 16, vertical: 12),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12)),
                        ),
                        onPressed: () => _openCyberCarDetails(linkedVehicle),
                        icon:
                            Icon(Icons.view_in_ar, size: 16, color: badgeColor),
                        label: Text(isMobile ? '3D' : s.t('cyber_specs'),
                            style: const TextStyle(
                                fontWeight: FontWeight.bold, fontSize: 12)),
                      ),
                      const SizedBox(width: 8),
                      FilledButton.icon(
                        style: FilledButton.styleFrom(
                          backgroundColor: badgeColor,
                          foregroundColor: Colors.white,
                          padding: EdgeInsets.symmetric(
                              horizontal: isMobile ? 12 : 18, vertical: 12),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12)),
                        ),
                        onPressed: () => _bookTestDriveFor(linkedVehicle),
                        icon: const Icon(Icons.speed, size: 16),
                        label: Text(isMobile ? 'Drive' : s.t('book_drive'),
                            style: const TextStyle(
                                fontWeight: FontWeight.bold, fontSize: 12)),
                      ),
                      const SizedBox(width: 8),
                      FilledButton.icon(
                        style: FilledButton.styleFrom(
                          backgroundColor: _cart.contains(linkedVehicle.id)
                              ? brandEmerald
                              : brandRed,
                          foregroundColor: Colors.white,
                          padding: EdgeInsets.symmetric(
                              horizontal: isMobile ? 12 : 18, vertical: 12),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12)),
                        ),
                        onPressed: () => _addToCart(linkedVehicle),
                        icon: Icon(
                          _cart.contains(linkedVehicle.id)
                              ? Icons.check_circle_rounded
                              : Icons.shopping_bag_outlined,
                          size: 16,
                        ),
                        label: Text(
                          _cart.contains(linkedVehicle.id)
                              ? (isMobile ? s.t('in_cart') : '✓ ${s.t('in_cart')}')
                              : (isMobile ? s.t('reserve_now') : s.t('reserve_online')),
                          style: const TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 12),
                        ),
                      ),
                    ] else ...[
                      FilledButton.icon(
                        style: FilledButton.styleFrom(
                          backgroundColor: badgeColor,
                          foregroundColor: Colors.white,
                          padding: EdgeInsets.symmetric(
                              horizontal: isMobile ? 12 : 20, vertical: 14),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12)),
                        ),
                        onPressed: () => _scrollTo(_carsKey),
                        icon: const Icon(Icons.explore, size: 16),
                        label: Text(s.t('explore_cars'),
                            style: const TextStyle(
                                fontWeight: FontWeight.bold, fontSize: 13)),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFallbackBannerBg(Color accent) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            const Color(0xFF0F172A),
            accent.withAlpha(50),
            const Color(0xFF1E293B),
            Colors.black,
          ],
        ),
      ),
      child: Center(
        child: Icon(Icons.directions_car,
            size: 180, color: Colors.white.withAlpha(15)),
      ),
    );
  }

  Widget _buildTiggo9HeroBanner(bool isMobile, bool isTablet, Vehicle tiggo) {
    final double bannerHeight = isMobile ? 480 : (isTablet ? 520 : 600);

    return Container(
      key: const ValueKey('Tiggo9Banner'),
      width: double.infinity,
      height: bannerHeight,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: const Color(0xFF10B981).withAlpha(70),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF047857).withAlpha(45),
            blurRadius: 32,
            spreadRadius: 2,
            offset: const Offset(0, 10),
          ),
          BoxShadow(
            color: Colors.black.withAlpha(190),
            blurRadius: 24,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: Stack(
          children: [
            // 1. High-Res Official Photo Banner with Canvas Fallback
            Positioned.fill(
              child: Image.asset(
                'assets/images/tiggo9_banner.png',
                fit: BoxFit.cover,
                alignment: Alignment.center,
                errorBuilder: (context, error, stackTrace) {
                  return Tiggo9BannerCanvas(isMobile: isMobile);
                },
              ),
            ),

            // 2. High-Contrast Overlay Gradient for Perfect Readability
            Positioned.fill(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    stops: const [0.0, 0.25, 0.65, 1.0],
                    colors: [
                      Colors.black.withAlpha(90),
                      Colors.transparent,
                      Colors.black.withAlpha(120),
                      Colors.black.withAlpha(235),
                    ],
                  ),
                ),
              ),
            ),

            // Subtle Dawn Sun Flare on Top-Right
            Positioned(
              top: 0,
              right: 0,
              width: 320,
              height: 240,
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: RadialGradient(
                    center: Alignment.topRight,
                    radius: 1.2,
                    colors: [
                      const Color(0xFFFDE68A).withAlpha(70),
                      const Color(0xFFF97316).withAlpha(20),
                      Colors.transparent,
                    ],
                  ),
                ),
              ),
            ),

            // 3. Top-Left "ONE STEP AHEAD" Badge
            Positioned(
              top: isMobile ? 16 : 24,
              left: isMobile ? 16 : 28,
              child: _buildBannerTopBadge(isMobile),
            ),

            // 4. Floating Spec Chips on Desktop / Tablet
            if (!isMobile)
              Positioned(
                top: 24,
                right: 28,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    _buildTiggo9SpecChip(
                      icon: Icons.flash_on_rounded,
                      title: s.language == AppLanguage.khmer ? 'ម៉ាស៊ីន 2.0L TURBO' : '2.0L TGDI TURBO',
                      val: s.language == AppLanguage.khmer ? 'កម្លាំង 261 HP · 400 NM' : '261 HP · 400 NM',
                      color: const Color(0xFF10B981),
                    ),
                    const SizedBox(height: 8),
                    _buildTiggo9SpecChip(
                      icon: Icons.all_inclusive_rounded,
                      title: s.language == AppLanguage.khmer ? 'ប្រអប់លេខ 8-AT' : '8-SPEED AT',
                      val: s.language == AppLanguage.khmer ? 'ប្រព័ន្ធប៉ុងពីរ AWD' : 'INTELLIGENT AWD',
                      color: const Color(0xFF06B6D4),
                    ),
                    const SizedBox(height: 8),
                    _buildTiggo9SpecChip(
                      icon: Icons.tune_rounded,
                      title: s.language == AppLanguage.khmer ? 'បូមម៉ាញ៉េទិច CDC' : 'CDC SUSPENSION',
                      val: s.language == AppLanguage.khmer ? 'អេឡិចត្រូម៉ាញ៉េទិច' : 'ELECTROMAGNETIC',
                      color: const Color(0xFFF59E0B),
                    ),
                    const SizedBox(height: 8),
                    _buildTiggo9SpecChip(
                      icon: Icons.airline_seat_recline_extra_rounded,
                      title: s.language == AppLanguage.khmer ? 'ប្រណីត ៧ កៅអី' : '7-SEAT LUXURY',
                      val: s.language == AppLanguage.khmer ? 'កៅអីម៉ាស្សាឆ្លាតវៃ' : 'MASSAGE COCKPIT',
                      color: const Color(0xFFA855F7),
                    ),
                  ],
                ),
              ),

            // 5. Bottom Interactive Control & Booking Glass HUD
            Positioned(
              left: isMobile ? 12 : 24,
              right: isMobile ? 12 : 24,
              bottom: isMobile ? 12 : 20,
              child: _buildBannerBottomHUD(isMobile, isTablet, tiggo),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBannerTopBadge(bool isMobile) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          padding: EdgeInsets.symmetric(
            horizontal: isMobile ? 12 : 16,
            vertical: isMobile ? 6 : 8,
          ),
          decoration: BoxDecoration(
            color: const Color(0xFF047857).withAlpha(190),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
                color: const Color(0xFF34D399).withAlpha(180), width: 1.2),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF10B981).withAlpha(70),
                blurRadius: 16,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 8,
                height: 8,
                decoration: const BoxDecoration(
                  color: Color(0xFF34D399),
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 8),
              Text(
                s.language == AppLanguage.khmer ? 'ឈានមុខមួយជំហាន' : 'ONE STEP AHEAD',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: isMobile ? 11 : 13,
                  fontWeight: FontWeight.w900,
                  fontStyle: FontStyle.italic,
                  letterSpacing: 2.2,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 6),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
          decoration: BoxDecoration(
            color: Colors.black.withAlpha(130),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.white24),
          ),
          child: Text(
            s.language == AppLanguage.khmer
                ? 'រថយន្ត SUV ប្រណីតកម្រិតកំពូល AWD'
                : 'CHERY FLAGSHIP LUXURY AWD SUV',
            style: const TextStyle(
              color: Colors.white70,
              fontSize: 10,
              fontWeight: FontWeight.w700,
              letterSpacing: 1.5,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTiggo9SpecChip({
    required IconData icon,
    required String title,
    required String val,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: const Color(0xFF0F172A).withAlpha(200),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withAlpha(120)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(100),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: color),
          const SizedBox(width: 8),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                title,
                style: TextStyle(
                  color: color,
                  fontSize: 9,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 0.8,
                ),
              ),
              Text(
                val,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildBannerBottomHUD(bool isMobile, bool isTablet, Vehicle tiggo) {
    final bool available = s.available(tiggo, _from, _to);

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: isMobile ? 14 : 22,
        vertical: isMobile ? 12 : 16,
      ),
      decoration: BoxDecoration(
        color: const Color(0xFF0F172A).withAlpha(225),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Colors.white24, width: 1.2),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(160),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: isMobile
          ? Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'CHERY TIGGO 9',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.w900,
                            letterSpacing: -0.2,
                          ),
                        ),
                        Text(
                          s.language == AppLanguage.khmer
                              ? 'រថយន្ត SUV ៧កៅអីឆ្លាតវៃ AWD'
                              : '2025 Flagship 7-Seat AWD SUV',
                          style: TextStyle(
                              color: Colors.white.withAlpha(180), fontSize: 11),
                        ),
                      ],
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: const Color(0xFF10B981).withAlpha(40),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                            color: const Color(0xFF10B981).withAlpha(120)),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            '\$55 / ${s.t('day').toUpperCase()}',
                            style: const TextStyle(
                              color: Color(0xFF34D399),
                              fontWeight: FontWeight.w900,
                              fontSize: 14,
                            ),
                          ),
                          Text(
                            s.language == AppLanguage.khmer ? 'ធានារ៉ាប់រងពេញលេញ • កក់ \$150' : 'Full Insurance • \$150 Deposit',
                            style:
                                const TextStyle(color: Colors.white70, fontSize: 9, fontWeight: FontWeight.w600),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    FilledButton.icon(
                      style: FilledButton.styleFrom(
                        backgroundColor: const Color(0xFF059669),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 12),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12)),
                      ),
                      onPressed: () => _bookTestDriveFor(tiggo),
                      icon: const Icon(Icons.speed, size: 16),
                      label: Text(s.t('book_drive'),
                          style: const TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 12)),
                    ),
                    OutlinedButton.icon(
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.white,
                        side: const BorderSide(color: Color(0xFF34D399)),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 12),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12)),
                      ),
                      onPressed: () => _openCyberCarDetails(tiggo),
                      icon: const Icon(Icons.view_in_ar_rounded,
                          size: 16, color: Color(0xFF34D399)),
                      label: Text(s.t('cyber_specs'),
                          style: const TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 12)),
                    ),
                    FilledButton.icon(
                      style: FilledButton.styleFrom(
                        backgroundColor: _cart.contains(tiggo.id)
                            ? brandEmerald
                            : (available ? brandRed : Colors.grey),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(
                            horizontal: 14, vertical: 12),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12)),
                      ),
                      onPressed: available ? () => _addToCart(tiggo) : null,
                      icon: Icon(
                        _cart.contains(tiggo.id)
                            ? Icons.check_circle_rounded
                            : Icons.shopping_bag_outlined,
                        size: 15,
                      ),
                      label: Text(
                        _cart.contains(tiggo.id)
                            ? '✓ ${s.t('in_cart')}'
                            : (available ? s.t('reserve_now') : s.t('booked')),
                        style: const TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 12),
                      ),
                    ),
                  ],
                ),
              ],
            )
          : Row(
              children: [
                Expanded(
                  flex: 5,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Wrap(
                        crossAxisAlignment: WrapCrossAlignment.center,
                        spacing: 12,
                        runSpacing: 4,
                        children: [
                          const Text(
                            'CHERY TIGGO 9',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 22,
                              fontWeight: FontWeight.w900,
                              letterSpacing: -0.5,
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 10, vertical: 3),
                            decoration: BoxDecoration(
                              color: const Color(0xFF10B981).withAlpha(40),
                              borderRadius: BorderRadius.circular(12),
                              border:
                                  Border.all(color: const Color(0xFF10B981)),
                            ),
                            child: const Text(
                              'FLAGSHIP AWD',
                              style: TextStyle(
                                color: Color(0xFF34D399),
                                fontSize: 10,
                                fontWeight: FontWeight.w800,
                                letterSpacing: 1,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        s.language == AppLanguage.khmer
                            ? 'រថយន្ត SUV ប្រណីត ៧កៅអីឆ្លាតវៃ AWD  •  កម្លាំង 261 HP Turbo  •  បូមម៉ាញ៉េទិច CDC'
                            : 'Ultimate Luxury 7-Seat Intelligent AWD SUV  •  261 HP Turbo  •  CDC Magnetic Suspension',
                        style: TextStyle(
                          color: Colors.white.withAlpha(200),
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Wrap(
                        crossAxisAlignment: WrapCrossAlignment.center,
                        spacing: 14,
                        runSpacing: 4,
                        children: [
                          Text.rich(
                            TextSpan(
                              text: '${s.t('daily_lease')}: ',
                              style: const TextStyle(
                                  color: Colors.white60, fontSize: 12),
                              children: [
                                TextSpan(
                                  text: '\$55 / ${s.t('day')}',
                                  style: const TextStyle(
                                    color: Color(0xFF34D399),
                                    fontSize: 15,
                                    fontWeight: FontWeight.w900,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Text.rich(
                            TextSpan(
                              text: '${s.language == AppLanguage.khmer ? 'ប្រាក់កក់ធានា' : 'Deposit'}: ',
                              style: const TextStyle(
                                  color: Colors.white60, fontSize: 12),
                              children: [
                                TextSpan(
                                  text: s.language == AppLanguage.khmer ? '\$150 (សងវិញ ១០០%)' : '\$150 (Refundable)',
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 14,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          InkWell(
                            onTap: _pickDates,
                            child: Text.rich(
                              TextSpan(
                                children: [
                                  const WidgetSpan(
                                    alignment: PlaceholderAlignment.middle,
                                    child: Padding(
                                      padding: EdgeInsets.only(right: 4),
                                      child: Icon(Icons.calendar_month,
                                          size: 14, color: Colors.white70),
                                    ),
                                  ),
                                  TextSpan(
                                    text:
                                        '${s.t('dates')} (${dateLabel(_from)} - ${dateLabel(_to)})',
                                    style: const TextStyle(
                                      color: Colors.white70,
                                      fontSize: 11,
                                      decoration: TextDecoration.underline,
                                    ),
                                  ),
                                ],
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 16),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    OutlinedButton.icon(
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.white,
                        side: const BorderSide(
                            color: Color(0xFF34D399), width: 1.5),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 18, vertical: 16),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14)),
                      ),
                      onPressed: () => _openCyberCarDetails(tiggo),
                      icon: const Icon(Icons.view_in_ar_rounded,
                          size: 18, color: Color(0xFF34D399)),
                      label: Text(
                        s.t('cyber_specs'),
                        style: const TextStyle(
                            fontWeight: FontWeight.w800, fontSize: 13),
                      ),
                    ),
                    const SizedBox(width: 10),
                    FilledButton.icon(
                      style: FilledButton.styleFrom(
                        backgroundColor: const Color(0xFF059669),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(
                            horizontal: 20, vertical: 16),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14)),
                        elevation: 4,
                      ),
                      onPressed: () => _bookTestDriveFor(tiggo),
                      icon: const Icon(Icons.speed, size: 18),
                      label: Text(
                        s.t('book_drive'),
                        style: const TextStyle(
                            fontWeight: FontWeight.w900, fontSize: 13),
                      ),
                    ),
                    const SizedBox(width: 10),
                    FilledButton.icon(
                      style: FilledButton.styleFrom(
                        backgroundColor: _cart.contains(tiggo.id)
                            ? brandEmerald
                            : (available ? brandRed : Colors.grey),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(
                            horizontal: 20, vertical: 16),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14)),
                      ),
                      onPressed: available ? () => _addToCart(tiggo) : null,
                      icon: Icon(
                        _cart.contains(tiggo.id)
                            ? Icons.check_circle_rounded
                            : Icons.shopping_bag_outlined,
                        size: 18,
                      ),
                      label: Text(
                        _cart.contains(tiggo.id)
                            ? '✓ ${s.t('in_cart')} (\$55/d)'
                            : (available ? '${s.t('reserve_now')} (\$55/d)' : s.t('booked')),
                        style: const TextStyle(
                            fontWeight: FontWeight.w900, fontSize: 13),
                      ),
                    ),
                  ],
                ),
              ],
            ),
    );
  }

  Widget _buildClassicHeroBody(bool isMobile, bool isTablet) {
    return Container(
      key: const ValueKey('ClassicBanner'),
      padding: EdgeInsets.symmetric(
        horizontal: isMobile ? 12 : 24,
        vertical: isMobile ? 24 : 36,
      ),
      decoration: BoxDecoration(
        color: darkCard,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.white12),
      ),
      child: isMobile
          ? Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildHeroCopy(isMobile),
                const SizedBox(height: 32),
                SizedBox(
                  height: 240,
                  child: _buildHeroCarVisual(),
                ),
              ],
            )
          : Row(
              children: [
                Expanded(flex: 5, child: _buildHeroCopy(isMobile)),
                const SizedBox(width: 32),
                Expanded(
                  flex: 6,
                  child: SizedBox(
                    height: 340,
                    child: _buildHeroCarVisual(),
                  ),
                ),
              ],
            ),
    );
  }

  Widget _buildHeroCopy(bool isMobile) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          s.t('drive_your_dream'),
          style: const TextStyle(
            color: brandRed,
            fontSize: 12,
            fontWeight: FontWeight.w800,
            letterSpacing: 2,
          ),
        ),
        const SizedBox(height: 14),
        Text(
          s.t('hero_title'),
          style: TextStyle(
            color: Colors.white,
            fontSize: isMobile ? 34 : 48,
            fontWeight: FontWeight.w900,
            height: 1.15,
            letterSpacing: -0.5,
          ),
        ),
        const SizedBox(height: 16),
        Text(
          s.t('hero_subtitle'),
          style: TextStyle(
            color: Colors.white.withAlpha(200),
            fontSize: isMobile ? 13 : 15,
            height: 1.6,
          ),
        ),
        const SizedBox(height: 28),
        Wrap(
          spacing: 14,
          runSpacing: 12,
          children: [
            FilledButton(
              style: FilledButton.styleFrom(
                backgroundColor: brandRed,
                foregroundColor: Colors.white,
                padding:
                    const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(24)),
              ),
              onPressed: () => _scrollTo(_carsKey),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(s.t('browse_cars'),
                      style:
                          const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                  const SizedBox(width: 8),
                  const Icon(Icons.arrow_forward, size: 16),
                ],
              ),
            ),
            OutlinedButton.icon(
              style: OutlinedButton.styleFrom(
                foregroundColor: Colors.white,
                side: const BorderSide(color: Colors.white38),
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(24)),
              ),
              onPressed: _pickDates,
              icon: const Icon(Icons.play_circle_outline, size: 18),
              label: Text('${s.t('trip_dates')} (${dateLabel(_from)})',
                  style: const TextStyle(
                      fontWeight: FontWeight.w600, fontSize: 13)),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildHeroCarVisual() {
    return Stack(
      alignment: Alignment.center,
      children: [
        Container(
          width: 320,
          height: 160,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: const Color(0xFFF97316).withAlpha(35),
          ),
        ),
        const VehicleArt(type: 'Car', color: Color(0xFF1E293B)),
      ],
    );
  }

  // -------------------------------------------------------------------------
  // 3. TRUST BADGES BAR
  // -------------------------------------------------------------------------

  Widget _buildTrustBar(bool isMobile) {
    final items = [
      (
        icon: Icons.verified_user_outlined,
        title: s.t('trusted_dealership'),
        desc: s.t('genuine_verified')
      ),
      (
        icon: Icons.sell_outlined,
        title: s.t('best_prices'),
        desc: s.t('competitive_rates')
      ),
      (
        icon: Icons.headset_mic_outlined,
        title: s.t('expert_support'),
        desc: s.t('always_here_to_help')
      ),
      (
        icon: Icons.flight_takeoff_outlined,
        title: s.t('easy_trade_in'),
        desc: s.t('upgrade_confidence')
      ),
    ];

    return Container(
      color: Colors.white,
      padding: EdgeInsets.symmetric(
          vertical: isMobile ? 24 : 32, horizontal: isMobile ? 16 : 40),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1280),
          child: LayoutBuilder(
            builder: (context, constraints) {
              final cols = isMobile ? 1 : (constraints.maxWidth > 900 ? 4 : 2);
              final width = (constraints.maxWidth - (cols - 1) * 20) / cols;

              return Wrap(
                spacing: 20,
                runSpacing: 20,
                children: [
                  for (final item in items)
                    SizedBox(
                      width: width,
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: const Color(0xFFF3F4F6),
                              borderRadius: BorderRadius.circular(10),
                              border:
                                  Border.all(color: const Color(0xFFE5E7EB)),
                            ),
                            child: Icon(item.icon, color: textDark, size: 22),
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  item.title,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w800,
                                    fontSize: 14,
                                    color: textDark,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  item.desc,
                                  style: const TextStyle(
                                      fontSize: 11, color: textMuted),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }

  // -------------------------------------------------------------------------
  // 4. FEATURED CARS SECTION
  // -------------------------------------------------------------------------

  Widget _buildFeaturedCarsSection(bool isMobile, bool isTablet) {
    final totalFleet = s.vehicles.length;
    final availableFleet = s.vehicles.where((v) => s.available(v, _from, _to)).length;
    final unavailableFleet = totalFleet - availableFleet;

    return Container(
      key: _carsKey,
      color: sectionLight,
      padding: EdgeInsets.symmetric(
          vertical: isMobile ? 40 : 64, horizontal: isMobile ? 16 : 40),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1280),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                s.t('featured_cars'),
                style: const TextStyle(
                  color: brandRed,
                  fontSize: 11,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 1.5,
                ),
              ),
              const SizedBox(height: 6),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    s.t('popular_cars'),
                    style: const TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.w900,
                      color: textDark,
                      letterSpacing: -0.5,
                    ),
                  ),
                  TextButton(
                    onPressed: () => setState(() {
                      _selectedCategory = 'All';
                      _selectedStockFilter = 'All';
                    }),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(s.t('view_all_cars'),
                            style: const TextStyle(
                                color: textDark,
                                fontWeight: FontWeight.bold,
                                fontSize: 13)),
                        const SizedBox(width: 4),
                        const Icon(Icons.arrow_forward, color: textDark, size: 14),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Live Showroom Stock Status Summary Card
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: lightBorder),
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
                    // Header Row with Live Indicator & Selected Dates
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            Container(
                              width: 9,
                              height: 9,
                              decoration: const BoxDecoration(
                                color: Color(0xFF10B981),
                                shape: BoxShape.circle,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              s.t('showroom_fleet_stock').toUpperCase(),
                              style: const TextStyle(
                                fontSize: 11.5,
                                fontWeight: FontWeight.w900,
                                color: textDark,
                                letterSpacing: 0.8,
                              ),
                            ),
                          ],
                        ),
                        InkWell(
                          onTap: _pickDates,
                          borderRadius: BorderRadius.circular(8),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(Icons.event, size: 14, color: brandRed),
                                const SizedBox(width: 4),
                                Text(
                                  '${dateLabel(_from)} - ${dateLabel(_to)}',
                                  style: const TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.bold,
                                    color: textDark,
                                  ),
                                ),
                                const SizedBox(width: 4),
                                const Icon(Icons.edit_calendar, size: 13, color: textMuted),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    // Stock Filter Selection Chips (All, Available, Unavailable)
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        ChoiceChip(
                          avatar: Icon(
                            Icons.directions_car_rounded,
                            size: 15,
                            color: _selectedStockFilter == 'All' ? Colors.white : textDark,
                          ),
                          label: Text('${s.t('stock_filter_all')} ($totalFleet)'),
                          selected: _selectedStockFilter == 'All',
                          selectedColor: textDark,
                          backgroundColor: const Color(0xFFF9FAFB),
                          labelStyle: TextStyle(
                            color: _selectedStockFilter == 'All' ? Colors.white : textDark,
                            fontWeight: FontWeight.w700,
                            fontSize: 12,
                          ),
                          side: BorderSide(
                            color: _selectedStockFilter == 'All' ? textDark : lightBorder,
                          ),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                          onSelected: (_) => setState(() => _selectedStockFilter = 'All'),
                        ),
                        ChoiceChip(
                          avatar: Icon(
                            Icons.check_circle_rounded,
                            size: 15,
                            color: _selectedStockFilter == 'Available' ? Colors.white : const Color(0xFF059669),
                          ),
                          label: Text('${s.t('stock_filter_available')} ($availableFleet)'),
                          selected: _selectedStockFilter == 'Available',
                          selectedColor: const Color(0xFF059669),
                          backgroundColor: const Color(0xFFECFDF5),
                          labelStyle: TextStyle(
                            color: _selectedStockFilter == 'Available' ? Colors.white : const Color(0xFF065F46),
                            fontWeight: FontWeight.w700,
                            fontSize: 12,
                          ),
                          side: BorderSide(
                            color: _selectedStockFilter == 'Available' ? const Color(0xFF059669) : const Color(0xFFA7F3D0),
                          ),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                          onSelected: (_) => setState(() => _selectedStockFilter = 'Available'),
                        ),
                        ChoiceChip(
                          avatar: Icon(
                            Icons.event_busy_rounded,
                            size: 15,
                            color: _selectedStockFilter == 'Unavailable' ? Colors.white : const Color(0xFFE11D48),
                          ),
                          label: Text('${s.t('stock_filter_unavailable')} ($unavailableFleet)'),
                          selected: _selectedStockFilter == 'Unavailable',
                          selectedColor: const Color(0xFFE11D48),
                          backgroundColor: const Color(0xFFFFE4E6),
                          labelStyle: TextStyle(
                            color: _selectedStockFilter == 'Unavailable' ? Colors.white : const Color(0xFF9F1239),
                            fontWeight: FontWeight.w700,
                            fontSize: 12,
                          ),
                          side: BorderSide(
                            color: _selectedStockFilter == 'Unavailable' ? const Color(0xFFE11D48) : const Color(0xFFFECDD3),
                          ),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                          onSelected: (_) => setState(() => _selectedStockFilter = 'Unavailable'),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 16),
              // Category Filter Chips
              Builder(builder: (context) {
                final categoriesList = <String>['All'];
                for (final c in s.categories) {
                  if (c.toLowerCase() != 'all' && !categoriesList.contains(c)) {
                    categoriesList.add(c);
                  }
                }

                return Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    for (final cat in categoriesList)
                      ChoiceChip(
                        label: Text(
                          s.language == AppLanguage.khmer
                              ? (cat.toLowerCase() == 'all'
                                  ? 'ទាំងអស់'
                                  : (cat == 'SUV'
                                      ? 'SUV'
                                      : (cat == 'Sedan'
                                          ? 'សេដាន'
                                          : (cat == 'Luxury'
                                              ? 'ប្រណីត'
                                              : (cat == 'Electric'
                                                  ? 'អគ្គិសនី'
                                                  : cat)))))
                              : cat,
                        ),
                        selected:
                            _selectedCategory.toLowerCase() == cat.toLowerCase(),
                        selectedColor: brandRed,
                        backgroundColor: Colors.white,
                        labelStyle: TextStyle(
                          color:
                              _selectedCategory.toLowerCase() == cat.toLowerCase()
                                  ? Colors.white
                                  : textDark,
                          fontWeight: FontWeight.w700,
                          fontSize: 12,
                        ),
                        side: BorderSide(
                          color:
                              _selectedCategory.toLowerCase() == cat.toLowerCase()
                                  ? brandRed
                                  : lightBorder,
                          width:
                              _selectedCategory.toLowerCase() == cat.toLowerCase()
                                  ? 1.5
                                  : 1,
                        ),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20)),
                        onSelected: (_) =>
                            setState(() => _selectedCategory = cat),
                      ),
                  ],
                );
              }),
              const SizedBox(height: 24),
              _buildCarGrid(isMobile, isTablet),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCarGrid(bool isMobile, bool isTablet) {
    final list = s.vehicles.where((v) {
      final matchesCategory = _selectedCategory == 'All' ||
          v.type.toLowerCase() == _selectedCategory.toLowerCase();
      if (!matchesCategory) return false;

      final isAvail = s.available(v, _from, _to);
      if (_selectedStockFilter == 'Available') return isAvail;
      if (_selectedStockFilter == 'Unavailable') return !isAvail;
      return true;
    }).toList();

    if (list.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(40),
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: lightBorder),
        ),
        child: Column(
          children: [
            const Icon(Icons.directions_car_outlined,
                size: 48, color: textMuted),
            const SizedBox(height: 12),
            Text(
              s.language == AppLanguage.khmer
                  ? 'មិនមានរថយន្តត្រូវនឹងលក្ខខណ្ឌស្វែងរកទេ'
                  : 'No vehicles found matching current filters',
              style: const TextStyle(
                  fontWeight: FontWeight.bold, fontSize: 16, color: textDark),
            ),
            const SizedBox(height: 8),
            Text(
              s.language == AppLanguage.khmer
                  ? 'សូមសាកល្បងជ្រើសរើសប្រភេទផ្សេងទៀត ឬកំណត់តម្រងស្តុកឡើងវិញ។'
                  : 'Try selecting another category or resetting your stock filter.',
              style: const TextStyle(color: textMuted, fontSize: 13),
            ),
            const SizedBox(height: 16),
            FilledButton(
              style: FilledButton.styleFrom(backgroundColor: brandRed),
              onPressed: () => setState(() {
                _selectedCategory = 'All';
                _selectedStockFilter = 'All';
              }),
              child: Text(s.t('show_all_cars')),
            ),
          ],
        ),
      );
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        final double maxWidth = constraints.maxWidth;
        final int cols;
        if (maxWidth < 640) {
          cols = 1;
        } else if (maxWidth < 960) {
          cols = 2;
        } else if (maxWidth < 1200) {
          cols = 3;
        } else {
          cols = 4;
        }

        const double spacing = 20.0;
        final double width = (maxWidth - (cols - 1) * spacing) / cols;

        return Wrap(
          spacing: spacing,
          runSpacing: spacing,
          alignment: WrapAlignment.start,
          crossAxisAlignment: WrapCrossAlignment.start,
          children: [
            for (final v in list)
              SizedBox(
                width: width,
                child: _InteractiveCarCard(
                  vehicle: v,
                  isAvailable: s.available(v, _from, _to),
                  status: s.vehicleStatus(v),
                  isFavorite: _favorites.contains(v.id),
                  isInCart: _cart.contains(v.id),
                  language: s.language,
                  onToggleFavorite: () => _toggleFavorite(v.id),
                  onAddToCart: () => _addToCart(v),
                  onOpenCart: _openCart,
                  onUnavailableTap: () => _showUnavailableDialog(v),
                  onViewDetails: () => _openCyberCarDetails(v),
                ),
              ),
          ],
        );
      },
    );
  }

  // -------------------------------------------------------------------------
  // 5. ABOUT US SECTION
  // -------------------------------------------------------------------------

  Widget _buildAboutUsSection(bool isMobile) {
    return Container(
      key: _aboutKey,
      color: Colors.white,
      padding: EdgeInsets.symmetric(
          vertical: isMobile ? 40 : 64, horizontal: isMobile ? 16 : 40),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1280),
          child: isMobile
              ? Column(
                  children: [
                    _buildCockpitVisual(),
                    const SizedBox(height: 32),
                    _buildAboutText(),
                  ],
                )
              : Row(
                  children: [
                    Expanded(flex: 5, child: _buildCockpitVisual()),
                    const SizedBox(width: 48),
                    Expanded(flex: 6, child: _buildAboutText()),
                  ],
                ),
        ),
      ),
    );
  }

  Widget _buildCockpitVisual() {
    return Container(
      height: 320,
      decoration: BoxDecoration(
        color: const Color(0xFF0F172A),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(20),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          const Icon(Icons.speed, size: 120, color: Colors.white10),
          Positioned(
            bottom: 24,
            left: 24,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  s.t('more_than_cars'),
                  style: const TextStyle(
                    color: Colors.white,
                    fontStyle: FontStyle.italic,
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  s.t('we_build_trust'),
                  style: const TextStyle(
                    color: brandRed,
                    fontStyle: FontStyle.italic,
                    fontSize: 22,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAboutText() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          s.t('why_choose_us'),
          style: const TextStyle(
            color: brandRed,
            fontSize: 11,
            fontWeight: FontWeight.w800,
            letterSpacing: 1.5,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          s.t('trusted_agency'),
          style: const TextStyle(
            fontSize: 30,
            fontWeight: FontWeight.w900,
            color: textDark,
            letterSpacing: -0.5,
          ),
        ),
        const SizedBox(height: 14),
        Text(
          s.t('about_intro'),
          style: const TextStyle(color: textMuted, fontSize: 13, height: 1.6),
        ),
        const SizedBox(height: 20),
        Wrap(
          spacing: 24,
          runSpacing: 12,
          children: [
            _checkItem(s.t('about_bullet_1')),
            _checkItem(s.t('about_bullet_2')),
            _checkItem(s.t('about_bullet_3')),
            _checkItem(s.t('about_bullet_4')),
          ],
        ),
        const SizedBox(height: 24),
        FilledButton(
          style: FilledButton.styleFrom(
            backgroundColor: textDark,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          ),
          onPressed: () => _scrollTo(_servicesKey),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(s.t('learn_more'),
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
              const SizedBox(width: 6),
              const Icon(Icons.arrow_forward, size: 14),
            ],
          ),
        ),
      ],
    );
  }

  Widget _checkItem(String text) {
    return SizedBox(
      width: 240,
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(4),
            decoration: const BoxDecoration(
              color: Color(0xFFFEE2E2),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.check, color: brandRed, size: 14),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(
                  fontWeight: FontWeight.w600, fontSize: 12, color: textDark),
            ),
          ),
        ],
      ),
    );
  }

  // -------------------------------------------------------------------------
  // 6. OUR SERVICES SECTION
  // -------------------------------------------------------------------------

  Widget _buildServicesSection(bool isMobile) {
    final services = [
      (
        icon: Icons.directions_car_outlined,
        title: s.language == AppLanguage.khmer ? 'សេវាជួលប្រចាំថ្ងៃ & សប្តាហ៍' : 'Daily & Weekly Rentals',
        desc: s.language == AppLanguage.khmer ? 'ម៉ាកល្បីៗ តម្លៃជួលសមរម្យ' : 'Top brands, best rental rates'
      ),
      (
        icon: Icons.business_center_outlined,
        title: s.language == AppLanguage.khmer ? 'សេវាជួលរយៈពេលវែង & សាជីវកម្ម' : 'Monthly & Corporate Fleet',
        desc: s.language == AppLanguage.khmer ? 'ដំណោះស្រាយជួលសម្រាប់ក្រុមហ៊ុន' : 'Flexible corporate lease terms'
      ),
      (
        icon: Icons.flight_takeoff_outlined,
        title: s.language == AppLanguage.khmer ? 'សេវាប្រគល់រថយន្តព្រលាន & ទីតាំង' : 'Airport & Doorstep Delivery',
        desc: s.language == AppLanguage.khmer ? 'ប្រគល់ជូនដល់កន្លែង ២៤/៧' : 'VIP airport & hotel handover'
      ),
      (
        icon: Icons.verified_user_outlined,
        title: s.language == AppLanguage.khmer ? 'ធានារ៉ាប់រងពេញ & សង្គ្រោះ ២៤/៧' : 'Full Insurance & 24/7 Rescue',
        desc: s.language == AppLanguage.khmer ? 'ទំនុកចិត្តលើគ្រប់ការធ្វើដំណើរ' : 'Comprehensive rental protection'
      ),
    ];

    return Container(
      key: _servicesKey,
      color: sectionLight,
      padding: EdgeInsets.symmetric(
          vertical: isMobile ? 40 : 64, horizontal: isMobile ? 16 : 40),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1280),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                s.t('our_services'),
                style: const TextStyle(
                  color: brandRed,
                  fontSize: 11,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 1.5,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                s.language == AppLanguage.khmer
                    ? 'សេវាកម្មជួលរថយន្តគ្រប់ជ្រុងជ្រោយ'
                    : 'Comprehensive Rental Services',
                style: const TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.w900,
                  color: textDark,
                  letterSpacing: -0.5,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                s.language == AppLanguage.khmer
                    ? 'យើងផ្តល់ជូននូវសេវាកម្មជួលរថយន្តពេញលេញ ដើម្បីធ្វើឱ្យការធ្វើដំណើរ និងដំណើរកម្សាន្តរបស់អ្នកកាន់តែងាយស្រួល សុវត្ថិភាព និងទំនុកចិត្តខ្ពស់បំផុត។'
                    : 'We offer a complete range of vehicle rental solutions to make your business trips and vacations seamless, safe and enjoyable.',
                style: const TextStyle(color: textMuted, fontSize: 13),
              ),
              const SizedBox(height: 36),
              LayoutBuilder(
                builder: (context, constraints) {
                  final cols =
                      isMobile ? 1 : (constraints.maxWidth > 900 ? 4 : 2);
                  final width = (constraints.maxWidth - (cols - 1) * 20) / cols;

                  return Wrap(
                    spacing: 20,
                    runSpacing: 20,
                    children: [
                      for (int i = 0; i < services.length; i++)
                        _buildInteractiveServiceCard(
                          item: services[i],
                          width: width,
                          onTap: () => _handleServiceClick(i),
                        ),
                    ],
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInteractiveServiceCard({
    required ({IconData icon, String title, String desc}) item,
    required double width,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        hoverColor: brandRed.withAlpha(10),
        child: Container(
          width: width,
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: lightBorder),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withAlpha(8),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: brandRed.withAlpha(16),
                  shape: BoxShape.circle,
                ),
                child: Icon(item.icon, size: 32, color: brandRed),
              ),
              const SizedBox(height: 16),
              Text(
                item.title,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontWeight: FontWeight.w800,
                  fontSize: 15,
                  color: textDark,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                item.desc,
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 12, color: textMuted),
              ),
              const SizedBox(height: 14),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    s.language == AppLanguage.khmer ? 'ស្វែងយល់បន្ថែម' : 'Learn More',
                    style: const TextStyle(
                      color: brandRed,
                      fontSize: 12,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(width: 4),
                  const Icon(Icons.arrow_forward_rounded, size: 14, color: brandRed),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _handleServiceClick(int index) {
    switch (index) {
      case 0:
        _scrollTo(_carsKey);
        setState(() => _selectedCategory = 'All');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            backgroundColor: darkBg,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            content: Row(
              children: [
                const Icon(Icons.directions_car, color: brandEmerald, size: 20),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    s.language == AppLanguage.khmer
                        ? 'រុករករថយន្តទាំងអស់ក្នុងស្តុករបស់យើង'
                        : 'Exploring all vehicles in our fleet catalog',
                    style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
                  ),
                ),
              ],
            ),
          ),
        );
        break;
      case 1:
        _showCorporateFleetDialog();
        break;
      case 2:
        _showAirportDeliveryDialog();
        break;
      case 3:
        _showInspectionDialog();
        break;
    }
  }

  void _showCorporateFleetDialog() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: brandRed.withAlpha(25),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(Icons.business_center_outlined, color: brandRed, size: 24),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    s.language == AppLanguage.khmer
                        ? 'សេវាជួលរយៈពេលវែង & សាជីវកម្ម'
                        : 'Monthly & Corporate Fleet',
                    style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 18, color: textDark),
                  ),
                  Text(
                    s.language == AppLanguage.khmer
                        ? 'ដំណោះស្រាយជួលសម្រាប់ក្រុមហ៊ុន & អាជីវកម្ម'
                        : 'Dedicated corporate fleet solutions with zero maintenance burden',
                    style: const TextStyle(fontSize: 12, color: textMuted),
                  ),
                ],
              ),
            ),
          ],
        ),
        content: SizedBox(
          width: 500,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: const Color(0xFFF8FAFC),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: const Color(0xFFE2E8F0)),
                ),
                child: Column(
                  children: [
                    _buildDialogFeature(
                      Icons.check_circle_rounded,
                      s.language == AppLanguage.khmer
                          ? 'កិច្ចសន្យាបត់បែនប្រចាំខែ (១ ដល់ ២៤+ ខែ) ជាមួយតម្លៃបញ្ចុះពិសេស'
                          : 'Flexible monthly leases (1 to 24+ mos) with bulk discounts',
                    ),
                    const SizedBox(height: 8),
                    _buildDialogFeature(
                      Icons.check_circle_rounded,
                      s.language == AppLanguage.khmer
                          ? 'គ្មានបន្ទុកថែទាំ៖ ការត្រួតពិនិត្យ និងប្តូរប្រេងម៉ាស៊ីនដោយឥតគិតថ្លៃ'
                          : 'Zero maintenance liability: servicing and tire care included',
                    ),
                    const SizedBox(height: 8),
                    _buildDialogFeature(
                      Icons.check_circle_rounded,
                      s.language == AppLanguage.khmer
                          ? 'ធានាប្តូររថយន្តជំនួសភ្លាមៗ ប្រសិនបើរថយន្តត្រូវការជួសជុល'
                          : 'Instant replacement vehicle guarantee anywhere in Cambodia',
                    ),
                    const SizedBox(height: 8),
                    _buildDialogFeature(
                      Icons.check_circle_rounded,
                      s.language == AppLanguage.khmer
                          ? 'វិក្កយបត្រសាជីវកម្មផ្លូវការ ងាយស្រួលកាត់កងពន្ធអាជីវកម្ម'
                          : 'Official corporate tax-compliant invoicing and VAT receipts',
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              Text(
                s.language == AppLanguage.khmer
                    ? 'ចង់បានសម្រង់តម្លៃពិសេសសម្រាប់ក្រុមហ៊ុន ឬកងរថយន្តបុគ្គលិក? ក្រុមការងារសេវាជួលសាជីវកម្មរបស់យើងត្រៀមខ្លួនជួយលោកអ្នក។'
                    : 'Looking for tailored monthly fleet quotes for your company executives or staff? Our corporate specialists are ready to assist you.',
                style: const TextStyle(fontSize: 13, color: Color(0xFF475569), height: 1.4),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(
              s.language == AppLanguage.khmer ? 'បិទ' : 'Close',
              style: const TextStyle(color: textMuted, fontWeight: FontWeight.bold),
            ),
          ),
          FilledButton.icon(
            style: FilledButton.styleFrom(backgroundColor: brandRed),
            icon: const Icon(Icons.chat_bubble_outline_rounded, size: 16),
            onPressed: () {
              Navigator.pop(ctx);
              _contactMessage.text = s.language == AppLanguage.khmer
                  ? 'ខ្ញុំមានចំណាប់អារម្មណ៍លើសេវាជួលរថយន្តរយៈពេលវែង ឬសម្រាប់ក្រុមហ៊ុន (Corporate Fleet) សូមទាក់ទងមកខ្ញុំវិញ។'
                  : 'I am interested in corporate long-term vehicle rental. Please contact me with a quote.';
              _scrollTo(_contactKey);
            },
            label: Text(
              s.language == AppLanguage.khmer ? 'ស្នើសុំសម្រង់តម្លៃសាជីវកម្ម' : 'Request Corporate Quote',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }

  void _showAirportDeliveryDialog() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: brandEmerald.withAlpha(25),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(Icons.flight_takeoff_outlined, color: brandEmerald, size: 24),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    s.language == AppLanguage.khmer
                        ? 'សេវាប្រគល់រថយន្តព្រលាន & ទីតាំង'
                        : 'Airport & Doorstep Delivery',
                    style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 18, color: textDark),
                  ),
                  Text(
                    s.language == AppLanguage.khmer
                        ? 'ប្រគល់ និងទទួលរថយន្តដល់ទីកន្លែង ២៤/៧'
                        : 'VIP airport terminal and doorstep hotel handover 24/7',
                    style: const TextStyle(fontSize: 12, color: textMuted),
                  ),
                ],
              ),
            ),
          ],
        ),
        content: SizedBox(
          width: 500,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: const Color(0xFFF8FAFC),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: const Color(0xFFE2E8F0)),
                ),
                child: Column(
                  children: [
                    _buildDialogFeature(
                      Icons.check_circle_rounded,
                      s.language == AppLanguage.khmer
                          ? 'ប្រគល់រថយន្តផ្ទាល់ដល់ច្រកចេញព្រលានយន្តហោះភ្នំពេញ និងសៀមរាប'
                          : 'Direct terminal curbside handover at Phnom Penh & Siem Reap Airports',
                    ),
                    const SizedBox(height: 8),
                    _buildDialogFeature(
                      Icons.check_circle_rounded,
                      s.language == AppLanguage.khmer
                          ? 'សេវាដឹកជញ្ជូនដល់មុខសណ្ឋាគារ វីឡា ឬគេហដ្ឋានរបស់អ្នក'
                          : 'Doorstep vehicle delivery to your hotel, villa, or residence',
                    ),
                    const SizedBox(height: 8),
                    _buildDialogFeature(
                      Icons.check_circle_rounded,
                      s.language == AppLanguage.khmer
                          ? 'តាមដានជើងហោះហើរស្វ័យប្រវត្តិ មិនគិតប្រាក់បន្ថែមបើជើងហោះហើរពន្យារពេល'
                          : 'Live flight tracking: zero extra fee for delayed arrivals',
                    ),
                    const SizedBox(height: 8),
                    _buildDialogFeature(
                      Icons.check_circle_rounded,
                      s.language == AppLanguage.khmer
                          ? 'ពិនិត្យ និងប្រគល់សោររហ័សត្រឹម ៥ នាទីតាមប្រព័ន្ធឌីជីថល'
                          : 'Express 5-minute digital check-in and contactless key handover',
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              Text(
                s.language == AppLanguage.khmer
                    ? 'គ្រាន់តែប្រាប់យើងអំពីលេខជើងហោះហើរ ឬអាសយដ្ឋានសណ្ឋាគាររបស់អ្នក ក្រុមការងារយើងនឹងរៀបចំរថយន្តរង់ចាំអ្នកជាស្រេច។'
                    : 'Simply provide your flight number or hotel address, and our team will have your rental car sanitized and ready upon arrival.',
                style: const TextStyle(fontSize: 13, color: Color(0xFF475569), height: 1.4),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(
              s.language == AppLanguage.khmer ? 'បិទ' : 'Close',
              style: const TextStyle(color: textMuted, fontWeight: FontWeight.bold),
            ),
          ),
          FilledButton.icon(
            style: FilledButton.styleFrom(backgroundColor: brandEmerald),
            icon: const Icon(Icons.send_rounded, size: 16),
            onPressed: () {
              Navigator.pop(ctx);
              _contactMessage.text = s.language == AppLanguage.khmer
                  ? 'ខ្ញុំចង់កក់សេវាប្រគល់រថយន្តនៅព្រលានយន្តហោះ ឬសណ្ឋាគារ សូមទាក់ទងមកខ្ញុំវិញ។'
                  : 'I would like to arrange airport/hotel vehicle delivery. Please contact me.';
              _scrollTo(_contactKey);
            },
            label: Text(
              s.language == AppLanguage.khmer ? 'កក់សេវាប្រគល់នៅព្រលាន' : 'Book Airport Handover',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }

  void _showInspectionDialog() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: const Color(0xFF0284C7).withAlpha(25),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(Icons.verified_outlined, color: Color(0xFF0284C7), size: 24),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    s.language == AppLanguage.khmer
                        ? 'ការត្រួតពិនិត្យរថយន្ត ១៥០+ ចំណុច'
                        : '150+ Point Vehicle Inspection',
                    style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 18, color: textDark),
                  ),
                  Text(
                    s.language == AppLanguage.khmer
                        ? 'គុណភាព និងសុវត្ថិភាពដែលអ្នកអាចទុកចិត្តបាន ១០០%'
                        : 'Certified quality & safety you can trust 100%',
                    style: const TextStyle(fontSize: 12, color: textMuted),
                  ),
                ],
              ),
            ),
          ],
        ),
        content: SizedBox(
          width: 500,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: const Color(0xFFF8FAFC),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: const Color(0xFFE2E8F0)),
                ),
                child: Column(
                  children: [
                    _buildDialogFeature(
                      Icons.settings_suggest_rounded,
                      s.language == AppLanguage.khmer
                          ? 'ម៉ាស៊ីន និងប្រព័ន្ធបញ្ជូនកម្លាំង (Engine & Gearbox)'
                          : 'Engine compression & transmission performance',
                    ),
                    const SizedBox(height: 8),
                    _buildDialogFeature(
                      Icons.speed_rounded,
                      s.language == AppLanguage.khmer
                          ? 'ប្រព័ន្ធហ្វ្រាំង ABS និងបូមជើងក្រោម (Brakes & Shocks)'
                          : 'Brakes, steering alignment & suspension integrity',
                    ),
                    const SizedBox(height: 8),
                    _buildDialogFeature(
                      Icons.memory_rounded,
                      s.language == AppLanguage.khmer
                          ? 'ប្រព័ន្ធអេឡិចត្រូនិច និងសេនស័រ Cyber HUD (Diagnostics)'
                          : 'Full computer scan, Cyber HUD & safety sensors',
                    ),
                    const SizedBox(height: 8),
                    _buildDialogFeature(
                      Icons.shield_rounded,
                      s.language == AppLanguage.khmer
                          ? 'គ្រោងឆ្អឹងតួរថយន្ត និងពោងសុវត្ថិភាព (Safety Frame)'
                          : 'Accident-free chassis & airbag certification',
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 14),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: const Color(0xFF10B981).withAlpha(20),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: const Color(0xFF10B981).withAlpha(60)),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.verified_user_rounded, color: Color(0xFF059669), size: 18),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        s.language == AppLanguage.khmer
                            ? 'រួមបញ្ចូលការធានារយៈពេល ៦ ខែ ឬ ១០,០០០ គីឡូម៉ែត្រ'
                            : 'Includes 6-month or 10,000 km warranty coverage',
                        style: const TextStyle(
                            color: Color(0xFF059669), fontWeight: FontWeight.bold, fontSize: 12),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(
              s.language == AppLanguage.khmer ? 'បិទ' : 'Close',
              style: const TextStyle(color: textMuted, fontWeight: FontWeight.bold),
            ),
          ),
          FilledButton.icon(
            style: FilledButton.styleFrom(backgroundColor: brandRed),
            icon: const Icon(Icons.calendar_today_rounded, size: 16),
            onPressed: () {
              Navigator.pop(ctx);
              _scrollTo(_contactKey);
            },
            label: Text(
              s.language == AppLanguage.khmer ? 'កក់រថយន្តឥឡូវនេះ' : 'Reserve Rental Now',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDialogFeature(IconData icon, String text) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 18, color: brandEmerald),
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            text,
            style: const TextStyle(fontSize: 13, color: Color(0xFF334155), fontWeight: FontWeight.w600),
          ),
        ),
      ],
    );
  }

  // -------------------------------------------------------------------------
  // 7. TESTIMONIALS SECTION
  // -------------------------------------------------------------------------

  Widget _buildTestimonialsSection(bool isMobile) {
    final testimonials = s.language == AppLanguage.khmer
        ? [
            (
              quote:
                  'បទពិសោធន៍ដ៏អស្ចារ្យ! ក្រុមការងារមានប្រយោជន៍ និងធ្វើឱ្យដំណើរការទាំងមូលមានភាពងាយស្រួល។ ណែនាំយ៉ាងខ្លាំង!',
              name: 'សុខ គង់',
              location: 'ភ្នំពេញ',
              avatar: 'ស',
            ),
            (
              quote:
                  'ខ្ញុំបានរកឃើញរថយន្តដ៏ល្អឥតខ្ចោះក្នុងតម្លៃសមរម្យ។ បុគ្គលិកមានវិជ្ជាជីវៈ និងយកចិត្តទុកដាក់ចំពោះអតិថិជនពិតប្រាកដ។',
              name: 'ចាន់ ធារ៉ា',
              location: 'សៀមរាប',
              avatar: 'ច',
            ),
            (
              quote:
                  'សេវាកម្មល្អឥតខ្ចោះ និងមានជម្រើសរថយន្តជាច្រើន។ ខ្ញុំពិតជាពេញចិត្តនឹងការជួលនេះ ហើយប្រាកដជានឹងត្រឡប់មកវិញ!',
              name: 'វណ្ណដា រិទ្ធ',
              location: 'បាត់ដំបង',
              avatar: 'វ',
            ),
          ]
        : [
            (
              quote:
                  'Amazing experience! The team was very helpful and made the whole process so easy. Highly recommended!',
              name: 'Ayesha Khan',
              location: 'Lahore',
              avatar: 'A',
            ),
            (
              quote:
                  'I found the perfect car at a great price. The staff is professional and truly cares about their customers.',
              name: 'Usman Tariq',
              location: 'Karachi',
              avatar: 'U',
            ),
            (
              quote:
                  'Excellent service and a wide variety of cars. I\'m really happy with my purchase and would definitely come back!',
              name: 'Sara Ahmed',
              location: 'Islamabad',
              avatar: 'S',
            ),
          ];

    return Container(
      key: _testimonialsKey,
      color: Colors.white,
      padding: EdgeInsets.symmetric(
          vertical: isMobile ? 40 : 64, horizontal: isMobile ? 16 : 40),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1280),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                s.t('testimonials').toUpperCase(),
                style: const TextStyle(
                  color: brandRed,
                  fontSize: 11,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 1.5,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                s.t('client_testimonials'),
                style: const TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.w900,
                  color: textDark,
                  letterSpacing: -0.5,
                ),
              ),
              const SizedBox(height: 28),
              LayoutBuilder(
                builder: (context, constraints) {
                  final cols =
                      isMobile ? 1 : (constraints.maxWidth > 900 ? 3 : 1);
                  final width = (constraints.maxWidth - (cols - 1) * 20) / cols;

                  return Wrap(
                    spacing: 20,
                    runSpacing: 20,
                    children: [
                      for (final t in testimonials)
                        Container(
                          width: width,
                          padding: const EdgeInsets.all(22),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: lightBorder),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withAlpha(6),
                                blurRadius: 10,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  CircleAvatar(
                                    radius: 20,
                                    backgroundColor: const Color(0xFFF3F4F6),
                                    foregroundColor: textDark,
                                    child: Text(t.avatar,
                                        style: const TextStyle(
                                            fontWeight: FontWeight.bold)),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Text(
                                      '"${t.quote}"',
                                      style: const TextStyle(
                                        fontSize: 12,
                                        color: Color(0xFF374151),
                                        height: 1.5,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 16),
                              Row(
                                children: [
                                  const SizedBox(width: 52),
                                  Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        t.name,
                                        style: const TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 12,
                                            color: textDark),
                                      ),
                                      Text(
                                        t.location,
                                        style: const TextStyle(
                                            fontSize: 10, color: textMuted),
                                      ),
                                    ],
                                  ),
                                  const Spacer(),
                                  Row(
                                    children: [
                                      for (int i = 0; i < 5; i++)
                                        const Icon(Icons.star,
                                            color: Color(0xFFF59E0B), size: 14),
                                    ],
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                    ],
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  // -------------------------------------------------------------------------
  // 8. CONTACT / BOOK TEST DRIVE SECTION
  // -------------------------------------------------------------------------

  Widget _buildContactSection(bool isMobile) {
    return Container(
      key: _contactKey,
      color: darkBg,
      padding: EdgeInsets.symmetric(
          vertical: isMobile ? 40 : 64, horizontal: isMobile ? 16 : 40),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1280),
          child: isMobile
              ? Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildContactInfo(),
                    const SizedBox(height: 32),
                    _buildContactForm(),
                  ],
                )
              : Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(flex: 5, child: _buildContactInfo()),
                    const SizedBox(width: 48),
                    Expanded(flex: 6, child: _buildContactForm()),
                  ],
                ),
        ),
      ),
    );
  }

  Widget _buildContactInfo() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          s.language == AppLanguage.khmer ? 'ទំនាក់ទំនងយើងខ្ញុំ' : 'GET IN TOUCH',
          style: const TextStyle(
            color: brandRed,
            fontSize: 11,
            fontWeight: FontWeight.w800,
            letterSpacing: 1.5,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          s.language == AppLanguage.khmer
              ? 'កក់ការជួលរថយន្តរបស់អ្នកថ្ងៃនេះ'
              : 'Book Your Rental Reservation Today',
          style: const TextStyle(
            fontSize: 32,
            fontWeight: FontWeight.w900,
            color: Colors.white,
            letterSpacing: -0.5,
          ),
        ),
        const SizedBox(height: 12),
        Text(
          s.language == AppLanguage.khmer
              ? 'មានចម្ងល់ ឬចង់កក់រថយន្តសម្រាប់ការធ្វើដំណើរ? សូមបំពេញទម្រង់បែបបទ ហើយក្រុមការងារសេវាជួលរបស់យើងនឹងទាក់ទងបញ្ជាក់ជូនលោកអ្នកភ្លាមៗ។'
              : 'Have questions or need a customized rental package? Fill out the form and our rental concierge will confirm your booking immediately.',
          style: const TextStyle(color: Colors.white70, fontSize: 13, height: 1.5),
        ),
        const SizedBox(height: 28),
        Wrap(
          spacing: 16,
          runSpacing: 12,
          children: [
            _contactChip(Icons.phone, s.agencyConfig.phone),
            _contactChip(Icons.email, s.agencyConfig.email),
            _contactChip(Icons.location_on, s.agencyConfig.address),
          ],
        ),
      ],
    );
  }

  Widget _contactChip(IconData icon, String text) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          padding: const EdgeInsets.all(6),
          decoration: const BoxDecoration(
            color: brandRed,
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: Colors.white, size: 14),
        ),
        const SizedBox(width: 8),
        Text(text,
            style: const TextStyle(
                color: Colors.white,
                fontSize: 12,
                fontWeight: FontWeight.w600)),
      ],
    );
  }

  Widget _buildContactForm() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: darkCard,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _contactName,
                  style: const TextStyle(color: Colors.white, fontSize: 13),
                  decoration: _formInputDecoration(s.t('full_name')),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: TextField(
                  controller: _contactPhone,
                  style: const TextStyle(color: Colors.white, fontSize: 13),
                  keyboardType: TextInputType.phone,
                  decoration: _formInputDecoration(s.t('phone_number')),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _contactEmail,
                  style: const TextStyle(color: Colors.white, fontSize: 13),
                  keyboardType: TextInputType.emailAddress,
                  decoration: _formInputDecoration(s.t('email_address')),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: DropdownButtonFormField<String>(
                  isExpanded: true,
                  initialValue: _selectedInterestedCar,
                  dropdownColor: darkCard,
                  style: const TextStyle(color: Colors.white, fontSize: 13),
                  decoration: _formInputDecoration(
                      s.language == AppLanguage.khmer ? 'រថយន្តដែលចាប់អារម្មណ៍' : 'Interested Car'),
                  items: s.vehicles
                      .map((v) => DropdownMenuItem(
                            value: v.name,
                            child:
                                Text(v.name, overflow: TextOverflow.ellipsis),
                          ))
                      .toList(),
                  onChanged: (v) => setState(() => _selectedInterestedCar = v),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _contactMessage,
            maxLines: 3,
            style: const TextStyle(color: Colors.white, fontSize: 13),
            decoration: _formInputDecoration(s.t('message_optional')),
          ),
          const SizedBox(height: 18),
          FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor: brandRed,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8)),
            ),
            onPressed: _formSubmitting ? null : _submitContactForm,
            child: _formSubmitting
                ? const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(
                        color: Colors.white, strokeWidth: 2),
                  )
                : Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(s.t('send_message'),
                          style: const TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 13)),
                      const SizedBox(width: 6),
                      const Icon(Icons.arrow_forward, size: 14),
                    ],
                  ),
          ),
        ],
      ),
    );
  }

  InputDecoration _formInputDecoration(String label) {
    return InputDecoration(
      hintText: label,
      hintStyle: const TextStyle(color: Colors.white38, fontSize: 12),
      filled: true,
      fillColor: const Color(0xFF1E283E),
      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide.none,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide.none,
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: brandRed),
      ),
    );
  }

  // -------------------------------------------------------------------------
  // 9. FOOTER
  // -------------------------------------------------------------------------

  Widget _buildFooter(bool isMobile) {
    return Container(
      color: const Color(0xFF070A11),
      padding: EdgeInsets.fromLTRB(
        isMobile ? 16 : 40,
        32,
        isMobile ? 16 : 40,
        24,
      ),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1280),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _buildLogo(),
                  if (!isMobile)
                    Row(
                      children: [
                        _footerLink(s.t('home'), onTap: () {}),
                        _footerLink(s.t('about'), onTap: () => _scrollTo(_aboutKey)),
                        _footerLink(s.t('fleet'), onTap: () => _scrollTo(_carsKey)),
                        _footerLink(s.t('services'),
                            onTap: () => _scrollTo(_servicesKey)),
                        _footerLink(s.t('testimonials'),
                            onTap: () => _scrollTo(_testimonialsKey)),
                        _footerLink(s.t('contact'),
                            onTap: () => _scrollTo(_contactKey)),
                      ],
                    ),
                  Row(
                    children: [
                      _socialIcon(Icons.facebook),
                      _socialIcon(Icons.camera_alt),
                      _socialIcon(Icons.play_arrow),
                      _socialIcon(Icons.link),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 24),
              const Divider(color: Colors.white12),
              const SizedBox(height: 16),
              Wrap(
                alignment: WrapAlignment.spaceBetween,
                crossAxisAlignment: WrapCrossAlignment.center,
                spacing: 16,
                runSpacing: 10,
                children: [
                  Text(
                    s.language == AppLanguage.khmer
                        ? '© ${DateTime.now().year} ${s.agencyConfig.companyName}។ រក្សាសិទ្ធិគ្រប់យ៉ាង។'
                        : '© ${DateTime.now().year} ${s.agencyConfig.companyName}. All Rights Reserved.',
                    style: const TextStyle(color: Colors.white38, fontSize: 11),
                  ),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 7,
                        height: 7,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: s.backendConnected ? const Color(0xFF10B981) : Colors.amber,
                        ),
                      ),
                      const SizedBox(width: 6),
                      Text(
                        s.backendConnected
                            ? 'VRMS Backend (Spring Boot :8080) Connected'
                            : 'Local Storage / Offline Mode',
                        style: TextStyle(
                          color: s.backendConnected ? const Color(0xFF10B981) : Colors.white38,
                          fontSize: 11,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                  Text(
                    s.language == AppLanguage.khmer
                        ? 'គោលការណ៍ឯកជនភាព   |   លក្ខខណ្ឌប្រើប្រាស់'
                        : 'Privacy Policy   |   Terms & Conditions',
                    style: const TextStyle(color: Colors.white38, fontSize: 11),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _footerLink(String label, {required VoidCallback onTap}) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10),
      child: InkWell(
        onTap: onTap,
        child: Text(
          label,
          style: const TextStyle(
              color: Colors.white70, fontSize: 12, fontWeight: FontWeight.w500),
        ),
      ),
    );
  }

  Widget _socialIcon(IconData icon) {
    return Padding(
      padding: const EdgeInsets.only(left: 10),
      child: Container(
        padding: const EdgeInsets.all(6),
        decoration: BoxDecoration(
          color: Colors.white.withAlpha(15),
          shape: BoxShape.circle,
        ),
        child: Icon(icon, color: Colors.white70, size: 14),
      ),
    );
  }

  // -------------------------------------------------------------------------
  // 10. CYBERNETIC VEHICLE DETAILS VIEW CARD (MATCHING USER UPLOADED SCREENSHOT)
  // -------------------------------------------------------------------------

  void _openCyberCarDetails(Vehicle v) {
    final status = s.vehicleStatus(v);
    final isAvail = s.available(v, _from, _to);
    showDialog<void>(
      context: context,
      barrierColor: Colors.black.withAlpha(140),
      builder: (ctx) => Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
        child: StatefulBuilder(
          builder: (modalCtx, setModalState) {
            final inCart = _cart.contains(v.id);
            return ProfessionalCarDetailCard(
              vehicle: v,
              isInCart: inCart,
              isAvailable: isAvail,
              vehicleStatus: status,
              language: s.language,
              onAddToCart: () {
                if (!isAvail) {
                  _showUnavailableDialog(v);
                  return;
                }
                if (inCart) {
                  Navigator.pop(ctx);
                  _openCart();
                } else {
                  _addToCart(v);
                  setModalState(() {});
                }
              },
              onClose: () => Navigator.pop(ctx),
            );
          },
        ),
      ),
    );
  }

  Future<void> _openCart() async {
    final items = s.vehicles.where((v) => _cart.contains(v.id)).toList();
    await Navigator.push(
      context,
      MaterialPageRoute<void>(
        builder: (_) => RentalCart(
          store: s,
          items: items,
          from: _from,
          to: _to,
          onRemove: (id) => setState(() => _cart.remove(id)),
          onComplete: () => setState(() => _cart.clear()),
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// INTERACTIVE ANIMATED VEHICLE CARD WITH MICRO-INTERACTIONS
// ---------------------------------------------------------------------------

class _InteractiveCarCard extends StatefulWidget {
  final Vehicle vehicle;
  final bool isFavorite;
  final bool isInCart;
  final bool isAvailable;
  final String status;
  final VoidCallback onToggleFavorite;
  final VoidCallback onAddToCart;
  final VoidCallback onViewDetails;
  final VoidCallback? onUnavailableTap;
  final VoidCallback? onOpenCart;
  final AppLanguage language;

  const _InteractiveCarCard({
    required this.vehicle,
    required this.isFavorite,
    required this.isInCart,
    this.isAvailable = true,
    this.status = 'Available',
    required this.onToggleFavorite,
    required this.onAddToCart,
    required this.onViewDetails,
    this.onUnavailableTap,
    this.onOpenCart,
    this.language = AppLanguage.english,
  });

  @override
  State<_InteractiveCarCard> createState() => _InteractiveCarCardState();
}

class _InteractiveCarCardState extends State<_InteractiveCarCard> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    final v = widget.vehicle;
    Color artColor = const Color(0xFF1E293B);
    if (v.name.contains('Bugatti')) artColor = const Color(0xFF030712);
    if (v.name.contains('Fortuner')) artColor = const Color(0xFFE2E8F0);
    if (v.name.contains('Civic')) artColor = const Color(0xFFDC2626);
    if (v.name.contains('Land Cruiser')) artColor = const Color(0xFF0F172A);
    if (v.name.contains('Tesla')) artColor = const Color(0xFF0284C7);

    return MouseRegion(
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 220),
        curve: Curves.easeOutCubic,
        transform: Matrix4.translationValues(0.0, _hovered ? -6.0 : 0.0, 0.0),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: _hovered
                ? const Color(0xFFE50914).withAlpha(140)
                : const Color(0xFFE5E7EB),
            width: _hovered ? 1.5 : 1,
          ),
          boxShadow: [
            BoxShadow(
              color: _hovered
                  ? const Color(0xFFE50914).withAlpha(35)
                  : Colors.black.withAlpha(8),
              blurRadius: _hovered ? 24 : 10,
              offset: Offset(0, _hovered ? 12 : 4),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(18),
          child: InkWell(
            onTap: widget.onViewDetails,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
            // Vehicle Image / Art Header
            Stack(
              children: [
                Container(
                  height: 160,
                  decoration: const BoxDecoration(
                    color: Color(0xFFF3F4F6),
                    borderRadius:
                        BorderRadius.vertical(top: Radius.circular(17)),
                  ),
                  child: ClipRRect(
                    borderRadius:
                        const BorderRadius.vertical(top: Radius.circular(17)),
                    child: SmartImage(
                      imageSource: (v.imageUrl != null && v.imageUrl!.isNotEmpty && v.imageUrl != 'null') ? v.imageUrl : null,
                      fit: BoxFit.cover,
                      width: double.infinity,
                      fallback: VehicleArt(type: v.type, color: artColor),
                    ),
                  ),
                ),
                // Custom Badge / Featured Pill
                if (v.customBadge != null && v.customBadge!.isNotEmpty && v.customBadge != 'null')
                  Positioned(
                    top: 10,
                    left: 10,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Color(0xFFE50914), Color(0xFFB91C1C)],
                        ),
                        borderRadius: BorderRadius.circular(8),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFFE50914).withAlpha(80),
                            blurRadius: 8,
                          ),
                        ],
                      ),
                      child: Text(
                        v.customBadge!.toUpperCase(),
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 9.5,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 0.8,
                        ),
                      ),
                    ),
                  )
                else if (v.isFeatured)
                  Positioned(
                    top: 10,
                    left: 10,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: const Color(0xFF10B981),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.star, color: Colors.white, size: 10),
                          const SizedBox(width: 4),
                          Text(
                            widget.language == AppLanguage.khmer ? 'ពិសេស' : 'FEATURED',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 9.5,
                              fontWeight: FontWeight.w900,
                              letterSpacing: 0.8,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                // Wishlist / Favorite Heart button with animated scale
                Positioned(
                  top: 8,
                  right: 8,
                  child: Material(
                    color: Colors.white.withAlpha(220),
                    shape: const CircleBorder(),
                    elevation: 2,
                    child: InkWell(
                      onTap: widget.onToggleFavorite,
                      customBorder: const CircleBorder(),
                      child: Padding(
                        padding: const EdgeInsets.all(6),
                        child: AnimatedScale(
                          scale: widget.isFavorite ? 1.25 : 1.0,
                          duration: const Duration(milliseconds: 200),
                          curve: Curves.elasticOut,
                          child: Icon(
                            widget.isFavorite
                                ? Icons.favorite
                                : Icons.favorite_border,
                            color: widget.isFavorite
                                ? const Color(0xFFE50914)
                                : Colors.black54,
                            size: 18,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                // Stock Availability Status Badge
                Positioned(
                  bottom: 8,
                  left: 8,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3.5),
                    decoration: BoxDecoration(
                      color: widget.isAvailable
                          ? const Color(0xFFECFDF5).withAlpha(240)
                          : (widget.status == 'Maintenance'
                              ? const Color(0xFFFEF3C7).withAlpha(240)
                              : const Color(0xFFFFE4E6).withAlpha(240)),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: widget.isAvailable
                            ? const Color(0xFFA7F3D0)
                            : (widget.status == 'Maintenance'
                                ? const Color(0xFFFDE68A)
                                : const Color(0xFFFECDD3)),
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withAlpha(25),
                          blurRadius: 6,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          width: 6,
                          height: 6,
                          decoration: BoxDecoration(
                            color: widget.isAvailable
                                ? const Color(0xFF10B981)
                                : (widget.status == 'Maintenance'
                                    ? const Color(0xFFD97706)
                                    : const Color(0xFFE11D48)),
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 5),
                        Text(
                          widget.isAvailable
                              ? AppTranslations.tr('stock_badge_available', widget.language)
                              : (widget.status == 'Maintenance'
                                  ? AppTranslations.tr('stock_badge_maintenance', widget.language)
                                  : AppTranslations.tr('stock_badge_rented', widget.language)),
                          style: TextStyle(
                            color: widget.isAvailable
                                ? const Color(0xFF065F46)
                                : (widget.status == 'Maintenance'
                                    ? const Color(0xFF92400E)
                                    : const Color(0xFF9F1239)),
                            fontSize: 9,
                            fontWeight: FontWeight.w900,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            // Card Details
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          v.name.isNotEmpty && v.name != 'null' ? v.name : 'Vehicle',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w900,
                            color: Color(0xFF111827),
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF3F4F6),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          v.type.isNotEmpty && v.type != 'null' ? v.type.toUpperCase() : 'CAR',
                          style: const TextStyle(
                            fontSize: 9,
                            fontWeight: FontWeight.w700,
                            color: Color(0xFF6B7280),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${v.year > 0 ? v.year : 2025} | ${(v.transmission.isNotEmpty && v.transmission != 'null') ? v.transmission : 'Automatic'} | ${(v.fuel.isNotEmpty && v.fuel != 'null') ? v.fuel : 'Petrol'}',
                    style:
                        const TextStyle(fontSize: 11, color: Color(0xFF6B7280)),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Flexible(
                        flex: 5,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            FittedBox(
                              fit: BoxFit.scaleDown,
                              alignment: Alignment.centerLeft,
                              child: Text.rich(
                                TextSpan(
                                  text: money(v.dailyCents),
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w900,
                                    color: Color(0xFFE50914),
                                    letterSpacing: -0.3,
                                  ),
                                  children: [
                                    TextSpan(
                                      text: ' / ${widget.language == AppLanguage.khmer ? 'ថ្ងៃ' : 'day'}',
                                      style: const TextStyle(
                                        fontSize: 11,
                                        fontWeight: FontWeight.w700,
                                        color: Color(0xFF6B7280),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            const SizedBox(height: 1),
                            Text(
                              widget.language == AppLanguage.khmer ? 'តម្លៃជួលប្រចាំថ្ងៃ' : 'Daily Rental Rate',
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                  fontSize: 9, color: Color(0xFF9CA3AF), fontWeight: FontWeight.w500),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 6),
                      Flexible(
                        flex: 4,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            FittedBox(
                              fit: BoxFit.scaleDown,
                              alignment: Alignment.centerRight,
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFF1F5F9),
                                  borderRadius: BorderRadius.circular(6),
                                  border: Border.all(color: const Color(0xFFE2E8F0)),
                                ),
                                child: Text(
                                  '${widget.language == AppLanguage.khmer ? 'កក់' : 'Deposit'} \$${(v.dailyCents * 3 ~/ 100).clamp(100, 500)}',
                                  style: const TextStyle(
                                    fontSize: 10,
                                    fontWeight: FontWeight.w700,
                                    color: Color(0xFF334155),
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              widget.language == AppLanguage.khmer ? 'សងវិញ ១០០%' : '100% Refundable',
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                fontSize: 9,
                                color: Color(0xFF10B981),
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),
                  Row(
                    children: [
                      Expanded(
                        child: FilledButton(
                          style: FilledButton.styleFrom(
                            backgroundColor: const Color(0xFFE50914),
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 10),
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10)),
                          ),
                          onPressed: widget.onViewDetails,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                AppTranslations.tr('cyber_specs', widget.language),
                                style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 12),
                              ),
                              const SizedBox(width: 4),
                              const Icon(Icons.view_in_ar, size: 14),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      IconButton.filledTonal(
                        style: IconButton.styleFrom(
                          backgroundColor: !widget.isAvailable
                              ? const Color(0xFFFFE4E6)
                              : (widget.isInCart
                                  ? const Color(0xFF10B981).withAlpha(40)
                                  : const Color(0xFFF3F4F6)),
                          foregroundColor: !widget.isAvailable
                              ? const Color(0xFFE11D48)
                              : (widget.isInCart
                                  ? const Color(0xFF059669)
                                  : const Color(0xFF111827)),
                        ),
                        onPressed: !widget.isAvailable
                            ? (widget.onUnavailableTap ?? widget.onAddToCart)
                            : (widget.isInCart
                                ? (widget.onOpenCart ?? widget.onAddToCart)
                                : widget.onAddToCart),
                        tooltip: !widget.isAvailable
                            ? AppTranslations.tr('stock_badge_rented', widget.language)
                            : (widget.isInCart
                                ? AppTranslations.tr('in_cart', widget.language)
                                : AppTranslations.tr('add_to_reservation', widget.language)),
                        icon: Icon(
                          !widget.isAvailable
                              ? Icons.event_busy_rounded
                              : (widget.isInCart
                                  ? Icons.check_circle
                                  : Icons.add_shopping_cart),
                          size: 18,
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
    ),
  ),
);
  }
}

// ---------------------------------------------------------------------------
// VECTOR VEHICLE ILLUSTRATION ENGINE
// Modularized in lib/src/shared/vehicle_art.dart
// ---------------------------------------------------------------------------

// ---------------------------------------------------------------------------
// TIGGO 9 "ONE STEP AHEAD" SUNLIT BANNER VECTOR ENGINE
// ---------------------------------------------------------------------------

class Tiggo9BannerCanvas extends StatelessWidget {
  final bool isMobile;
  final double? height;

  const Tiggo9BannerCanvas({super.key, this.isMobile = false, this.height});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: height ?? (isMobile ? 480 : 560),
      child: CustomPaint(
        painter: _Tiggo9BannerPainter(isMobile: isMobile),
      ),
    );
  }
}

class _Tiggo9BannerPainter extends CustomPainter {
  final bool isMobile;

  _Tiggo9BannerPainter({this.isMobile = false});

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Offset.zero & size;

    // 1. Sky Gradient (Crisp Cerulean to Warm Morning Sun)
    final skyPaint = Paint()
      ..shader = const LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          Color(0xFF3880C4),
          Color(0xFF64B5F6),
          Color(0xFFBAE6FD),
          Color(0xFFFED7AA),
          Color(0xFFFFFBEB),
        ],
        stops: [0.0, 0.35, 0.65, 0.88, 1.0],
      ).createShader(rect);
    canvas.drawRect(rect, skyPaint);

    // Sun disc glow on top-right horizon
    final sunCenter = Offset(size.width * 0.88, size.height * 0.55);
    final sunPaint = Paint()
      ..shader = RadialGradient(
        colors: [
          Colors.white.withAlpha(220),
          const Color(0xFFFDE68A).withAlpha(140),
          const Color(0xFFF97316).withAlpha(30),
          Colors.transparent,
        ],
        stops: const [0.0, 0.25, 0.6, 1.0],
      ).createShader(
          Rect.fromCircle(center: sunCenter, radius: size.width * 0.45));
    canvas.drawCircle(sunCenter, size.width * 0.45, sunPaint);

    // 2. Modern Architectural Overhang (Top Left Canopy)
    final canopyPath = Path()
      ..moveTo(0, 0)
      ..lineTo(size.width * 0.48, 0)
      ..lineTo(0, size.height * 0.26)
      ..close();
    final canopyPaint = Paint()..color = const Color(0xFF1E293B);
    canvas.drawPath(canopyPath, canopyPaint);

    final canopyEdge = Paint()
      ..color = const Color(0xFF94A3B8)
      ..strokeWidth = 3
      ..style = PaintingStyle.stroke;
    canvas.drawLine(Offset(0, size.height * 0.26), Offset(size.width * 0.48, 0),
        canopyEdge);

    // 3. Cityscape Skyline Silhouette (Along horizon at y = 0.68)
    final horizonY = size.height * 0.68;
    final skylinePaint = Paint()
      ..color = const Color(0xFF64748B).withAlpha(110);
    final buildings = [
      (0.0, 45.0, 18.0),
      (0.04, 60.0, 22.0),
      (0.08, 35.0, 15.0),
      (0.12, 70.0, 26.0),
      (0.17, 50.0, 18.0),
      (0.22, 85.0, 30.0),
      (0.28, 40.0, 20.0),
      (0.33, 95.0, 32.0),
      (0.39, 65.0, 24.0),
      (0.45, 110.0, 38.0),
      (0.52, 75.0, 28.0),
      (0.58, 120.0, 40.0),
      (0.65, 80.0, 30.0),
      (0.72, 100.0, 35.0),
      (0.80, 60.0, 25.0),
      (0.88, 45.0, 20.0),
      (0.94, 30.0, 20.0),
    ];
    for (final b in buildings) {
      final bx = size.width * b.$1;
      final bh = b.$2 * (size.height / 500);
      final bw = b.$3 * (size.width / 1000);
      canvas.drawRect(Rect.fromLTWH(bx, horizonY - bh, bw, bh), skylinePaint);
    }

    // 4. Ground Deck & Infinity Water Pool
    final deckPaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          const Color(0xFF334155),
          const Color(0xFF1E293B),
          const Color(0xFF0F172A),
        ],
      ).createShader(
          Rect.fromLTWH(0, horizonY, size.width, size.height - horizonY));
    canvas.drawRect(
        Rect.fromLTWH(0, horizonY, size.width, size.height - horizonY),
        deckPaint);

    final poolPath = Path()
      ..moveTo(0, horizonY + 10)
      ..lineTo(size.width * 0.42, horizonY + 10)
      ..lineTo(size.width * 0.35, size.height)
      ..lineTo(0, size.height)
      ..close();
    final poolPaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          const Color(0xFF0F2942),
          const Color(0xFF0A192F),
          const Color(0xFF030E1C),
        ],
      ).createShader(Rect.fromLTWH(
          0, horizonY, size.width * 0.45, size.height - horizonY));
    canvas.drawPath(poolPath, poolPaint);

    final ripplePaint = Paint()
      ..color = const Color(0xFF38BDF8).withAlpha(70)
      ..strokeWidth = 1.5
      ..style = PaintingStyle.stroke;
    for (double ry = horizonY + 25; ry < size.height - 30; ry += 16) {
      final double widthFactor = ((ry - horizonY) / (size.height - horizonY));
      canvas.drawLine(
        Offset(20, ry),
        Offset(size.width * (0.15 + 0.18 * widthFactor), ry),
        ripplePaint,
      );
    }

    // 5. Giant Typography: ONE STEP AHEAD & TIGGO 9
    final textPainter1 = TextPainter(
      text: const TextSpan(
        text: 'ONE STEP AHEAD',
        style: TextStyle(
          color: Colors.white,
          fontSize: 26,
          fontWeight: FontWeight.w900,
          fontStyle: FontStyle.italic,
          letterSpacing: 3,
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();

    canvas.save();
    canvas.translate(size.width * 0.12, size.height * 0.18);
    canvas.rotate(-0.06);
    textPainter1.paint(canvas, Offset.zero);
    canvas.restore();

    final textPainter2 = TextPainter(
      text: TextSpan(
        text: 'TIGGO 9',
        style: TextStyle(
          color: Colors.white.withAlpha(245),
          fontSize: isMobile ? 64 : 110,
          fontWeight: FontWeight.w900,
          letterSpacing: 4,
          shadows: [
            Shadow(
              color: Colors.black.withAlpha(120),
              blurRadius: 18,
              offset: const Offset(4, 6),
            ),
            Shadow(
              color: const Color(0xFF047857).withAlpha(100),
              blurRadius: 30,
              offset: const Offset(0, 8),
            ),
          ],
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();

    canvas.save();
    canvas.translate(
      isMobile ? size.width * 0.08 : size.width * 0.10,
      isMobile ? size.height * 0.24 : size.height * 0.22,
    );
    canvas.rotate(-0.04);
    textPainter2.paint(canvas, Offset.zero);
    canvas.restore();

    // 6. Vector Flagship Chery Tiggo 9 SUV
    _drawTiggo9HeroVehicle(canvas, size);
  }

  void _drawTiggo9HeroVehicle(Canvas canvas, Size size) {
    canvas.save();
    final double scale = isMobile ? (size.width / 550) : (size.width / 880);
    final double carX = size.width * 0.18;
    final double carY = size.height * 0.42;

    canvas.translate(carX, carY);
    canvas.scale(scale);

    final p = Paint()..isAntiAlias = true;

    // Road Shadow & Ground Reflection
    canvas.drawOval(
      const Rect.fromLTWH(40, 240, 520, 36),
      p..color = Colors.black.withAlpha(120),
    );

    // Emerald Green Metallic SUV Body Shell
    final body = Path()
      ..moveTo(55, 210)
      ..lineTo(75, 160)
      ..lineTo(145, 140)
      ..lineTo(210, 72)
      ..lineTo(440, 72)
      ..lineTo(495, 135)
      ..lineTo(545, 155)
      ..quadraticBezierTo(575, 175, 565, 225)
      ..lineTo(550, 245)
      ..lineTo(60, 245)
      ..close();

    p.shader = const LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: [
        Color(0xFF044E3C),
        Color(0xFF065F46),
        Color(0xFF047857),
        Color(0xFF10B981),
        Color(0xFF064E3B),
      ],
      stops: [0.0, 0.25, 0.55, 0.8, 1.0],
    ).createShader(const Rect.fromLTWH(50, 70, 520, 180));
    p.style = PaintingStyle.fill;
    canvas.drawPath(body, p);
    p.shader = null;

    // Body Gloss Shoulder Crease Highlight
    final crease = Path()
      ..moveTo(80, 160)
      ..lineTo(160, 150)
      ..lineTo(380, 148)
      ..lineTo(530, 162);
    p.color = const Color(0xFF34D399).withAlpha(180);
    p.style = PaintingStyle.stroke;
    p.strokeWidth = 2.5;
    canvas.drawPath(crease, p);

    // Panoramic Tinted Greenhouse Glass
    final glass = Path()
      ..moveTo(165, 134)
      ..lineTo(220, 82)
      ..lineTo(425, 82)
      ..lineTo(478, 134)
      ..close();
    p.shader = const LinearGradient(
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
      colors: [
        Color(0xFF0F172A),
        Color(0xFF1E293B),
        Color(0xFF030712),
      ],
    ).createShader(const Rect.fromLTWH(160, 80, 320, 60));
    p.style = PaintingStyle.fill;
    canvas.drawPath(glass, p);
    p.shader = null;

    // Chrome Window Surrounds & Roof Rails
    p.color = const Color(0xFFE2E8F0);
    p.strokeWidth = 3.5;
    p.style = PaintingStyle.stroke;
    canvas.drawPath(glass, p);
    canvas.drawLine(const Offset(230, 68), const Offset(420, 68), p);

    canvas.drawLine(const Offset(290, 82), const Offset(285, 134), p);
    canvas.drawLine(const Offset(370, 82), const Offset(365, 134), p);

    // Front Chery Waterfall Diamond Grille
    final grilleRect = RRect.fromRectAndRadius(
      const Rect.fromLTWH(485, 160, 72, 70),
      const Radius.circular(16),
    );
    p.style = PaintingStyle.fill;
    p.color = const Color(0xFF0F172A);
    canvas.drawRRect(grilleRect, p);

    p.style = PaintingStyle.stroke;
    p.strokeWidth = 3;
    p.color = const Color(0xFFE2E8F0);
    canvas.drawRRect(grilleRect, p);

    p.strokeWidth = 1.8;
    for (double gx = 495; gx <= 545; gx += 7) {
      canvas.drawLine(Offset(gx, 166), Offset(gx, 224), p);
    }

    // Chery Central Emblem
    p.style = PaintingStyle.fill;
    p.color = Colors.white;
    canvas.drawCircle(const Offset(521, 185), 6, p);
    p.color = const Color(0xFF065F46);
    canvas.drawCircle(const Offset(521, 185), 3.5, p);

    // TIGGO 9 Plate
    p.color = const Color(0xFF030712);
    canvas.drawRRect(
        RRect.fromRectAndRadius(
            const Rect.fromLTWH(500, 208, 42, 14), const Radius.circular(3)),
        p);
    p.color = Colors.white;
    p.style = PaintingStyle.stroke;
    p.strokeWidth = 1;
    canvas.drawRRect(
        RRect.fromRectAndRadius(
            const Rect.fromLTWH(500, 208, 42, 14), const Radius.circular(3)),
        p);

    // Triple-L Matrix LED Headlights
    p.style = PaintingStyle.fill;
    p.color = const Color(0xFFE0F2FE);
    final headlight = Path()
      ..moveTo(470, 155)
      ..lineTo(515, 158)
      ..lineTo(495, 172)
      ..close();
    canvas.drawPath(headlight, p);

    p.color = const Color(0xFF67E8F9);
    p.style = PaintingStyle.stroke;
    p.strokeWidth = 2.5;
    canvas.drawLine(const Offset(470, 155), const Offset(515, 158), p);

    // Multi-Spoke 20-Inch Turbine Alloy Wheels
    _drawTurbineWheel(canvas, p, 155, 235);
    _drawTurbineWheel(canvas, p, 445, 235);

    canvas.restore();
  }

  void _drawTurbineWheel(Canvas canvas, Paint p, double cx, double cy) {
    p.style = PaintingStyle.fill;
    p.color = const Color(0xFF0F172A);
    canvas.drawCircle(Offset(cx, cy), 46, p);

    p.color = const Color(0xFFE2E8F0);
    p.style = PaintingStyle.stroke;
    p.strokeWidth = 3;
    canvas.drawCircle(Offset(cx, cy), 44, p);

    p.style = PaintingStyle.fill;
    p.color = const Color(0xFF1E293B);
    canvas.drawCircle(Offset(cx, cy), 34, p);

    p.color = const Color(0xFFE2E8F0);
    p.style = PaintingStyle.stroke;
    p.strokeWidth = 2;
    for (int i = 0; i < 16; i++) {
      final double angle = i * (pi * 2 / 16);
      final double x1 = cx + 12 * cos(angle);
      final double y1 = cy + 12 * sin(angle);
      final double x2 = cx + 33 * cos(angle + 0.15);
      final double y2 = cy + 33 * sin(angle + 0.15);
      canvas.drawLine(Offset(x1, y1), Offset(x2, y2), p);
    }

    p.style = PaintingStyle.fill;
    p.color = const Color(0xFF065F46);
    canvas.drawCircle(Offset(cx, cy), 10, p);
    p.color = Colors.white;
    canvas.drawCircle(Offset(cx, cy), 4, p);
  }

  @override
  bool shouldRepaint(covariant _Tiggo9BannerPainter oldDelegate) =>
      oldDelegate.isMobile != isMobile;
}
