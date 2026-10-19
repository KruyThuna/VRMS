class Customer {
  final String id, name, phone, email;
  final String licenseNumber;
  final String address;
  final String notes;

  Customer(
    this.id,
    this.name,
    this.phone, {
    this.email = '',
    this.licenseNumber = '',
    this.address = '',
    this.notes = '',
  });

  Customer copyWith({
    String? id,
    String? name,
    String? phone,
    String? email,
    String? licenseNumber,
    String? address,
    String? notes,
  }) =>
      Customer(
        id ?? this.id,
        name ?? this.name,
        phone ?? this.phone,
        email: email ?? this.email,
        licenseNumber: licenseNumber ?? this.licenseNumber,
        address: address ?? this.address,
        notes: notes ?? this.notes,
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'phone': phone,
        'email': email,
        'licenseNumber': licenseNumber,
        'address': address,
        'notes': notes,
      };

  factory Customer.fromJson(Map<String, dynamic> j) => Customer(
        j['id'] as String,
        j['name'] as String,
        j['phone'] as String,
        email: j['email'] as String? ?? '',
        licenseNumber: j['licenseNumber'] as String? ?? '',
        address: j['address'] as String? ?? '',
        notes: j['notes'] as String? ?? '',
      );
}
