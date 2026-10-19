import 'package:flutter/foundation.dart';
import '../models/user.dart';
import 'user_role.dart';

class AuthState extends ChangeNotifier {
  AppUser _currentUser = AppUser.guestDefault;
  bool _isAuthenticated = false;

  AppUser get currentUser => _currentUser;
  bool get isAuthenticated => _isAuthenticated;
  bool get isAdmin => _currentUser.isAdmin;
  bool get isManager => _currentUser.isManager;
  UserRole get role => _currentUser.role;

  void setUser(AppUser user) {
    _currentUser = user;
    _isAuthenticated = user.role != UserRole.guest;
    notifyListeners();
  }

  void logout() {
    _currentUser = AppUser.guestDefault;
    _isAuthenticated = false;
    notifyListeners();
  }
}

