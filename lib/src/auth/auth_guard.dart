import 'package:flutter/material.dart';
import 'auth_service.dart';
import 'auth_state.dart';
import 'user_role.dart';
import '../screens/auth/admin_pin_modal.dart';

class AuthGuard {
  static Future<bool> ensureRole({
    required BuildContext context,
    required AuthState authState,
    required AuthService authService,
    required UserRole requiredRole,
    String? reason,
  }) async {
    // If user already satisfies role
    if (requiredRole == UserRole.admin && authState.isAdmin) {
      return true;
    }
    if (requiredRole == UserRole.manager && authState.isManager) {
      return true;
    }
    if (requiredRole == UserRole.customer && authState.isAuthenticated) {
      return true;
    }

    // Otherwise prompt for Admin PIN
    final authenticated = await showDialog<bool>(
      context: context,
      barrierDismissible: true,
      builder: (ctx) => AdminPinModal(
        authService: authService,
        authState: authState,
        reason: reason ?? 'Please enter your Admin PIN to proceed.',
      ),
    );

    return authenticated ?? false;
  }
}

