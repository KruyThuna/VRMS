import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/vehicle.dart';
import '../models/customer.dart';
import '../models/rental.dart';
import '../models/banner_item.dart';
import '../models/agency_config.dart';

class StorageService {
  final SharedPreferences prefs;
  static const String currentStorageVersionKey = 'driveline_v5';

  StorageService(this.prefs);

  Future<void> saveDataset({
    required List<Vehicle> vehicles,
    required List<Customer> customers,
    required List<Rental> rentals,
    required List<BannerItem> banners,
    required List<String> categories,
    required AgencyConfig agencyConfig,
  }) async {
    final map = {
      'vehicles': vehicles.map((v) => v.toJson()).toList(),
      'customers': customers.map((c) => c.toJson()).toList(),
      'rentals': rentals.map((r) => r.toJson()).toList(),
      'banners': banners.map((b) => b.toJson()).toList(),
      'categories': categories,
      'agencyConfig': agencyConfig.toJson(),
    };
    await prefs.setString(currentStorageVersionKey, jsonEncode(map));
  }

  Map<String, dynamic>? loadDataset() {
    final raw = prefs.getString(currentStorageVersionKey) ??
        prefs.getString('driveline_v4') ??
        prefs.getString('driveline_v3') ??
        prefs.getString('driveline_v2');
    if (raw == null) return null;
    try {
      return jsonDecode(raw) as Map<String, dynamic>;
    } catch (_) {
      return null;
    }
  }

  Future<void> clearAllData() async {
    await prefs.remove(currentStorageVersionKey);
  }
}

