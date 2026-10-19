class Vehicle {
  final String id, name, plate, type;
  final int dailyCents;
  final int purchasePrice;
  final int year;
  bool maintenance;
  final int seats;
  final String transmission;
  final String fuel;
  final List<String> features;
  final double rating;
  final int tripsCount;
  final String? imageUrl;
  final bool isFeatured;
  final String? customBadge;

  // High-Tech Cyber Showcase Attributes
  final String brand;
  final String tagline;
  final String engine;
  final String horsepower;
  final String topSpeed;
  final String acceleration;
  final List<String> designHighlights;
  final List<String> quickFacts;

  Vehicle(
    this.id,
    this.name,
    this.plate,
    this.type,
    this.dailyCents, {
    this.purchasePrice = 28500,
    this.year = 2024,
    this.maintenance = false,
    this.seats = 5,
    this.transmission = 'Automatic',
    this.fuel = 'Petrol',
    this.features = const ['Bluetooth', 'Air Conditioning', 'Backup Cam', 'Apple CarPlay'],
    this.rating = 4.9,
    this.tripsCount = 24,
    this.imageUrl,
    this.isFeatured = false,
    this.customBadge,
    this.brand = 'DRIVELINE',
    this.tagline = 'A OBRA-PRIMA EXCLUSIVA',
    this.engine = 'MOTOR V6 TURBO',
    this.horsepower = '300 CV',
    this.topSpeed = '250 KM/H',
    this.acceleration = '0-100 EM 5,2S',
    this.designHighlights = const [
      'CARROCERIA EM FIBRA DE CARBONO',
      '2 LINHA CENTRAL ICÔNICA',
      'FARÓIS DE LED PERSONALIZADOS',
    ],
    this.quickFacts = const [
      'PREÇO COMPETITIVO DE MERCADO',
      'UNIQUE: 100% INSPECIONADO',
      'LUXO SOB MEDIDA',
    ],
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'plate': plate,
        'type': type,
        'rate': dailyCents,
        'purchasePrice': purchasePrice,
        'year': year,
        'maintenance': maintenance,
        'seats': seats,
        'transmission': transmission,
        'fuel': fuel,
        'features': features,
        'rating': rating,
        'tripsCount': tripsCount,
        'imageUrl': imageUrl,
        'isFeatured': isFeatured,
        'customBadge': customBadge,
        'brand': brand,
        'tagline': tagline,
        'engine': engine,
        'horsepower': horsepower,
        'topSpeed': topSpeed,
        'acceleration': acceleration,
        'designHighlights': designHighlights,
        'quickFacts': quickFacts,
        'dailyCents': dailyCents,
      };

  static String _cleanStr(dynamic val, String fallback) {
    if (val == null) return fallback;
    final s = val.toString().trim();
    if (s.isEmpty || s.toLowerCase() == 'null') return fallback;
    return s;
  }

  static String? _cleanNullableStr(dynamic val) {
    if (val == null) return null;
    final s = val.toString().trim();
    if (s.isEmpty || s.toLowerCase() == 'null') return null;
    return s;
  }

  factory Vehicle.fromJson(Map<String, dynamic> j) {
    final type = _cleanStr(j['type'], 'Car');
    final rawName = _cleanStr(j['name'], 'Vehicle');

    final defaultEngine = (rawName == 'Bugatti La Voiture Noire')
        ? 'MOTOR W16'
        : '2.0L TURBO ENGINE';
    final defaultHp = (rawName == 'Bugatti La Voiture Noire')
        ? '1500 CV'
        : '250 HP';
    final defaultSpeed = (rawName == 'Bugatti La Voiture Noire')
        ? '420 KM/H'
        : '220 KM/H';
    final defaultAccel = (rawName == 'Bugatti La Voiture Noire')
        ? '0-100 IN 2.5S'
        : '0-100 IN 6.5S';

    final defaultSeats = type == 'Motorbike' ? 2 : (type == 'SUV' ? 7 : (type == 'Pickup' ? 5 : 5));
    final defaultFuel = type == 'Motorbike' ? 'Petrol' : (type == 'Electric' ? 'Electric' : 'Petrol');

    return Vehicle(
      _cleanStr(j['id'], 'V-${DateTime.now().millisecondsSinceEpoch}'),
      rawName,
      _cleanStr(j['plate'] ?? j['plateNumber'], '1-AUTO'),
      type,
      (j['rate'] as num?)?.toInt() ?? (j['dailyCents'] as num?)?.toInt() ?? 5500,
      purchasePrice: (j['purchasePrice'] as num?)?.toInt() ?? 28500,
      year: (j['year'] as num?)?.toInt() ?? 2024,
      maintenance: j['maintenance'] as bool? ?? false,
      seats: (j['seats'] as num?)?.toInt() ?? defaultSeats,
      transmission: _cleanStr(j['transmission'], 'Automatic'),
      fuel: _cleanStr(j['fuel'], defaultFuel),
      features: (j['features'] as List?)
              ?.map((e) => e?.toString() ?? '')
              .where((s) => s.trim().isNotEmpty && s.trim().toLowerCase() != 'null')
              .toList() ??
          const ['Bluetooth', 'Air Conditioning', 'Backup Cam', 'Apple CarPlay'],
      rating: (j['rating'] as num?)?.toDouble() ?? 4.9,
      tripsCount: (j['tripsCount'] as num?)?.toInt() ?? 24,
      imageUrl: _cleanNullableStr(j['imageUrl']),
      isFeatured: j['isFeatured'] as bool? ?? false,
      customBadge: _cleanNullableStr(j['customBadge']),
      brand: _cleanStr(j['brand'], 'DRIVELINE'),
      tagline: _cleanStr(j['tagline'], 'A OBRA-PRIMA EXCLUSIVA'),
      engine: _cleanStr(j['engine'], defaultEngine),
      horsepower: _cleanStr(j['horsepower'], defaultHp),
      topSpeed: _cleanStr(j['topSpeed'], defaultSpeed),
      acceleration: _cleanStr(j['acceleration'], defaultAccel),
      designHighlights: (j['designHighlights'] as List?)
              ?.map((e) => e?.toString() ?? '')
              .where((s) => s.trim().isNotEmpty && s.trim().toLowerCase() != 'null')
              .toList() ??
          const [
            'CARROCERIA EM FIBRA DE CARBONO',
            '2 LINHA CENTRAL ICÔNICA',
            'FARÓIS DE LED PERSONALIZADOS',
          ],
      quickFacts: (j['quickFacts'] as List?)
              ?.map((e) => e?.toString() ?? '')
              .where((s) => s.trim().isNotEmpty && s.trim().toLowerCase() != 'null')
              .toList() ??
          const [
            'PREÇO COMPETITIVO DE MERCADO',
            'UNIQUE: 100% INSPECIONADO',
            'LUXO SOB MEDIDA',
          ],
    );
  }

  Vehicle copyWith({
    String? id,
    String? name,
    String? plate,
    String? type,
    int? dailyCents,
    int? purchasePrice,
    int? year,
    bool? maintenance,
    int? seats,
    String? transmission,
    String? fuel,
    List<String>? features,
    double? rating,
    int? tripsCount,
    String? imageUrl,
    bool? isFeatured,
    String? customBadge,
    String? brand,
    String? tagline,
    String? engine,
    String? horsepower,
    String? topSpeed,
    String? acceleration,
    List<String>? designHighlights,
    List<String>? quickFacts,
  }) {
    return Vehicle(
      id ?? this.id,
      name ?? this.name,
      plate ?? this.plate,
      type ?? this.type,
      dailyCents ?? this.dailyCents,
      purchasePrice: purchasePrice ?? this.purchasePrice,
      year: year ?? this.year,
      maintenance: maintenance ?? this.maintenance,
      seats: seats ?? this.seats,
      transmission: transmission ?? this.transmission,
      fuel: fuel ?? this.fuel,
      features: features ?? this.features,
      rating: rating ?? this.rating,
      tripsCount: tripsCount ?? this.tripsCount,
      imageUrl: imageUrl ?? this.imageUrl,
      isFeatured: isFeatured ?? this.isFeatured,
      customBadge: customBadge ?? this.customBadge,
      brand: brand ?? this.brand,
      tagline: tagline ?? this.tagline,
      engine: engine ?? this.engine,
      horsepower: horsepower ?? this.horsepower,
      topSpeed: topSpeed ?? this.topSpeed,
      acceleration: acceleration ?? this.acceleration,
      designHighlights: designHighlights ?? this.designHighlights,
      quickFacts: quickFacts ?? this.quickFacts,
    );
  }
}

