class AgencyConfig {
  final String companyName;
  final String companySlogan;
  final String phone;
  final String email;
  final String address;
  final String? logoUrl;

  AgencyConfig({
    this.companyName = 'DriveLine',
    this.companySlogan = 'CAR RENTAL',
    this.phone = '+92 300 1234567',
    this.email = 'info@driveline.pk',
    this.address = 'Lahore, Pakistan',
    this.logoUrl,
  });

  Map<String, dynamic> toJson() => {
        'companyName': companyName,
        'companySlogan': companySlogan,
        'phone': phone,
        'email': email,
        'address': address,
        'logoUrl': logoUrl,
      };

  factory AgencyConfig.fromJson(Map<String, dynamic> j) {
    final rawSlogan = j['companySlogan'] as String?;
    final resolvedSlogan = (rawSlogan == null || rawSlogan == 'CAR AGENCY')
        ? 'CAR RENTAL'
        : rawSlogan;

    return AgencyConfig(
      companyName: j['companyName'] as String? ?? 'DriveLine',
      companySlogan: resolvedSlogan,
      phone: j['phone'] as String? ?? '+92 300 1234567',
      email: j['email'] as String? ?? 'info@driveline.pk',
      address: j['address'] as String? ?? 'Lahore, Pakistan',
      logoUrl: j['logoUrl'] as String?,
    );
  }
}

