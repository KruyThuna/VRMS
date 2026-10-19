import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user.dart';
import 'user_role.dart';

class AuthService {
  final SharedPreferences prefs;
  static const String _userKey = 'driveline_auth_user';
  static const String _adminPinKey = 'driveline_admin_pin';
  static const String defaultAdminPin = '1234';

  AuthService(this.prefs);

  String get adminPin => prefs.getString(_adminPinKey) ?? defaultAdminPin;

  Future<bool> setAdminPin(String newPin) async {
    if (newPin.trim().length < 4) return false;
    return await prefs.setString(_adminPinKey, newPin.trim());
  }

  bool verifyPin(String pin) {
    return pin.trim() == adminPin;
  }

  AppUser? loadSessionUser() {
    final raw = prefs.getString(_userKey);
    if (raw == null) return null;
    try {
      final json = jsonDecode(raw) as Map<String, dynamic>;
      return AppUser.fromJson(json);
    } catch (_) {
      return null;
    }
  }

  Future<void> saveSessionUser(AppUser user) async {
    await prefs.setString(_userKey, jsonEncode(user.toJson()));
  }

  Future<void> clearSession() async {
    await prefs.remove(_userKey);
  }

  Future<AppUser?> loginAdminWithPin(String pin) async {
    if (verifyPin(pin)) {
      const admin = AppUser.adminDefault;
      await saveSessionUser(admin);
      return admin;
    }
    return null;
  }

  Future<AppUser> loginAsCustomer({required String name, required String email}) async {
    final user = AppUser(
      id: 'usr_${DateTime.now().millisecondsSinceEpoch}',
      name: name.trim().isEmpty ? 'Valued Customer' : name.trim(),
      email: email.trim().isEmpty ? 'customer@driveline.pk' : email.trim(),
      role: UserRole.customer,
    );
    await saveSessionUser(user);
    return user;
  }
}

