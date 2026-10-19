import 'package:flutter/material.dart';
import '../../../models/vehicle.dart';
import '../../../models/banner_item.dart';
import '../../../../store.dart';
import '../../../shared/app_colors.dart';
import '../../../shared/smart_image.dart';

class PostVehicleDialog extends StatefulWidget {
  final RentalStore store;
  final Vehicle? existing;
  final Function(String) onMessage;

  const PostVehicleDialog({
    super.key,
    required this.store,
    this.existing,
    required this.onMessage,
  });

  @override
  State<PostVehicleDialog> createState() => _PostVehicleDialogState();
}

class _PostVehicleDialogState extends State<PostVehicleDialog> {
  late final TextEditingController nameCtrl;
  late final TextEditingController brandCtrl;
  late final TextEditingController plateCtrl;
  late String selectedType;
  late final TextEditingController rateCtrl;
  late final TextEditingController msrpCtrl;
  late final TextEditingController yearCtrl;
  late final TextEditingController seatsCtrl;
  late String transmission;
  late String fuel;

  late final TextEditingController engineCtrl;
  late final TextEditingController hpCtrl;
  late final TextEditingController speedCtrl;
  late final TextEditingController accelCtrl;
  late final TextEditingController taglineCtrl;

  late final TextEditingController d1Ctrl;
  late final TextEditingController d2Ctrl;
  late final TextEditingController d3Ctrl;

  late final TextEditingController q1Ctrl;
  late final TextEditingController q2Ctrl;
  late final TextEditingController q3Ctrl;

  String? imageUrl;
  late bool promoteToBanner;

  bool get isEdit => widget.existing != null;

  @override
  void initState() {
    super.initState();
    final e = widget.existing;
    final s = widget.store;

    String cleanText(String? val, String fallback) {
      if (val == null) return fallback;
      final t = val.trim();
      return (t.isEmpty || t.toLowerCase() == 'null') ? fallback : t;
    }

    String? cleanNullable(String? val) {
      if (val == null) return null;
      final t = val.trim();
      return (t.isEmpty || t.toLowerCase() == 'null') ? null : t;
    }

    nameCtrl = TextEditingController(text: cleanText(e?.name, ''));
    brandCtrl = TextEditingController(text: cleanText(e?.brand, 'CHERY'));
    plateCtrl = TextEditingController(text: cleanText(e?.plate, '1-NEW'));
    selectedType = cleanText(e?.type, (s.categories.length > 1 ? s.categories[1] : 'SUV'));
    rateCtrl = TextEditingController(text: e != null && e.dailyCents > 0 ? (e.dailyCents / 100).toStringAsFixed(0) : '65');
    msrpCtrl = TextEditingController(text: e != null && e.purchasePrice > 0 ? e.purchasePrice.toString() : '35000');
    yearCtrl = TextEditingController(text: e != null && e.year > 0 ? e.year.toString() : '2025');
    seatsCtrl = TextEditingController(text: e != null && e.seats > 0 ? e.seats.toString() : '5');
    transmission = cleanText(e?.transmission, 'Automatic');
    fuel = cleanText(e?.fuel, 'Petrol');

    engineCtrl = TextEditingController(text: cleanText(e?.engine, '2.0L TURBO ENGINE'));
    hpCtrl = TextEditingController(text: cleanText(e?.horsepower, '250 HP'));
    speedCtrl = TextEditingController(text: cleanText(e?.topSpeed, '220 KM/H'));
    accelCtrl = TextEditingController(text: cleanText(e?.acceleration, '0-100 IN 6.5S'));
    taglineCtrl = TextEditingController(text: cleanText(e?.tagline, 'ONE STEP AHEAD'));

    final dHighlights = (e?.designHighlights ?? []).map((h) => h.trim()).where((h) => h.isNotEmpty && h.toLowerCase() != 'null').toList();
    d1Ctrl = TextEditingController(text: dHighlights.isNotEmpty ? dHighlights[0] : 'PREMIUM AERODYNAMIC DESIGN');
    d2Ctrl = TextEditingController(text: dHighlights.length > 1 ? dHighlights[1] : 'FULL MATRIX LED LIGHTING');
    d3Ctrl = TextEditingController(text: dHighlights.length > 2 ? dHighlights[2] : '20-INCH ALLOY WHEELS');

    final qFacts = (e?.quickFacts ?? []).map((q) => q.trim()).where((q) => q.isNotEmpty && q.toLowerCase() != 'null').toList();
    q1Ctrl = TextEditingController(text: qFacts.isNotEmpty ? qFacts[0] : 'PRICE: COMPETITIVE');
    q2Ctrl = TextEditingController(text: qFacts.length > 1 ? qFacts[1] : '100% INSPECTED & CERTIFIED');
    q3Ctrl = TextEditingController(text: qFacts.length > 2 ? qFacts[2] : 'TOTAL CONNECTIVITY');

    imageUrl = cleanNullable(e?.imageUrl);
    promoteToBanner = e?.isFeatured ?? false;
  }

  @override
  void dispose() {
    nameCtrl.dispose();
    brandCtrl.dispose();
    plateCtrl.dispose();
    rateCtrl.dispose();
    msrpCtrl.dispose();
    yearCtrl.dispose();
    seatsCtrl.dispose();
    engineCtrl.dispose();
    hpCtrl.dispose();
    speedCtrl.dispose();
    accelCtrl.dispose();
    taglineCtrl.dispose();
    d1Ctrl.dispose();
    d2Ctrl.dispose();
    d3Ctrl.dispose();
    q1Ctrl.dispose();
    q2Ctrl.dispose();
    q3Ctrl.dispose();
    super.dispose();
  }

  void _submit() async {
    final s = widget.store;
    final e = widget.existing;

    String cleanInput(String text, String fallback) {
      final t = text.trim();
      return (t.isEmpty || t.toLowerCase() == 'null') ? fallback : t;
    }

    if (nameCtrl.text.trim().isEmpty || brandCtrl.text.trim().isEmpty) {
      widget.onMessage('Please enter Vehicle Name and Brand.');
      return;
    }
    final rate = (double.tryParse(rateCtrl.text.trim()) ?? 55) * 100;
    final msrp = int.tryParse(msrpCtrl.text.trim()) ?? 35000;
    final yr = int.tryParse(yearCtrl.text.trim()) ?? 2025;
    final seats = int.tryParse(seatsCtrl.text.trim()) ?? 5;

    final sanitizedImageUrl = (imageUrl != null && imageUrl!.trim().isNotEmpty && imageUrl!.trim().toLowerCase() != 'null')
        ? imageUrl!.trim()
        : null;

    final v = Vehicle(
      isEdit ? e!.id : s.newId('V'),
      cleanInput(nameCtrl.text, 'Vehicle'),
      cleanInput(plateCtrl.text, '1-AUTO'),
      cleanInput(selectedType, 'SUV'),
      rate.toInt(),
      purchasePrice: msrp,
      year: yr,
      seats: seats,
      transmission: cleanInput(transmission, 'Automatic'),
      fuel: cleanInput(fuel, 'Petrol'),
      imageUrl: sanitizedImageUrl,
      brand: cleanInput(brandCtrl.text, 'DRIVELINE').toUpperCase(),
      tagline: cleanInput(taglineCtrl.text, 'ONE STEP AHEAD'),
      engine: cleanInput(engineCtrl.text, '2.0L TURBO ENGINE'),
      horsepower: cleanInput(hpCtrl.text, '250 HP'),
      topSpeed: cleanInput(speedCtrl.text, '220 KM/H'),
      acceleration: cleanInput(accelCtrl.text, '0-100 IN 6.5S'),
      designHighlights: [
        cleanInput(d1Ctrl.text, 'PREMIUM AERODYNAMIC DESIGN'),
        cleanInput(d2Ctrl.text, 'FULL MATRIX LED LIGHTING'),
        cleanInput(d3Ctrl.text, '20-INCH ALLOY WHEELS'),
      ],
      quickFacts: [
        cleanInput(q1Ctrl.text, 'PRICE: COMPETITIVE'),
        cleanInput(q2Ctrl.text, '100% INSPECTED & CERTIFIED'),
        cleanInput(q3Ctrl.text, 'TOTAL CONNECTIVITY'),
      ],
      isFeatured: promoteToBanner,
    );

    if (isEdit) {
      await s.updateVehicle(v);
      if (promoteToBanner) {
        final bIdx = s.banners.indexWhere((b) => b.vehicleId == v.id);
        final bannerItem = BannerItem(
          id: bIdx != -1 ? s.banners[bIdx].id : s.newId('B'),
          tagline: v.tagline.isNotEmpty && v.tagline != 'null' ? v.tagline : 'FEATURED VEHICLE',
          title: v.name.toUpperCase(),
          subtitle: '${v.brand} Flagship ${v.type} • ${v.engine}',
          vehicleId: v.id,
          priceText: '\$${(v.dailyCents / 100).toStringAsFixed(0)} / DAY • FULL INSURANCE',
          specChips: [
            v.engine,
            '${v.horsepower} · ${v.acceleration}',
            v.transmission,
            '${v.seats} SEATS',
          ],
          badgeText: v.brand,
          badgeColorValue: 0xFF10B981,
          active: true,
          imageUrl: v.imageUrl,
        );
        if (bIdx != -1) {
          await s.updateBanner(bannerItem);
        } else {
          await s.addBanner(bannerItem);
        }
      }
      widget.onMessage('Updated ${v.name} successfully!');
    } else {
      await s.addVehicle(v);
      if (promoteToBanner) {
        final b = BannerItem(
          id: s.newId('B'),
          tagline: v.tagline.isNotEmpty && v.tagline != 'null' ? v.tagline : 'NEW ARRIVAL',
          title: v.name.toUpperCase(),
          subtitle: '${v.brand} Flagship ${v.type} • ${v.engine}',
          vehicleId: v.id,
          priceText: '\$${(v.dailyCents / 100).toStringAsFixed(0)} / DAY • FULL INSURANCE',
          specChips: [
            v.engine,
            '${v.horsepower} · ${v.acceleration}',
            v.transmission,
            '${v.seats} SEATS',
          ],
          badgeText: v.brand,
          badgeColorValue: 0xFF10B981,
          active: true,
          imageUrl: v.imageUrl,
        );
        await s.addBanner(b);
      }
      widget.onMessage('Posted ${v.name} to Fleet & Storefront!');
    }
    if (mounted) Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final s = widget.store;
    final e = widget.existing;

    return AlertDialog(
      backgroundColor: Colors.white,
      surfaceTintColor: Colors.transparent,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: const BorderSide(color: AppColors.lightBorder),
      ),
      elevation: 12,
      shadowColor: Colors.black.withAlpha(30),
      titlePadding: const EdgeInsets.fromLTRB(24, 20, 16, 12),
      contentPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
      actionsPadding: const EdgeInsets.fromLTRB(24, 12, 24, 20),
      title: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: const Color(0xFFFEE2E2),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: const Color(0xFFFECACA)),
            ),
            child: Icon(
              isEdit ? Icons.edit_note_rounded : Icons.add_circle_outline_rounded,
              color: AppColors.brandRed,
              size: 22,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  isEdit ? '${s.t('edit_vehicle')}: ${e?.name}' : s.t('new_fleet_product'),
                  style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 18, color: AppColors.textDark),
                ),
                const SizedBox(height: 2),
                Text(
                  isEdit ? 'Update product specifications and media' : 'Add inventory vehicle with full Cyber HUD specs',
                  style: const TextStyle(fontSize: 12, color: AppColors.textMuted),
                ),
              ],
            ),
          ),
          IconButton(
            icon: const Icon(Icons.close_rounded, size: 20, color: AppColors.textMuted),
            tooltip: 'Close',
            onPressed: () => Navigator.pop(context),
          ),
        ],
      ),
      content: SizedBox(
        width: 580,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              ImageUploadPickerField(
                initialValue: imageUrl,
                label: 'Vehicle Photo / Product Image',
                presets: const [
                  (label: 'Chery Tiggo 9', url: 'assets/images/tiggo9_banner.png'),
                  (label: 'Hypercar', url: 'https://images.unsplash.com/photo-1617788138017-80ad40651399?w=800&q=80'),
                  (label: 'Luxury SUV', url: 'https://images.unsplash.com/photo-1533473359331-0135ef1b58bf?w=800&q=80'),
                  (label: 'Electric Sport', url: 'https://images.unsplash.com/photo-1560958089-b8a1929cea89?w=800&q=80'),
                ],
                onChanged: (val) => imageUrl = val,
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Container(width: 3.5, height: 14, decoration: BoxDecoration(color: AppColors.darkBg, borderRadius: BorderRadius.circular(2))),
                  const SizedBox(width: 8),
                  Text(s.t('vehicle_attributes'), style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 13, color: AppColors.textDark, letterSpacing: 0.2)),
                ],
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  Expanded(flex: 3, child: TextField(controller: nameCtrl, decoration: const InputDecoration(labelText: 'Car Model Name *'))),
                  const SizedBox(width: 10),
                  Expanded(flex: 2, child: TextField(controller: brandCtrl, decoration: InputDecoration(labelText: '${s.t('brand')} *'))),
                ],
              ),
              const SizedBox(height: 6),
              Wrap(
                spacing: 6,
                runSpacing: 4,
                children: ['CHERY', 'TOYOTA', 'BMW', 'TESLA', 'BUGATTI', 'HONDA', 'FORD', 'LEXUS'].map((b) => ActionChip(
                  label: Text(b, style: TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: brandCtrl.text.toUpperCase() == b ? Colors.white : AppColors.textDark)),
                  backgroundColor: brandCtrl.text.toUpperCase() == b ? AppColors.brandRed : const Color(0xFFF3F4F6),
                  side: BorderSide(color: brandCtrl.text.toUpperCase() == b ? AppColors.brandRed : const Color(0xFFE5E7EB)),
                  padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 0),
                  visualDensity: VisualDensity.compact,
                  onPressed: () => setState(() => brandCtrl.text = b),
                )).toList(),
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  Expanded(
                    child: DropdownButtonFormField<String>(
                      initialValue: s.categories.contains(selectedType) ? selectedType : 'SUV',
                      decoration: const InputDecoration(labelText: 'Category / Type'),
                      items: s.categories
                          .where((c) => c != 'All')
                          .map((c) => DropdownMenuItem(value: c, child: Text(c)))
                          .toList(),
                      onChanged: (v) => setState(() => selectedType = v!),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(child: TextField(controller: plateCtrl, decoration: const InputDecoration(labelText: 'Plate / Serial *'))),
                ],
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  Expanded(child: TextField(controller: rateCtrl, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'Daily Rate (USD) *', prefixText: '\$'))),
                  const SizedBox(width: 10),
                  Expanded(child: TextField(controller: msrpCtrl, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'Fleet Asset Value (USD)', prefixText: '\$'))),
                ],
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  Expanded(child: TextField(controller: yearCtrl, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'Year'))),
                  const SizedBox(width: 10),
                  Expanded(child: TextField(controller: seatsCtrl, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'Seats'))),
                  const SizedBox(width: 10),
                  Expanded(
                    child: DropdownButtonFormField<String>(
                      initialValue: transmission,
                      decoration: const InputDecoration(labelText: 'Transmission'),
                      items: const [
                        DropdownMenuItem(value: 'Automatic', child: Text('Automatic')),
                        DropdownMenuItem(value: 'Manual', child: Text('Manual')),
                        DropdownMenuItem(value: 'Dual-Clutch', child: Text('Dual-Clutch')),
                        DropdownMenuItem(value: '8-Speed AT AWD', child: Text('8-Speed AWD')),
                      ],
                      onChanged: (v) => setState(() => transmission = v!),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              const Divider(color: AppColors.lightBorder, height: 28),
              Row(
                children: [
                  Container(width: 3.5, height: 14, decoration: BoxDecoration(color: AppColors.brandRed, borderRadius: BorderRadius.circular(2))),
                  const SizedBox(width: 8),
                  const Text('Cyber HUD Performance Specs', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 13, color: AppColors.textDark, letterSpacing: 0.2)),
                ],
              ),
              const SizedBox(height: 10),
              TextField(controller: engineCtrl, decoration: const InputDecoration(labelText: 'Engine Specs (e.g. 2.0L TGDI TURBO (261 HP))')),
              const SizedBox(height: 10),
              Row(
                children: [
                  Expanded(child: TextField(controller: hpCtrl, decoration: const InputDecoration(labelText: 'Horsepower (e.g. 261 CV)'))),
                  const SizedBox(width: 10),
                  Expanded(child: TextField(controller: speedCtrl, decoration: const InputDecoration(labelText: 'Top Speed (e.g. 220 KM/H)'))),
                  const SizedBox(width: 10),
                  Expanded(child: TextField(controller: accelCtrl, decoration: const InputDecoration(labelText: '0-100 Accel (e.g. 6.5s)'))),
                ],
              ),
              const SizedBox(height: 10),
              TextField(controller: taglineCtrl, decoration: const InputDecoration(labelText: 'Slogan / Tagline (e.g. ONE STEP AHEAD)')),
              const SizedBox(height: 16),
              const Divider(color: AppColors.lightBorder, height: 28),
              Row(
                children: [
                  Container(width: 3.5, height: 14, decoration: BoxDecoration(color: AppColors.brandBlue, borderRadius: BorderRadius.circular(2))),
                  const SizedBox(width: 8),
                  const Text('Design Highlights (3 Key Points)', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 13, color: AppColors.textDark, letterSpacing: 0.2)),
                ],
              ),
              const SizedBox(height: 8),
              TextField(controller: d1Ctrl, decoration: const InputDecoration(labelText: 'Highlight 1')),
              const SizedBox(height: 6),
              TextField(controller: d2Ctrl, decoration: const InputDecoration(labelText: 'Highlight 2')),
              const SizedBox(height: 6),
              TextField(controller: d3Ctrl, decoration: const InputDecoration(labelText: 'Highlight 3')),
              const SizedBox(height: 14),
              Row(
                children: [
                  Container(width: 3.5, height: 14, decoration: BoxDecoration(color: AppColors.brandEmerald, borderRadius: BorderRadius.circular(2))),
                  const SizedBox(width: 8),
                  const Text('Quick Facts (3 Bullet Points)', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 13, color: AppColors.textDark, letterSpacing: 0.2)),
                ],
              ),
              const SizedBox(height: 8),
              TextField(controller: q1Ctrl, decoration: const InputDecoration(labelText: 'Fact 1')),
              const SizedBox(height: 6),
              TextField(controller: q2Ctrl, decoration: const InputDecoration(labelText: 'Fact 2')),
              const SizedBox(height: 6),
              TextField(controller: q3Ctrl, decoration: const InputDecoration(labelText: 'Fact 3')),
              const SizedBox(height: 14),
              Material(
                color: AppColors.lightBg,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                  side: const BorderSide(color: AppColors.lightBorder),
                ),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                  child: CheckboxListTile(
                    contentPadding: EdgeInsets.zero,
                    dense: true,
                    title: const Text('Promote & publish as Active Website Hero Banner', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: AppColors.textDark)),
                    subtitle: const Text('Automatically adds to public hero banner carousel with HUD telemetry.', style: TextStyle(fontSize: 11, color: AppColors.textMuted)),
                    value: promoteToBanner,
                    activeColor: AppColors.brandEmerald,
                    onChanged: (v) => setState(() => promoteToBanner = v ?? false),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      actions: [
        OutlinedButton(
          style: OutlinedButton.styleFrom(
            foregroundColor: const Color(0xFF374151),
            side: const BorderSide(color: AppColors.inputBorder),
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          ),
          onPressed: () => Navigator.pop(context),
          child: Text(s.t('cancel'), style: const TextStyle(fontWeight: FontWeight.w600)),
        ),
        FilledButton.icon(
          icon: Icon(isEdit ? Icons.check_circle_outline : Icons.add_task_rounded, size: 18),
          style: FilledButton.styleFrom(
            backgroundColor: AppColors.brandRed,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            elevation: 0,
          ),
          onPressed: _submit,
          label: Text(isEdit ? s.t('save_changes') : s.t('post_product'), style: const TextStyle(fontWeight: FontWeight.bold)),
        ),
      ],
    );
  }
}

