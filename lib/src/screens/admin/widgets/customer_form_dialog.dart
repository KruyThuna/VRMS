import 'package:flutter/material.dart';
import '../../../../models.dart';
import '../../../../store.dart';
import '../../../shared/app_colors.dart';

class CustomerFormDialog extends StatefulWidget {
  final RentalStore store;
  final Customer? customer;

  const CustomerFormDialog({
    super.key,
    required this.store,
    this.customer,
  });

  @override
  State<CustomerFormDialog> createState() => _CustomerFormDialogState();
}

class _CustomerFormDialogState extends State<CustomerFormDialog> {
  final _formKey = GlobalKey<FormState>();

  late final TextEditingController _nameController;
  late final TextEditingController _phoneController;
  late final TextEditingController _emailController;
  late final TextEditingController _licenseController;
  late final TextEditingController _addressController;
  late final TextEditingController _notesController;

  bool _isSaving = false;
  bool get isEdit => widget.customer != null;

  @override
  void initState() {
    super.initState();
    final c = widget.customer;
    _nameController = TextEditingController(text: c?.name ?? '');
    _phoneController = TextEditingController(text: c?.phone ?? '');
    _emailController = TextEditingController(text: c?.email ?? '');
    _licenseController = TextEditingController(text: c?.licenseNumber ?? '');
    _addressController = TextEditingController(text: c?.address ?? '');
    _notesController = TextEditingController(text: c?.notes ?? '');
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    _licenseController.dispose();
    _addressController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  String _t(String key) => widget.store.t(key);

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSaving = true);
    final s = widget.store;

    final customerToSave = Customer(
      widget.customer?.id ?? s.newId('C'),
      _nameController.text.trim(),
      _phoneController.text.trim(),
      email: _emailController.text.trim(),
      licenseNumber: _licenseController.text.trim(),
      address: _addressController.text.trim(),
      notes: _notesController.text.trim(),
    );

    try {
      if (isEdit) {
        await s.updateCustomer(customerToSave);
      } else {
        await s.addCustomer(customerToSave);
      }
      if (mounted) Navigator.of(context).pop(true);
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(_t('error'))),
        );
      }
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      backgroundColor: Colors.white,
      surfaceTintColor: Colors.transparent,
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 540),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Form(
            key: _formKey,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Dialog Header
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: AppColors.brandRed.withAlpha(20),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(Icons.person_pin_rounded, color: AppColors.brandRed, size: 24),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              isEdit ? _t('edit_customer') : _t('add_customer'),
                              style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 18, color: Color(0xFF0F172A)),
                            ),
                            Text(
                              isEdit
                                  ? 'ID: ${widget.customer!.id} • ${_t('save_changes')}'
                                  : 'DriveLine Customer Profile Management',
                              style: const TextStyle(fontSize: 12, color: Color(0xFF64748B)),
                            ),
                          ],
                        ),
                      ),
                      IconButton(
                        onPressed: () => Navigator.of(context).pop(),
                        icon: const Icon(Icons.close_rounded, color: Color(0xFF94A3B8)),
                      ),
                    ],
                  ),
                  const Divider(height: 24),

                  // Full Name
                  TextFormField(
                    controller: _nameController,
                    textCapitalization: TextCapitalization.words,
                    decoration: InputDecoration(
                      labelText: '${_t('full_name')} *',
                      hintText: 'e.g. Kimleng Seng, Jane Doe',
                      prefixIcon: const Icon(Icons.person_outline_rounded, size: 20),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                      filled: true,
                      fillColor: const Color(0xFFF8FAFC),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                    ),
                    validator: (v) => (v == null || v.trim().isEmpty) ? _t('full_name') : null,
                  ),
                  const SizedBox(height: 14),

                  // Phone & Email Row
                  Row(
                    children: [
                      Expanded(
                        child: TextFormField(
                          controller: _phoneController,
                          keyboardType: TextInputType.phone,
                          decoration: InputDecoration(
                            labelText: '${_t('phone_number')} *',
                            hintText: '+855 12 889 999',
                            prefixIcon: const Icon(Icons.phone_outlined, size: 20),
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                            filled: true,
                            fillColor: const Color(0xFFF8FAFC),
                            contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                          ),
                          validator: (v) => (v == null || v.trim().isEmpty) ? _t('phone_number') : null,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: TextFormField(
                          controller: _emailController,
                          keyboardType: TextInputType.emailAddress,
                          decoration: InputDecoration(
                            labelText: _t('email_address'),
                            hintText: 'customer@example.com',
                            prefixIcon: const Icon(Icons.email_outlined, size: 20),
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                            filled: true,
                            fillColor: const Color(0xFFF8FAFC),
                            contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),

                  // Driver's License / ID Number
                  TextFormField(
                    controller: _licenseController,
                    decoration: InputDecoration(
                      labelText: _t('driver_license'),
                      hintText: 'e.g. KH-DL-9823441 / ID 010293849',
                      prefixIcon: const Icon(Icons.badge_outlined, size: 20),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                      filled: true,
                      fillColor: const Color(0xFFF8FAFC),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                    ),
                  ),
                  const SizedBox(height: 14),

                  // Address / Location
                  TextFormField(
                    controller: _addressController,
                    decoration: InputDecoration(
                      labelText: _t('customer_address'),
                      hintText: 'e.g. Khan Chamkarmon, Phnom Penh',
                      prefixIcon: const Icon(Icons.location_on_outlined, size: 20),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                      filled: true,
                      fillColor: const Color(0xFFF8FAFC),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                    ),
                  ),
                  const SizedBox(height: 14),

                  // Customer Notes / Remarks
                  TextFormField(
                    controller: _notesController,
                    maxLines: 2,
                    decoration: InputDecoration(
                      labelText: _t('customer_notes'),
                      hintText: 'e.g. Preferred SUV models, VIP concierge requested, flight arrival note',
                      prefixIcon: const Icon(Icons.note_alt_outlined, size: 20),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                      filled: true,
                      fillColor: const Color(0xFFF8FAFC),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                    ),
                  ),
                  const SizedBox(height: 8),

                  // Preset Notes Quick Chips
                  Wrap(
                    spacing: 6,
                    runSpacing: 4,
                    children: [
                      _buildQuickTag('VIP Customer'),
                      _buildQuickTag('Corporate Account'),
                      _buildQuickTag('Verified Driver'),
                      _buildQuickTag('Airport Handover'),
                    ],
                  ),

                  const SizedBox(height: 24),
                  // Actions: Cancel & Submit
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      OutlinedButton(
                        onPressed: _isSaving ? null : () => Navigator.of(context).pop(),
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                        ),
                        child: Text(_t('cancel')),
                      ),
                      const SizedBox(width: 12),
                      FilledButton.icon(
                        onPressed: _isSaving ? null : _submit,
                        style: FilledButton.styleFrom(
                          backgroundColor: AppColors.brandRed,
                          padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 12),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                        ),
                        icon: _isSaving
                            ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                            : Icon(isEdit ? Icons.check_circle_outline_rounded : Icons.person_add_rounded, size: 18),
                        label: Text(
                          isEdit ? _t('save_changes') : _t('add_customer'),
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildQuickTag(String tag) {
    return ActionChip(
      label: Text(tag, style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w600)),
      backgroundColor: const Color(0xFFF1F5F9),
      padding: EdgeInsets.zero,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      onPressed: () {
        final current = _notesController.text.trim();
        if (current.isEmpty) {
          _notesController.text = tag;
        } else if (!current.contains(tag)) {
          _notesController.text = '$current • $tag';
        }
      },
    );
  }
}

