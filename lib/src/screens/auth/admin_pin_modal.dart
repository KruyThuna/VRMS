import 'package:flutter/material.dart';
import '../../auth/auth_service.dart';
import '../../auth/auth_state.dart';
import '../../shared/app_colors.dart';

class AdminPinModal extends StatefulWidget {
  final AuthService authService;
  final AuthState authState;
  final String reason;

  const AdminPinModal({
    super.key,
    required this.authService,
    required this.authState,
    required this.reason,
  });

  @override
  State<AdminPinModal> createState() => _AdminPinModalState();
}

class _AdminPinModalState extends State<AdminPinModal> {
  final _pinCtrl = TextEditingController();
  String? _error;
  bool _busy = false;

  void _verify() async {
    final pin = _pinCtrl.text.trim();
    if (pin.isEmpty) {
      setState(() => _error = 'Please enter your Admin PIN.');
      return;
    }
    setState(() => _busy = true);
    final user = await widget.authService.loginAdminWithPin(pin);
    if (!mounted) return;
    setState(() => _busy = false);

    if (user != null) {
      widget.authState.setUser(user);
      Navigator.pop(context, true);
    } else {
      setState(() => _error = 'Invalid Admin PIN. (Default PIN: 1234)');
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: Colors.white,
      surfaceTintColor: Colors.transparent,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: const BorderSide(color: AppColors.lightBorder),
      ),
      elevation: 12,
      shadowColor: Colors.black.withAlpha(25),
      title: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppColors.brandRed.withAlpha(25),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(Icons.admin_panel_settings_rounded, color: AppColors.brandRed, size: 22),
          ),
          const SizedBox(width: 12),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Admin Authorization',
                  style: TextStyle(fontWeight: FontWeight.w800, fontSize: 18, color: AppColors.textDark),
                ),
                Text(
                  'Restricted workspace access',
                  style: TextStyle(fontSize: 12, color: AppColors.textMuted),
                ),
              ],
            ),
          ),
          IconButton(
            icon: const Icon(Icons.close_rounded, size: 20, color: AppColors.textMuted),
            onPressed: () => Navigator.pop(context, false),
          ),
        ],
      ),
      content: SizedBox(
        width: 380,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(widget.reason, style: const TextStyle(fontSize: 13, color: AppColors.textDark)),
            const SizedBox(height: 16),
            TextField(
              controller: _pinCtrl,
              autofocus: true,
              obscureText: true,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'Admin PIN Passcode',
                hintText: 'Enter 4-digit PIN (default: 1234)',
                prefixIcon: Icon(Icons.lock_outline_rounded, size: 18),
              ),
              onSubmitted: (_) => _verify(),
            ),
            if (_error != null) ...[
              const SizedBox(height: 8),
              Text(_error!, style: const TextStyle(color: Colors.redAccent, fontSize: 12, fontWeight: FontWeight.bold)),
            ],
          ],
        ),
      ),
      actionsPadding: const EdgeInsets.fromLTRB(24, 0, 24, 18),
      actions: [
        OutlinedButton(
          onPressed: () => Navigator.pop(context, false),
          child: const Text('Cancel'),
        ),
        FilledButton(
          style: FilledButton.styleFrom(backgroundColor: AppColors.brandRed),
          onPressed: _busy ? null : _verify,
          child: _busy
              ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
              : const Text('Unlock Workspace'),
        ),
      ],
    );
  }
}

