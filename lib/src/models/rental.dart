class Rental {
  final String id, vehicleId, customerId;
  final DateTime start, end;
  final int dailyCents;
  int paidCents;
  bool returned;
  final String notes;

  Rental(
    this.id,
    this.vehicleId,
    this.customerId,
    this.start,
    this.end,
    this.dailyCents, {
    this.paidCents = 0,
    this.returned = false,
    this.notes = '',
  });

  // Dates are inclusive: pickup and return on one calendar day costs one day.
  int get days =>
      DateTime.utc(end.year, end.month, end.day)
          .difference(DateTime.utc(start.year, start.month, start.day))
          .inDays +
      1;

  int get totalCents => days * dailyCents;
  int get balanceCents => totalCents - paidCents;

  bool overlaps(DateTime from, DateTime to) =>
      !returned && !end.isBefore(from) && !start.isAfter(to);

  String status(DateTime now) {
    if (returned) return 'Returned';
    final today = DateTime(now.year, now.month, now.day);
    if (end.isBefore(today)) return 'Overdue';
    if (start.isAfter(today)) return 'Upcoming';
    return 'Active';
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'vehicleId': vehicleId,
        'customerId': customerId,
        'start': start.toIso8601String(),
        'end': end.toIso8601String(),
        'rate': dailyCents,
        'paid': paidCents,
        'returned': returned,
        'notes': notes,
      };

  Rental copyWith({
    String? id,
    String? vehicleId,
    String? customerId,
    DateTime? start,
    DateTime? end,
    int? dailyCents,
    int? paidCents,
    bool? returned,
    String? notes,
  }) {
    return Rental(
      id ?? this.id,
      vehicleId ?? this.vehicleId,
      customerId ?? this.customerId,
      start ?? this.start,
      end ?? this.end,
      dailyCents ?? this.dailyCents,
      paidCents: paidCents ?? this.paidCents,
      returned: returned ?? this.returned,
      notes: notes ?? this.notes,
    );
  }

  factory Rental.fromJson(Map<String, dynamic> j) => Rental(
        j['id'] as String,
        j['vehicleId'] as String,
        j['customerId'] as String,
        DateTime.parse(j['start'] as String),
        DateTime.parse(j['end'] as String),
        j['rate'] as int,
        paidCents: j['paid'] as int? ?? 0,
        returned: j['returned'] as bool? ?? false,
        notes: j['notes'] as String? ?? '',
      );
}

