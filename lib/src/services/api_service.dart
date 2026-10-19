import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import '../../models.dart';

class ApiService {
  static const String defaultBaseUrl = 'http://localhost:8080/api';
  final String baseUrl;

  const ApiService({this.baseUrl = defaultBaseUrl});

  Future<bool> checkHealth() async {
    try {
      final res = await http
          .get(Uri.parse('$baseUrl/health'))
          .timeout(const Duration(seconds: 3));
      return res.statusCode == 200;
    } catch (_) {
      return false;
    }
  }

  Future<Map<String, dynamic>?> fetchSyncData() async {
    try {
      final res = await http
          .get(Uri.parse('$baseUrl/sync'))
          .timeout(const Duration(seconds: 5));
      if (res.statusCode == 200) {
        return jsonDecode(utf8.decode(res.bodyBytes)) as Map<String, dynamic>;
      }
    } catch (e) {
      debugPrint('[ApiService] fetchSyncData error: $e');
    }
    return null;
  }

  Future<bool> saveVehicle(Vehicle v) async {
    try {
      final res = await http.post(
        Uri.parse('$baseUrl/vehicles'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(v.toJson()),
      ).timeout(const Duration(seconds: 4));
      return res.statusCode >= 200 && res.statusCode < 300;
    } catch (e) {
      debugPrint('[ApiService] saveVehicle error: $e');
      return false;
    }
  }

  Future<bool> deleteVehicle(String id) async {
    try {
      final res = await http
          .delete(Uri.parse('$baseUrl/vehicles/$id'))
          .timeout(const Duration(seconds: 4));
      return res.statusCode >= 200 && res.statusCode < 300;
    } catch (e) {
      debugPrint('[ApiService] deleteVehicle error: $e');
      return false;
    }
  }

  Future<bool> saveBanner(BannerItem b) async {
    try {
      final res = await http.post(
        Uri.parse('$baseUrl/banners'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(b.toJson()),
      ).timeout(const Duration(seconds: 4));
      return res.statusCode >= 200 && res.statusCode < 300;
    } catch (e) {
      debugPrint('[ApiService] saveBanner error: $e');
      return false;
    }
  }

  Future<bool> deleteBanner(String id) async {
    try {
      final res = await http
          .delete(Uri.parse('$baseUrl/banners/$id'))
          .timeout(const Duration(seconds: 4));
      return res.statusCode >= 200 && res.statusCode < 300;
    } catch (e) {
      debugPrint('[ApiService] deleteBanner error: $e');
      return false;
    }
  }

  Future<bool> saveCustomer(Customer c) async {
    try {
      final res = await http.post(
        Uri.parse('$baseUrl/customers'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(c.toJson()),
      ).timeout(const Duration(seconds: 4));
      return res.statusCode >= 200 && res.statusCode < 300;
    } catch (e) {
      debugPrint('[ApiService] saveCustomer error: $e');
      return false;
    }
  }

  Future<bool> saveRental(Rental r) async {
    try {
      final res = await http.post(
        Uri.parse('$baseUrl/rentals'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(r.toJson()),
      ).timeout(const Duration(seconds: 4));
      return res.statusCode >= 200 && res.statusCode < 300;
    } catch (e) {
      debugPrint('[ApiService] saveRental error: $e');
      return false;
    }
  }

  Future<bool> saveAgencyConfig(AgencyConfig cfg) async {
    try {
      final res = await http.put(
        Uri.parse('$baseUrl/agency'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(cfg.toJson()),
      ).timeout(const Duration(seconds: 4));
      return res.statusCode >= 200 && res.statusCode < 300;
    } catch (e) {
      debugPrint('[ApiService] saveAgencyConfig error: $e');
      return false;
    }
  }

  Future<bool> submitInquiry({
    required String name,
    required String phone,
    String? email,
    String? vehicleName,
    String? message,
  }) async {
    try {
      final res = await http.post(
        Uri.parse('$baseUrl/inquiries'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'name': name,
          'phone': phone,
          'email': email ?? '',
          'vehicleName': vehicleName ?? '',
          'message': message ?? '',
        }),
      ).timeout(const Duration(seconds: 4));
      return res.statusCode >= 200 && res.statusCode < 300;
    } catch (e) {
      debugPrint('[ApiService] submitInquiry error: $e');
      return false;
    }
  }
}
