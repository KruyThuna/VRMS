import '../models/vehicle.dart';
import '../models/rental.dart';

class BookingService {
  static bool isVehicleAvailable(Vehicle vehicle, List<Rental> rentals, DateTime from, DateTime to) {
    if (vehicle.maintenance) return false;
    for (final r in rentals) {
      if (r.vehicleId == vehicle.id && r.overlaps(from, to)) {
        return false;
      }
    }
    return true;
  }

  static int calculateTotalCents(List<Vehicle> items, int days, {int voucherDiscountCents = 0}) {
    int subtotal = 0;
    for (final v in items) {
      subtotal += v.dailyCents * days;
    }
    final total = subtotal - voucherDiscountCents;
    return total > 0 ? total : 0;
  }

  static int calculateVoucherDiscount(String voucherCode, int rawSubtotal) {
    final code = voucherCode.trim().toUpperCase();
    if (code == 'VIP10') {
      return (rawSubtotal * 0.10).round();
    } else if (code == 'TIGGO9' || code == 'DRIVELINE') {
      return (rawSubtotal * 0.15).round();
    } else if (code == 'SUPER50') {
      return 5000; // $50.00 off
    }
    return 0;
  }
}

