import 'dart:async';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'models.dart';
import 'src/localization/app_language.dart';
import 'src/localization/app_translations.dart';
import 'src/services/api_service.dart';

class RentalStore extends ChangeNotifier {
  final SharedPreferences prefs;
  final ApiService api;
  bool backendConnected = false;
  bool isSyncing = false;

  List<Vehicle> vehicles = [];
  List<Customer> customers = [];
  List<Rental> rentals = [];
  List<BannerItem> banners = [];
  List<String> categories = ['All', 'SUV', 'Hypercar', 'Car', 'Electric', 'Luxury', 'Sports', 'Concept'];
  AgencyConfig agencyConfig = AgencyConfig();
  AppLanguage language = AppLanguage.english;

  RentalStore(this.prefs, {this.api = const ApiService()}) {
    final langCode = prefs.getString('driveline_lang');
    if (langCode != null) {
      language = AppLanguage.fromCode(langCode);
    }
    final raw = prefs.getString('driveline_v5') ?? prefs.getString('driveline_v4') ?? prefs.getString('driveline_v3') ?? prefs.getString('driveline_v2');
    if (raw != null) {
      try {
        final j = jsonDecode(raw) as Map<String, dynamic>;
        vehicles = (j['vehicles'] as List)
            .map((v) => Vehicle.fromJson(v as Map<String, dynamic>))
            .map(sanitizeVehicle)
            .toList();
        customers = (j['customers'] as List).map((v) => Customer.fromJson(v as Map<String, dynamic>)).toList();
        rentals = (j['rentals'] as List).map((v) => Rental.fromJson(v as Map<String, dynamic>)).toList();
        if (j['banners'] != null) {
          banners = (j['banners'] as List).map((b) => BannerItem.fromJson(b as Map<String, dynamic>)).toList();
          for (final def in defaultBanners) {
            if (!banners.any((b) => b.id == def.id)) {
              banners.add(def);
            }
          }
        } else {
          _initDefaultBanners();
        }
        if (j['categories'] != null) {
          categories = (j['categories'] as List).map((c) => c.toString()).toList();
          if (!categories.contains('All')) categories.insert(0, 'All');
        }
        if (j['agencyConfig'] != null) {
          agencyConfig = AgencyConfig.fromJson(j['agencyConfig'] as Map<String, dynamic>);
        }
        if (!vehicles.any((v) => v.id == 'v_tiggo9')) {
          vehicles.insert(0, tiggo9Vehicle);
        }
        // Auto-heal missing imageUrls from legacy storage
        for (int i = 0; i < vehicles.length; i++) {
          final v = vehicles[i];
          if (v.imageUrl == null || v.imageUrl!.isEmpty) {
            if (v.id == 'v_tiggo9' || v.name.toLowerCase().contains('tiggo')) {
              vehicles[i] = v.copyWith(imageUrl: 'assets/images/tiggo9_banner.png');
            } else if (v.id == 'v0' || v.name.toLowerCase().contains('bugatti')) {
              vehicles[i] = v.copyWith(imageUrl: 'https://images.unsplash.com/photo-1617788138017-80ad40651399?w=1200&q=80');
            } else if (v.id == 'v5' || v.name.toLowerCase().contains('tesla')) {
              vehicles[i] = v.copyWith(imageUrl: 'https://images.unsplash.com/photo-1560958089-b8a1929cea89?w=1200&q=80');
            } else if (v.id == 'v6' || v.name.toLowerCase().contains('bmw')) {
              vehicles[i] = v.copyWith(imageUrl: 'https://images.unsplash.com/photo-1555215695-3004980ad54e?w=1200&q=80');
            } else if (v.id == 'v1' || v.name.toLowerCase().contains('camry')) {
              vehicles[i] = v.copyWith(imageUrl: 'https://images.unsplash.com/photo-1621007947382-bb3c3994e3fb?w=1200&q=80');
            } else if (v.id == 'v2' || v.name.toLowerCase().contains('fortuner')) {
              vehicles[i] = v.copyWith(imageUrl: 'https://images.unsplash.com/photo-1533473359331-0135ef1b58bf?w=1200&q=80');
            } else if (v.id == 'v3' || v.name.toLowerCase().contains('civic')) {
              vehicles[i] = v.copyWith(imageUrl: 'https://images.unsplash.com/photo-1606016159991-dfe4f2746ad5?w=1200&q=80');
            } else if (v.id == 'v4' || v.name.toLowerCase().contains('land cruiser')) {
              vehicles[i] = v.copyWith(imageUrl: 'https://images.unsplash.com/photo-1594502184342-2e12f877aa73?w=1200&q=80');
            }
          }
        }
        for (int i = 0; i < banners.length; i++) {
          final b = banners[i];
          if (b.imageUrl == null || b.imageUrl!.isEmpty) {
            if (b.id == 'b_tiggo9') {
              banners[i] = b.copyWith(imageUrl: 'assets/images/tiggo9_banner.png');
            } else if (b.id == 'b_bugatti') {
              banners[i] = b.copyWith(imageUrl: 'https://images.unsplash.com/photo-1617788138017-80ad40651399?w=1200&q=80');
            } else if (b.id == 'b_tesla') {
              banners[i] = b.copyWith(imageUrl: 'https://images.unsplash.com/photo-1560958089-b8a1929cea89?w=1200&q=80');
            } else if (b.id == 'b_bmw') {
              banners[i] = b.copyWith(imageUrl: 'https://images.unsplash.com/photo-1555215695-3004980ad54e?w=1200&q=80');
            }
          }
        }
      } catch (_) {
        _initDefaults();
      }
    } else {
      _initDefaults();
    }
    // Proactively connect to Spring Boot backend asynchronously
    syncWithBackend();
  }

  void _initDefaultBanners() {
    banners = List.from(defaultBanners);
  }

  static List<BannerItem> get defaultBanners => [
        BannerItem(
          id: 'b_tiggo9',
          tagline: 'ONE STEP AHEAD',
          title: 'TIGGO 9',
          subtitle: 'Chery Flagship Luxury 7-Seat Intelligent AWD SUV',
          vehicleId: 'v_tiggo9',
          priceText: '\$55 / DAY • FULL INSURANCE',
          imageUrl: 'assets/images/tiggo9_banner.png',
          specChips: const [
            '2.0L TGDI TURBO · 261 HP',
            '8-SPEED AT · INTELLIGENT AWD',
            'CDC SUSPENSION',
            '7-SEAT LUXURY',
          ],
          badgeText: 'CHERY FLAGSHIP',
          badgeColorValue: 0xFF10B981,
          active: true,
        ),
        BannerItem(
          id: 'b_bugatti',
          tagline: 'THE EXCLUSIVE MASTERPIECE',
          title: 'LA VOITURE NOIRE',
          subtitle: '1-of-1 Bespoke Carbon Hypercar • 1500 HP W16 Quad-Turbo',
          vehicleId: 'v0',
          priceText: '\$950 / DAY • VIP CHAUFFEUR & INSURANCE',
          imageUrl: 'https://images.unsplash.com/photo-1617788138017-80ad40651399?w=1200&q=80',
          specChips: const [
            '8.0L W16 QUAD-TURBO · 1500 CV',
            '0-100 IN 2.5 SEC · 420 KM/H',
            'FULL CARBON MONOCOQUE',
            '1 OF 1 WORLDWIDE',
          ],
          badgeText: 'HYPERCAR ICON',
          badgeColorValue: 0xFFE50914,
          active: true,
        ),
        BannerItem(
          id: 'b_tesla',
          tagline: 'THE ELECTRIC REVOLUTION',
          title: 'MODEL 3 AWD',
          subtitle: 'Instant Torque Dual Motor • Autopilot Enabled Cockpit',
          vehicleId: 'v5',
          priceText: '\$75 / DAY • FREE CHARGING & GPS',
          imageUrl: 'https://images.unsplash.com/photo-1560958089-b8a1929cea89?w=1200&q=80',
          specChips: const [
            'DUAL MOTOR AWD · 450 CV',
            '0-100 IN 3.1 SEC',
            'AUTOPILOT COCKPIT',
            'SUPERCHARGING',
          ],
          badgeText: 'ZERO EMISSIONS',
          badgeColorValue: 0xFF06B6D4,
          active: true,
        ),
        BannerItem(
          id: 'b_bmw',
          tagline: 'THE ULTIMATE DRIVING MACHINE',
          title: 'BMW 4 SERIES',
          subtitle: 'TwinPower Turbo Performance • M Sport Aerodynamics',
          vehicleId: 'v6',
          priceText: '\$85 / DAY • AIRPORT PICKUP & INSURANCE',
          imageUrl: 'https://images.unsplash.com/photo-1555215695-3004980ad54e?w=1200&q=80',
          specChips: const [
            '2.0L TWINPOWER · 258 CV',
            '0-100 IN 5.8 SEC · 250 KM/H',
            'M SPORT AERODYNAMICS',
            'HARMAN KARDON AUDIO',
          ],
          badgeText: 'M SPORT LUXURY',
          badgeColorValue: 0xFF2563EB,
          active: true,
        ),
      ];

  static Vehicle get tiggo9Vehicle => Vehicle(
        'v_tiggo9',
        'Chery Tiggo 9',
        '1-TIGGO9',
        'SUV',
        5500,
        purchasePrice: 34500,
        year: 2025,
        imageUrl: 'assets/images/tiggo9_banner.png',
        seats: 7,
        transmission: '8-Speed AT AWD',
        fuel: '2.0L TGDI Turbo Petrol',
        brand: 'CHERY',
        tagline: 'ONE STEP AHEAD',
        engine: '2.0L TGDI TURBO (261 HP)',
        horsepower: '261 CV',
        topSpeed: '205 KM/H',
        acceleration: '0-100 EM 7.5S',
        designHighlights: const [
          'GRADE FRONTAL WATERFALL DIAMANTE 3D',
          'FARÓIS MATRIX LED COM DRL TRIPLO',
          'RODAS MULTIRRAIO TURBINA 20"',
          'TETO SOLAR PANORÂMICO FLUTUANTE',
        ],
        quickFacts: const [
          'PREÇO: \$34,500',
          'SUSPENSÃO ELETROMAGNÉTICA CDC',
          '7 LUGARES COCKPIT PREMIUM LUXURY',
          'ONE STEP AHEAD FLAGSHIP SUV',
        ],
        features: const [
          'CDC Magnetic Suspension',
          '24.6" Dual Curved Display',
          'Sony 14-Speaker Audio',
          'Level 2.5 ADAS Autopilot',
          'Heated & Ventilated Massage Seats',
          'Panoramic Sunroof',
          'AWD Intelligent All-Wheel Drive',
        ],
        rating: 4.99,
        tripsCount: 42,
      );

  static Vehicle sanitizeVehicle(Vehicle v) {
    String clean(String? val, String fallback) {
      if (val == null) return fallback;
      final t = val.trim();
      return (t.isEmpty || t.toLowerCase() == 'null') ? fallback : t;
    }

    String? cleanNullable(String? val) {
      if (val == null) return null;
      final t = val.trim();
      return (t.isEmpty || t.toLowerCase() == 'null') ? null : t;
    }

    final isBugatti = v.name.toLowerCase().contains('bugatti');
    final isTiggo = v.id == 'v_tiggo9' || v.name.toLowerCase().contains('tiggo');

    final cleanHighlights = v.designHighlights
        .map((h) => h.trim())
        .where((h) => h.isNotEmpty && h.toLowerCase() != 'null')
        .toList();
    final cleanFacts = v.quickFacts
        .map((q) => q.trim())
        .where((q) => q.isNotEmpty && q.toLowerCase() != 'null')
        .toList();

    return v.copyWith(
      id: clean(v.id, 'V-${DateTime.now().millisecondsSinceEpoch}'),
      name: clean(v.name, 'Vehicle'),
      brand: clean(v.brand, 'DRIVELINE').toUpperCase(),
      plate: clean(v.plate, '1-AUTO'),
      type: clean(v.type, 'Car'),
      transmission: clean(v.transmission, 'Automatic'),
      fuel: clean(v.fuel, 'Petrol'),
      engine: clean(v.engine, isBugatti ? 'MOTOR W16' : (isTiggo ? '2.0L TGDI TURBO (261 HP)' : '2.0L TURBO ENGINE')),
      horsepower: clean(v.horsepower, isBugatti ? '1500 CV' : (isTiggo ? '261 CV' : '250 HP')),
      topSpeed: clean(v.topSpeed, isBugatti ? '420 KM/H' : (isTiggo ? '205 KM/H' : '220 KM/H')),
      acceleration: clean(v.acceleration, isBugatti ? '0-100 IN 2.5S' : (isTiggo ? '0-100 IN 7.5S' : '0-100 IN 6.5S')),
      tagline: clean(v.tagline, 'PREMIUM LUXURY RENTAL'),
      imageUrl: cleanNullable(v.imageUrl) ?? (isTiggo ? 'assets/images/tiggo9_banner.png' : null),
      customBadge: cleanNullable(v.customBadge),
      seats: v.seats > 0 ? v.seats : 5,
      year: v.year > 0 ? v.year : 2025,
      dailyCents: v.dailyCents > 0 ? v.dailyCents : 5500,
      designHighlights: cleanHighlights.isNotEmpty
          ? cleanHighlights
          : const [
              'CARROCERIA EM FIBRA DE CARBONO',
              '2 LINHA CENTRAL ICÔNICA',
              'FARÓIS DE LED PERSONALIZADOS',
            ],
      quickFacts: cleanFacts.isNotEmpty
          ? cleanFacts
          : const [
              'PREÇO COMPETITIVO DE MERCADO',
              'UNIQUE: 100% INSPECIONADO',
              'LUXO SOB MEDIDA',
            ],
    );
  }

  void _initDefaults() {
    vehicles = [
      tiggo9Vehicle,
      Vehicle(
        'v0',
        'Bugatti La Voiture Noire',
        '1-BUGATTI',
        'Hypercar',
        95000,
        purchasePrice: 11000000,
        year: 2024,
        seats: 2,
        transmission: 'Dual-Clutch 7-Speed',
        fuel: 'Petrol W16 Quad-Turbo',
        imageUrl: 'https://images.unsplash.com/photo-1617788138017-80ad40651399?w=1200&q=80',
        brand: 'BUGATTI',
        tagline: 'A OBRA-PRIMA EXCLUSIVA',
        engine: 'MOTOR W16',
        horsepower: '1500 CV',
        topSpeed: '420 KM/H',
        acceleration: '0-100 EM 2,5S',
        designHighlights: const [
          'CARROCERIA EM FIBRA DE CARBONO',
          '2 LINHA CENTRAL ICÔNICA',
          'FARÓIS DE LED PERSONALIZADOS',
        ],
        quickFacts: const [
          'PREÇO: €11 MILHÕES',
          'UNIQUE: 1 DE 1 UNIDADE',
          'LUXO SOB MEDIDA',
        ],
        features: ['Full Carbon Monocoque', 'Active Aero Wing', 'Hand-Stitched Leather', 'Bespoke Exhaust System'],
        rating: 5.0,
        tripsCount: 12,
      ),
      Vehicle(
        'v1',
        'Toyota Camry',
        '2AB-1234',
        'Car',
        4500,
        purchasePrice: 28500,
        year: 2022,
        seats: 5,
        transmission: 'Automatic',
        fuel: 'Petrol',
        imageUrl: 'https://images.unsplash.com/photo-1621007947382-bb3c3994e3fb?w=1200&q=80',
        brand: 'TOYOTA',
        tagline: 'A OBRA-PRIMA EXCLUSIVA',
        engine: 'MOTOR 2.5L DYNAMIC',
        horsepower: '208 CV',
        topSpeed: '210 KM/H',
        acceleration: '0-100 EM 7,4S',
        designHighlights: const [
          'CARROCERIA EM FIBRA DE CARBONO',
          '2 LINHA CENTRAL ICÔNICA',
          'FARÓIS DE LED PERSONALIZADOS',
        ],
        quickFacts: const [
          'PREÇO: \$28,500',
          'UNIQUE: 100% INSPECIONADO',
          'LUXO SOB MEDIDA',
        ],
        features: ['Apple CarPlay', 'Lane Assist', 'Adaptive Cruise', 'Backup Cam'],
        rating: 4.95,
        tripsCount: 68,
      ),
      Vehicle(
        'v2',
        'Toyota Fortuner',
        '2CD-5678',
        'SUV',
        6500,
        purchasePrice: 42000,
        year: 2021,
        seats: 7,
        transmission: 'Automatic',
        fuel: 'Diesel',
        imageUrl: 'https://images.unsplash.com/photo-1533473359331-0135ef1b58bf?w=1200&q=80',
        brand: 'TOYOTA',
        tagline: 'FORÇA & ROBUSTEZ OFF-ROAD',
        engine: 'MOTOR 2.8L TURBODIESEL',
        horsepower: '204 CV',
        topSpeed: '185 KM/H',
        acceleration: '0-100 EM 9,8S',
        designHighlights: const [
          'CHASSI REFORÇADO OFF-ROAD',
          'GRADE FRONTAL IMPONENTE',
          'FARÓIS BI-BEAM LED',
        ],
        quickFacts: const [
          'PREÇO: \$42,000',
          'TRAÇÃO 4X4 INTEGRAL',
          '7 LUGARES RECLINÁVEIS',
        ],
        features: ['Panoramic Sunroof', 'All-Wheel Drive', '7 Seats', 'Heated Seats'],
        rating: 4.89,
        tripsCount: 45,
      ),
      Vehicle(
        'v3',
        'Honda Civic',
        '3EV-9901',
        'Car',
        4000,
        purchasePrice: 26000,
        year: 2022,
        seats: 5,
        transmission: 'Automatic',
        fuel: 'Petrol',
        imageUrl: 'https://images.unsplash.com/photo-1606016159991-dfe4f2746ad5?w=1200&q=80',
        brand: 'HONDA',
        tagline: 'DESIGN ESPORTIVO & DINÂMICA',
        engine: 'MOTOR 1.5L VTEC TURBO',
        horsepower: '182 CV',
        topSpeed: '220 KM/H',
        acceleration: '0-100 EM 7,8S',
        designHighlights: const [
          'SILHUETA FASTBACK ESPORTIVA',
          'ESCAPE DUPLO CROMADO',
          'FARÓIS FULL LED MATRIX',
        ],
        quickFacts: const [
          'PREÇO: \$26,000',
          'PAINEL DIGITAL 10.2"',
          'SISTEMA HONDA SENSING',
        ],
        features: ['Turbocharged', 'Sport Trim', 'Touchscreen Infotainment', 'Digital Cockpit'],
        rating: 4.92,
        tripsCount: 78,
      ),
      Vehicle(
        'v4',
        'Toyota Land Cruiser',
        '2GH-3456',
        'SUV',
        9500,
        purchasePrice: 68000,
        year: 2021,
        maintenance: true,
        seats: 7,
        transmission: 'Automatic',
        fuel: 'Diesel',
        imageUrl: 'https://images.unsplash.com/photo-1594502184342-2e12f877aa73?w=1200&q=80',
        brand: 'TOYOTA',
        tagline: 'O ÍCONE SUPREMO DO LUXO 4X4',
        engine: 'MOTOR 3.3L V6 TWIN-TURBO',
        horsepower: '309 CV',
        topSpeed: '210 KM/H',
        acceleration: '0-100 EM 6,7S',
        designHighlights: const [
          'BLINDAGEM & CHASSI TNGA-F',
          'SUSPENSÃO E-KDSS ADAPTATIVA',
          'ASSINATURA DE LED TRIDIMENSIONAL',
        ],
        quickFacts: const [
          'PREÇO: \$68,000',
          'CRAWL CONTROL MULTI-TERRAIN',
          'ÁUDIO PREMIUM JBL 14 AUTO-FALANTES',
        ],
        features: ['4x4 Crawl Control', 'Premium Leather', 'JBL Audio', 'Cool Box'],
        rating: 4.99,
        tripsCount: 38,
      ),
      Vehicle(
        'v5',
        'Tesla Model 3',
        '1EF-9012',
        'Electric',
        7500,
        purchasePrice: 38900,
        year: 2024,
        seats: 5,
        transmission: 'Automatic',
        fuel: 'Electric',
        imageUrl: 'https://images.unsplash.com/photo-1560958089-b8a1929cea89?w=1200&q=80',
        brand: 'TESLA',
        tagline: 'PERFORMANCE 100% ELÉTRICA',
        engine: 'DUAL MOTOR ALL-WHEEL DRIVE',
        horsepower: '450 CV',
        topSpeed: '261 KM/H',
        acceleration: '0-100 EM 3,1S',
        designHighlights: const [
          'COEFICIENTE AERODINÂMICO 0.219',
          'TETO PANORÂMICO DE VIDRO TOTAL',
          'FARÓIS ADAPTATIVOS MATRIX',
        ],
        quickFacts: const [
          'PREÇO: \$38,900',
          'PILOTO AUTOMÁTICO INTEGRADO',
          'SUPERCHARGING ULTRA-RÁPIDO',
        ],
        features: ['Autopilot', 'Supercharging Access', 'Glass Roof', 'Premium Audio'],
        rating: 4.97,
        tripsCount: 114,
      ),
      Vehicle(
        'v6',
        'BMW 4 Series',
        '2JK-8822',
        'Luxury',
        8500,
        purchasePrice: 48000,
        year: 2024,
        seats: 5,
        transmission: 'Automatic',
        fuel: 'Petrol',
        imageUrl: 'https://images.unsplash.com/photo-1555215695-3004980ad54e?w=1200&q=80',
        brand: 'BMW',
        tagline: 'ELEGÂNCIA PURA & PERFORMANCE M',
        engine: 'MOTOR 3.0L TWINPOWER TURBO',
        horsepower: '382 CV',
        topSpeed: '250 KM/H',
        acceleration: '0-100 EM 4,5S',
        designHighlights: const [
          'GRADE DUPLO RIM VERTICAL M',
          'LINHA DE TETO COUPÉ AERODINÂMICA',
          'FARÓIS BMW LASERLIGHT',
        ],
        quickFacts: const [
          'PREÇO: \$48,000',
          'HEAD-UP DISPLAY COLORIDO',
          'SOM HARMAN KARDON SURROUND',
        ],
        features: ['M Sport Package', 'Harman Kardon', 'Head-Up Display', 'Ambient Lighting'],
        rating: 4.99,
        tripsCount: 56,
      ),
    ];

    customers = [
      Customer('c1', 'Ayesha Khan', '+92 300 1234567', email: 'ayesha.khan@example.com'),
      Customer('c2', 'Usman Tariq', '+92 321 7654321', email: 'usman.tariq@example.com'),
      Customer('c3', 'Sara Ahmed', '+92 333 8889990', email: 'sara.ahmed@example.com'),
    ];

    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    rentals = [
      Rental(
        'R-DEMO',
        'v1',
        'c1',
        today,
        today.add(const Duration(days: 2)),
        4500,
        paidCents: 4500,
        notes: 'VIP Concierge rental and airport handover.',
      ),
    ];
    _initDefaultBanners();
    categories = ['All', 'SUV', 'Hypercar', 'Car', 'Electric', 'Luxury', 'Sports', 'Concept'];
    agencyConfig = AgencyConfig();
  }

  String newId(String prefix) => '$prefix-${DateTime.now().microsecondsSinceEpoch}';

  Vehicle vehicle(String id) =>
      vehicles.firstWhere((v) => v.id == id, orElse: () => vehicles.first);

  Customer customer(String id) =>
      customers.firstWhere((c) => c.id == id, orElse: () => customers.first);

  bool available(Vehicle v, DateTime from, DateTime to) =>
      !v.maintenance &&
      !rentals.any((r) =>
          r.vehicleId == v.id &&
          (r.overlaps(from, to) || r.status(DateTime.now()) == 'Overdue'));

  String vehicleStatus(Vehicle v) {
    if (v.maintenance) return 'Maintenance';
    if (rentals.any((r) =>
        r.vehicleId == v.id && ['Active', 'Overdue'].contains(r.status(DateTime.now())))) {
      return 'Rented';
    }
    return 'Available';
  }

  int get availableCount =>
      vehicles.where((v) => vehicleStatus(v) == 'Available').length;

  int get activeRentalsCount =>
      rentals.where((r) => ['Active', 'Overdue'].contains(r.status(DateTime.now()))).length;

  int get totalCollectedCents =>
      rentals.fold<int>(0, (sum, r) => sum + r.paidCents);

  int get totalDueCents =>
      rentals.fold<int>(0, (sum, r) => sum + r.balanceCents);

  Future<void> addVehicle(Vehicle v) async {
    final safeV = sanitizeVehicle(v);
    await commit(() {
      vehicles.insert(0, safeV);
      if (!categories.contains(safeV.type)) {
        categories.add(safeV.type);
      }
    });
    if (backendConnected) {
      unawaited(api.saveVehicle(safeV));
    }
  }

  Future<void> updateVehicle(Vehicle v) async {
    final safeV = sanitizeVehicle(v);
    await commit(() {
      final index = vehicles.indexWhere((x) => x.id == safeV.id);
      if (index != -1) {
        vehicles[index] = safeV;
      }
      if (!categories.contains(safeV.type)) {
        categories.add(safeV.type);
      }
    });
    if (backendConnected) {
      unawaited(api.saveVehicle(safeV));
    }
  }

  Future<void> deleteVehicle(String id) async {
    await commit(() {
      vehicles.removeWhere((x) => x.id == id);
      banners.removeWhere((b) => b.vehicleId == id);
    });
    if (backendConnected) {
      unawaited(api.deleteVehicle(id));
    }
  }

  Future<void> addBanner(BannerItem b) async {
    await commit(() {
      banners.insert(0, b);
    });
    if (backendConnected) {
      unawaited(api.saveBanner(b));
    }
  }

  Future<void> updateBanner(BannerItem b) async {
    await commit(() {
      final index = banners.indexWhere((x) => x.id == b.id);
      if (index != -1) {
        banners[index] = b;
      }
    });
    if (backendConnected) {
      unawaited(api.saveBanner(b));
    }
  }

  Future<void> deleteBanner(String id) async {
    await commit(() {
      banners.removeWhere((x) => x.id == id);
    });
    if (backendConnected) {
      unawaited(api.deleteBanner(id));
    }
  }

  Future<void> toggleBannerActive(String id) async {
    BannerItem? updatedBanner;
    await commit(() {
      final index = banners.indexWhere((x) => x.id == id);
      if (index != -1) {
        final b = banners[index];
        final toggled = BannerItem(
          id: b.id,
          tagline: b.tagline,
          title: b.title,
          subtitle: b.subtitle,
          vehicleId: b.vehicleId,
          imageUrl: b.imageUrl,
          priceText: b.priceText,
          specChips: b.specChips,
          badgeText: b.badgeText,
          badgeColorValue: b.badgeColorValue,
          active: !b.active,
        );
        banners[index] = toggled;
        updatedBanner = toggled;
      }
    });
    if (backendConnected && updatedBanner != null) {
      unawaited(api.saveBanner(updatedBanner!));
    }
  }

  Future<void> addCategory(String cat) async {
    final clean = cat.trim();
    if (clean.isEmpty || categories.contains(clean)) return;
    await commit(() {
      categories.add(clean);
    });
  }

  Future<void> deleteCategory(String cat) async {
    if (cat == 'All') return;
    await commit(() {
      categories.remove(cat);
    });
  }

  Future<void> addCustomer(Customer c) async {
    await commit(() {
      customers.insert(0, c);
    });
    if (backendConnected) {
      unawaited(api.saveCustomer(c));
    }
  }

  Future<void> updateCustomer(Customer c) async {
    await commit(() {
      final index = customers.indexWhere((x) => x.id == c.id);
      if (index != -1) {
        customers[index] = c;
      }
    });
    if (backendConnected) {
      unawaited(api.saveCustomer(c));
    }
  }

  Future<void> deleteCustomer(String id) async {
    await commit(() {
      customers.removeWhere((x) => x.id == id);
    });
  }

  Future<void> addRental(Rental r) async {
    await commit(() {
      rentals.insert(0, r);
    });
    if (backendConnected) {
      unawaited(api.saveRental(r));
    }
  }

  Future<void> updateRental(Rental r) async {
    await commit(() {
      final index = rentals.indexWhere((x) => x.id == r.id);
      if (index != -1) {
        rentals[index] = r;
      }
    });
    if (backendConnected) {
      unawaited(api.saveRental(r));
    }
  }

  Future<void> deleteRental(String id) async {
    await commit(() {
      rentals.removeWhere((x) => x.id == id);
    });
  }

  Future<void> returnRentalVehicle(String rentalId, {String? notes}) async {
    Rental? updated;
    await commit(() {
      final index = rentals.indexWhere((x) => x.id == rentalId);
      if (index != -1) {
        final r = rentals[index];
        final updatedNotes = (notes != null && notes.trim().isNotEmpty)
            ? (r.notes.isNotEmpty ? '${r.notes}\n$notes' : notes.trim())
            : r.notes;
        rentals[index] = r.copyWith(
          returned: true,
          notes: updatedNotes,
        );
        updated = rentals[index];
      }
    });
    if (backendConnected && updated != null) {
      unawaited(api.saveRental(updated!));
    }
  }

  Future<void> recordRentalPayment(String rentalId, int amountCents, {String? notes}) async {
    Rental? updated;
    await commit(() {
      final index = rentals.indexWhere((x) => x.id == rentalId);
      if (index != -1) {
        final r = rentals[index];
        final newPaid = (r.paidCents + amountCents).clamp(0, r.totalCents);
        final updatedNotes = (notes != null && notes.trim().isNotEmpty)
            ? (r.notes.isNotEmpty ? '${r.notes}\n$notes' : notes.trim())
            : r.notes;
        rentals[index] = r.copyWith(
          paidCents: newPaid,
          notes: updatedNotes,
        );
        updated = rentals[index];
      }
    });
    if (backendConnected && updated != null) {
      unawaited(api.saveRental(updated!));
    }
  }

  Future<void> updateRentalPayment(String rentalId, int newPaidCents, {String? notes}) async {
    Rental? updated;
    await commit(() {
      final index = rentals.indexWhere((x) => x.id == rentalId);
      if (index != -1) {
        final r = rentals[index];
        final val = newPaidCents.clamp(0, r.totalCents);
        rentals[index] = r.copyWith(
          paidCents: val,
          notes: notes ?? r.notes,
        );
        updated = rentals[index];
      }
    });
    if (backendConnected && updated != null) {
      unawaited(api.saveRental(updated!));
    }
  }

  Future<void> settleRentalPayment(String rentalId, {String? notes}) async {
    Rental? updated;
    await commit(() {
      final index = rentals.indexWhere((x) => x.id == rentalId);
      if (index != -1) {
        final r = rentals[index];
        final updatedNotes = (notes != null && notes.trim().isNotEmpty)
            ? (r.notes.isNotEmpty ? '${r.notes}\n$notes' : notes.trim())
            : r.notes;
        rentals[index] = r.copyWith(
          paidCents: r.totalCents,
          notes: updatedNotes,
        );
        updated = rentals[index];
      }
    });
    if (backendConnected && updated != null) {
      unawaited(api.saveRental(updated!));
    }
  }

  Future<void> resetRentalPayment(String rentalId) async {
    Rental? updated;
    await commit(() {
      final index = rentals.indexWhere((x) => x.id == rentalId);
      if (index != -1) {
        final r = rentals[index];
        rentals[index] = r.copyWith(paidCents: 0);
        updated = rentals[index];
      }
    });
    if (backendConnected && updated != null) {
      unawaited(api.saveRental(updated!));
    }
  }

  int get returnedRentalsCount => rentals.where((r) => r.returned).length;
  int get upcomingRentalsCount => rentals.where((r) => r.status(DateTime.now()) == 'Upcoming').length;
  int get overdueRentalsCount => rentals.where((r) => r.status(DateTime.now()) == 'Overdue').length;
  int get balanceDueRentalsCount => rentals.where((r) => r.balanceCents > 0).length;
  int get totalRentalBilledCents => rentals.fold<int>(0, (sum, r) => sum + r.totalCents);
  int get totalRentalRevenueCents => rentals.fold<int>(0, (sum, r) => sum + r.paidCents);
  int get totalRentalReceivablesCents => rentals.fold<int>(0, (sum, r) => sum + r.balanceCents);
  int get fullyPaidRentalsCount => rentals.where((r) => r.balanceCents <= 0).length;
  int get partialPaidRentalsCount => rentals.where((r) => r.paidCents > 0 && r.balanceCents > 0).length;
  int get unpaidRentalsCount => rentals.where((r) => r.paidCents == 0).length;

  List<Rental> rentalsForCustomer(String customerId) =>
      rentals.where((r) => r.customerId == customerId).toList();

  int customerTotalSpend(String customerId) =>
      rentalsForCustomer(customerId).fold<int>(0, (sum, r) => sum + r.paidCents);

  int customerActiveRentals(String customerId) {
    final now = DateTime.now();
    return rentalsForCustomer(customerId).where((r) {
      final s = r.status(now);
      return s == 'Active' || s == 'Upcoming';
    }).length;
  }

  Future<void> updateAgencyConfig(AgencyConfig config) async {
    await commit(() {
      agencyConfig = config;
    });
    if (backendConnected) {
      unawaited(api.saveAgencyConfig(config));
    }
  }

  Future<bool> syncWithBackend() async {
    if (isSyncing) return backendConnected;
    isSyncing = true;
    notifyListeners();

    try {
      final isUp = await api.checkHealth();
      backendConnected = isUp;
      if (!isUp) {
        return false;
      }

      final data = await api.fetchSyncData();
      if (data != null) {
        if (data['vehicles'] is List && (data['vehicles'] as List).isNotEmpty) {
          final backendVehicles = (data['vehicles'] as List)
              .map((v) => Vehicle.fromJson(v as Map<String, dynamic>))
              .map(sanitizeVehicle)
              .toList();
          for (final bv in backendVehicles) {
            final idx = vehicles.indexWhere((v) => v.id == bv.id);
            if (idx >= 0) {
              vehicles[idx] = bv;
            } else {
              vehicles.add(bv);
            }
          }
        }

        if (data['banners'] is List && (data['banners'] as List).isNotEmpty) {
          final backendBanners = (data['banners'] as List)
              .map((b) => BannerItem.fromJson(b as Map<String, dynamic>))
              .toList();
          for (final bb in backendBanners) {
            final idx = banners.indexWhere((b) => b.id == bb.id);
            if (idx >= 0) {
              banners[idx] = bb;
            } else {
              banners.add(bb);
            }
          }
        }

        if (data['customers'] is List && (data['customers'] as List).isNotEmpty) {
          final backendCust = (data['customers'] as List)
              .map((c) => Customer.fromJson(c as Map<String, dynamic>))
              .toList();
          for (final bc in backendCust) {
            final idx = customers.indexWhere((c) => c.id == bc.id);
            if (idx >= 0) {
              customers[idx] = bc;
            } else {
              customers.add(bc);
            }
          }
        }

        if (data['rentals'] is List && (data['rentals'] as List).isNotEmpty) {
          final backendRentals = (data['rentals'] as List)
              .map((r) => Rental.fromJson(r as Map<String, dynamic>))
              .toList();
          for (final br in backendRentals) {
            final idx = rentals.indexWhere((r) => r.id == br.id);
            if (idx >= 0) {
              rentals[idx] = br;
            } else {
              rentals.add(br);
            }
          }
        }

        if (data['agencyConfig'] != null && data['agencyConfig'] is Map<String, dynamic>) {
          agencyConfig = AgencyConfig.fromJson(data['agencyConfig'] as Map<String, dynamic>);
        }

        await prefs.setString('driveline_v5', encode());
      }
    } catch (e) {
      debugPrint('[RentalStore] syncWithBackend error: $e');
      backendConnected = false;
    } finally {
      isSyncing = false;
      notifyListeners();
    }
    return backendConnected;
  }

  Future<void> commit(void Function() change) async {
    final backup = encode();
    change();
    try {
      if (!await prefs.setString('driveline_v5', encode())) {
        throw Exception('Storage rejected the change');
      }
    } catch (_) {
      final j = jsonDecode(backup) as Map<String, dynamic>;
      vehicles = (j['vehicles'] as List).map((v) => Vehicle.fromJson(v as Map<String, dynamic>)).toList();
      customers = (j['customers'] as List).map((v) => Customer.fromJson(v as Map<String, dynamic>)).toList();
      rentals = (j['rentals'] as List).map((v) => Rental.fromJson(v as Map<String, dynamic>)).toList();
      if (j['banners'] != null) {
        banners = (j['banners'] as List).map((b) => BannerItem.fromJson(b as Map<String, dynamic>)).toList();
      }
      if (j['categories'] != null) {
        categories = (j['categories'] as List).map((c) => c.toString()).toList();
      }
      if (j['agencyConfig'] != null) {
        agencyConfig = AgencyConfig.fromJson(j['agencyConfig'] as Map<String, dynamic>);
      }
      rethrow;
    }
    notifyListeners();
  }

  String encode() => jsonEncode({
        'vehicles': vehicles.map((v) => v.toJson()).toList(),
        'customers': customers.map((c) => c.toJson()).toList(),
        'rentals': rentals.map((r) => r.toJson()).toList(),
        'banners': banners.map((b) => b.toJson()).toList(),
        'categories': categories,
        'agencyConfig': agencyConfig.toJson(),
      });

  void setLanguage(AppLanguage lang) {
    language = lang;
    prefs.setString('driveline_lang', lang.code);
    notifyListeners();
  }

  String t(String key) => AppTranslations.tr(key, language);
}

