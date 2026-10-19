import 'package:flutter/material.dart';
import '../../auth/auth_service.dart';
import '../../auth/auth_state.dart';
import '../../shared/app_colors.dart';

class LoginDialog extends StatefulWidget {
  final AuthService authService;
  final AuthState authState;

  const LoginDialog({
    super.key,
    required this.authService,
    required this.authState,
  });

  @override
  State<LoginDialog> createState() => _LoginDialogState();
}

class _LoginDialogState extends State<LoginDialog> {
  final _nameCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _pinCtrl = TextEditingController();
  bool _isAdminMode = false;
  String? _error;

  void _submit() async {
    if (_isAdminMode) {
      final user = await widget.authService.loginAdminWithPin(_pinCtrl.text.trim());
      if (user != null) {
        widget.authState.setUser(user);
        if (mounted) Navigator.pop(context, true);
      } else {
        setState(() => _error = 'Invalid Admin PIN. (Default: 1234)');
      }
    } else {
      if (_nameCtrl.text.trim().isEmpty) {
        setState(() => _error = 'Please enter your name.');
        return;
      }
      final user = await widget.authService.loginAsCustomer(
        name: _nameCtrl.text.trim(),
        email: _emailCtrl.text.trim(),
      );
      widget.authState.setUser(user);
      if (mounted) Navigator.pop(context, true);
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
      title: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppColors.brandRed.withAlpha(20),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(
              _isAdminMode ? Icons.shield_rounded : Icons.person_rounded,
              color: AppColors.brandRed,
              size: 22,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              _isAdminMode ? 'Admin Staff Sign In' : 'Customer Account',
              style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 18, color: AppColors.textDark),
            ),
          ),
        ],
      ),
      content: SizedBox(
        width: 400,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                Expanded(
                  child: ChoiceChip(
                    label: const Center(child: Text('Client Sign In')),
                    selected: !_isAdminMode,
                    onSelected: (v) => setState(() {
                      _isAdminMode = !v;
                      _error = null;
                    }),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: ChoiceChip(
                    label: const Center(child: Text('Admin Workspace')),
                    selected: _isAdminMode,
                    onSelected: (v) => setState(() {
                      _isAdminMode = v;
                      _error = null;
                    }),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            if (!_isAdminMode) ...[
              TextField(
                controller: _nameCtrl,
                decoration: const InputDecoration(labelText: 'Your Full Name *'),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: _emailCtrl,
                keyboardType: TextInputType.emailAddress,
                decoration: const InputDecoration(labelText: 'Email Address (Optional)'),
              ),
            ] else ...[
              TextField(
                controller: _pinCtrl,
                obscureText: true,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Admin Access PIN',
                  hintText: 'Default PIN: 1234',
                  prefixIcon: Icon(Icons.key_rounded, size: 18),
                ),
              ),
            ],
            if (_error != null) ...[
              const SizedBox(height: 10),
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
          onPressed: _submit,
          child: Text(_isAdminMode ? 'Unlock Admin' : 'Sign In'),
        ),
      ],
    );
  }
}

