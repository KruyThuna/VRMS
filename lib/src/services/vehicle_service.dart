import '../models/vehicle.dart';

class VehicleService {
  static List<Vehicle> filterVehicles({
    required List<Vehicle> vehicles,
    required String selectedCategory,
    String searchQuery = '',
  }) {
    return vehicles.where((v) {
      final matchesCategory = selectedCategory == 'All' ||
          v.type.toLowerCase() == selectedCategory.toLowerCase();
      final query = searchQuery.trim().toLowerCase();
      final matchesSearch = query.isEmpty ||
          v.name.toLowerCase().contains(query) ||
          v.brand.toLowerCase().contains(query) ||
          v.type.toLowerCase().contains(query);
      return matchesCategory && matchesSearch;
    }).toList();
  }

  static List<Vehicle> getFeaturedVehicles(List<Vehicle> vehicles) {
    return vehicles.where((v) => v.isFeatured && !v.maintenance).toList();
  }
}

