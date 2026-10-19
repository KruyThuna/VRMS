class BannerItem {
  final String id;
  final String tagline;
  final String title;
  final String subtitle;
  final String? vehicleId;
  final String? imageUrl;
  final String priceText;
  final List<String> specChips;
  final String badgeText;
  final int badgeColorValue;
  final bool active;

  BannerItem({
    required this.id,
    required this.tagline,
    required this.title,
    required this.subtitle,
    this.vehicleId,
    this.imageUrl,
    this.priceText = '\$55 / DAY • FULL INSURANCE',
    this.specChips = const [
      '2.0L TGDI TURBO · 261 HP',
      '8-SPEED AT · INTELLIGENT AWD',
      'CDC SUSPENSION',
      '7-SEAT LUXURY',
    ],
    this.badgeText = 'ONE STEP AHEAD',
    this.badgeColorValue = 0xFF10B981,
    this.active = true,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'tagline': tagline,
        'title': title,
        'subtitle': subtitle,
        'vehicleId': vehicleId,
        'imageUrl': imageUrl,
        'priceText': priceText,
        'specChips': specChips,
        'badgeText': badgeText,
        'badgeColorValue': badgeColorValue,
        'active': active,
      };

  factory BannerItem.fromJson(Map<String, dynamic> j) {
    var rawPrice = j['priceText'] as String? ?? '\$55 / DAY • FULL INSURANCE';
    if (rawPrice.contains('MSRP')) {
      rawPrice = rawPrice.replaceAll(RegExp(r'•\s*MSRP\s*[\$€]?[\d,]+', caseSensitive: false), '• FULL INSURANCE').trim();
    }
    return BannerItem(
        id: j['id'] as String? ?? 'b1',
        tagline: j['tagline'] as String? ?? 'ONE STEP AHEAD',
        title: j['title'] as String? ?? 'TIGGO 9',
        subtitle: j['subtitle'] as String? ?? 'Chery Flagship Luxury AWD SUV',
        vehicleId: j['vehicleId'] as String?,
        imageUrl: j['imageUrl'] as String?,
        priceText: rawPrice,
        specChips: (j['specChips'] as List?)?.map((e) => e.toString()).toList() ??
            const [
              '2.0L TGDI TURBO · 261 HP',
              '8-SPEED AT · INTELLIGENT AWD',
              'CDC SUSPENSION',
              '7-SEAT LUXURY',
            ],
        badgeText: j['badgeText'] as String? ?? 'ONE STEP AHEAD',
        badgeColorValue: j['badgeColorValue'] as int? ?? 0xFF10B981,
        active: j['active'] as bool? ?? true,
      );
  }

  BannerItem copyWith({
    String? id,
    String? tagline,
    String? title,
    String? subtitle,
    String? vehicleId,
    String? imageUrl,
    String? priceText,
    List<String>? specChips,
    String? badgeText,
    int? badgeColorValue,
    bool? active,
  }) =>
      BannerItem(
        id: id ?? this.id,
        tagline: tagline ?? this.tagline,
        title: title ?? this.title,
        subtitle: subtitle ?? this.subtitle,
        vehicleId: vehicleId ?? this.vehicleId,
        imageUrl: imageUrl ?? this.imageUrl,
        priceText: priceText ?? this.priceText,
        specChips: specChips ?? this.specChips,
        badgeText: badgeText ?? this.badgeText,
        badgeColorValue: badgeColorValue ?? this.badgeColorValue,
        active: active ?? this.active,
      );
}

