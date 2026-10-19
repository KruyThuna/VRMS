import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:vehicle_rental/models.dart';
import 'package:vehicle_rental/store.dart';
import 'package:vehicle_rental/src/screens/storefront/widgets/professional_booking_date_dialog.dart';
import 'package:vehicle_rental/src/screens/cart/rental_cart_screen.dart';

void main() {
  test('Inclusive calendar dates and integer money preserve totals', () {
    final r = Rental('r', 'v', 'c', DateTime(2026, 10, 8), DateTime(2026, 10, 10), 3500, paidCents: 2000);
    expect(r.days, 3);
    expect(r.totalCents, 10500);
    expect(r.balanceCents, 8500);
    expect(parseMoney('12.50'), 1250);
    expect(parseMoney('0.01'), 1);
    expect(parseMoney('-1'), isNull);
    expect(parseMoney('2.333'), isNull);
    expect(money(1250), '\$12.50');
    expect(formattedDate(DateTime(2026, 10, 8)), 'Thu, Oct 8, 2026');
  });

  test('Booking overlap includes pickup and return dates', () {
    final r = Rental('r', 'v', 'c', DateTime(2026, 10, 8), DateTime(2026, 10, 10), 3500);
    expect(r.overlaps(DateTime(2026, 10, 10), DateTime(2026, 10, 12)), isTrue);
    expect(r.overlaps(DateTime(2026, 10, 11), DateTime(2026, 10, 12)), isFalse);
    expect(r.status(DateTime(2026, 10, 11)), 'Overdue');
    r.returned = true;
    expect(r.overlaps(DateTime(2026, 10, 8), DateTime(2026, 10, 10)), isFalse);
  });

  test('Saved changes reload and maintenance blocks reservations', () async {
    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();
    final store = RentalStore(prefs);
    await store.commit(() => store.customers.add(Customer('test', 'Test Customer', '012345678', email: 'test@example.com')));
    final reloaded = RentalStore(prefs);
    expect(reloaded.customer('test').name, 'Test Customer');
    expect(reloaded.customer('test').email, 'test@example.com');
    final maintenance = reloaded.vehicle('v4');
    expect(reloaded.available(maintenance, DateTime(2030), DateTime(2030, 1, 2)), isFalse);
  });

  test('Vehicle specifications and cyber HUD properties serialize correctly', () {
    final v = Vehicle(
      'v-bugatti',
      'Bugatti La Voiture Noire',
      '1-BUGATTI',
      'Hypercar',
      95000,
      purchasePrice: 11000000,
      brand: 'BUGATTI',
      tagline: 'A OBRA-PRIMA EXCLUSIVA',
      engine: 'MOTOR W16',
      horsepower: '1500 CV',
      topSpeed: '420 KM/H',
      acceleration: '0-100 EM 2,5S',
      seats: 2,
      transmission: 'Dual-Clutch 7-Speed',
      fuel: 'Petrol W16 Quad-Turbo',
      features: ['Full Carbon Monocoque', 'Active Aero Wing'],
      rating: 5.0,
      tripsCount: 12,
    );

    final json = v.toJson();
    final deserialized = Vehicle.fromJson(json);

    expect(deserialized.id, 'v-bugatti');
    expect(deserialized.name, 'Bugatti La Voiture Noire');
    expect(deserialized.brand, 'BUGATTI');
    expect(deserialized.engine, 'MOTOR W16');
    expect(deserialized.horsepower, '1500 CV');
    expect(deserialized.topSpeed, '420 KM/H');
    expect(deserialized.acceleration, '0-100 EM 2,5S');
    expect(deserialized.purchasePrice, 11000000);
  });

  test('BannerItem and AgencyConfig serialize and persist properly in RentalStore', () async {
    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();
    final store = RentalStore(prefs);

    // Test Default Banners & Categories
    expect(store.banners.isNotEmpty, isTrue);
    expect(store.categories.contains('SUV'), isTrue);
    expect(store.agencyConfig.companyName, 'DriveLine');

    // Test Adding Custom Banner
    final customBanner = BannerItem(
      id: 'b-custom',
      tagline: 'SPECIAL EDITION',
      title: 'FERRARI SF90',
      subtitle: 'Hybrid V8 Supercar',
      vehicleId: 'v-bugatti',
      priceText: '\$800 / DAY',
      specChips: ['1000 HP', 'AWD'],
      badgeText: 'HYBRID BEAST',
      badgeColorValue: 0xFFE50914,
      active: true,
    );

    await store.addBanner(customBanner);
    expect(store.banners.any((b) => b.id == 'b-custom'), isTrue);

    // Test Adding Dynamic Category
    await store.addCategory('Convertible');
    expect(store.categories.contains('Convertible'), isTrue);

    // Test Updating Agency Config
    await store.updateAgencyConfig(
      AgencyConfig(
        companyName: 'Apex Motors',
        companySlogan: 'Drive Pure Luxury',
        phone: '+1 800 555 0199',
        email: 'vip@apexmotors.com',
        address: 'Beverly Hills, CA',
        logoUrl: 'data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAYAAAAfFcSJAAAADUlEQVR42mNk+M9QDwADhgGAWjR9awAAAABJRU5ErkJggg==',
      ),
    );

    expect(store.agencyConfig.companyName, 'Apex Motors');
    expect(store.agencyConfig.phone, '+1 800 555 0199');
    expect(store.agencyConfig.logoUrl, startsWith('data:image/png;base64'));

    // Reload store from SharedPreferences and verify persistence
    final reloaded = RentalStore(prefs);
    expect(reloaded.banners.any((b) => b.id == 'b-custom'), isTrue);
    expect(reloaded.categories.contains('Convertible'), isTrue);
    expect(reloaded.agencyConfig.companyName, 'Apex Motors');
    expect(reloaded.agencyConfig.companySlogan, 'Drive Pure Luxury');
    expect(reloaded.agencyConfig.logoUrl, startsWith('data:image/png;base64'));
  });

  test('Vehicle copyWith updates properties accurately', () {
    final v = RentalStore.tiggo9Vehicle;
    final updated = v.copyWith(
      imageUrl: 'https://example.com/tiggo9.png',
      dailyCents: 6000,
      maintenance: true,
    );
    expect(updated.id, v.id);
    expect(updated.name, v.name);
    expect(updated.imageUrl, 'https://example.com/tiggo9.png');
    expect(updated.dailyCents, 6000);
    expect(updated.maintenance, isTrue);
  });

  testWidgets('ProfessionalBookingDateDialog renders timeline, presets, and confirms dates', (tester) async {
    DateTimeRange? confirmedRange;

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Builder(
            builder: (context) => ElevatedButton(
              onPressed: () async {
                confirmedRange = await showProfessionalBookingDatePicker(
                  context: context,
                  initialStart: DateTime(2026, 10, 15),
                  initialEnd: DateTime(2026, 10, 17),
                  firstDate: DateTime(2026, 10, 1),
                );
              },
              child: const Text('Open'),
            ),
          ),
        ),
      ),
    );

    // Tap to open dialog
    await tester.tap(find.text('Open'));
    await tester.pumpAndSettle();

    // Verify luxury header & badges
    expect(find.text('Rental Period & Schedule'), findsOneWidget);
    expect(find.text('100% FLEXIBLE'), findsOneWidget);
    expect(find.text('PICKUP DATE'), findsOneWidget);
    expect(find.text('RETURN DATE'), findsOneWidget);
    expect(find.text('QUICK DURATION:'), findsOneWidget);
    expect(find.text('3 Days (Weekend)'), findsOneWidget);

    // Tap the Confirm button
    final confirmBtn = find.textContaining('Confirm Booking');
    expect(confirmBtn, findsOneWidget);
    await tester.tap(confirmBtn);
    await tester.pumpAndSettle();

    // Verify dialog returned the range
    expect(confirmedRange, isNotNull);
    expect(confirmedRange!.start, DateTime(2026, 10, 15));
    expect(confirmedRange!.end, DateTime(2026, 10, 17));
  });

  testWidgets('RentalCart allows inputting user booking name, shows pickup & due dates', (tester) async {
    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();
    final store = RentalStore(prefs);

    final vehicle = RentalStore.tiggo9Vehicle;
    final now = DateTime.now();
    final pickupDate = DateTime(now.year, now.month, now.day).add(const Duration(days: 1));
    final dueDate = pickupDate.add(const Duration(days: 2));

    tester.view.physicalSize = const Size(1280, 1024);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);

    await tester.pumpWidget(
      MaterialApp(
        home: RentalCart(
          store: store,
          items: [vehicle],
          from: pickupDate,
          to: dueDate,
          onRemove: (_) {},
          onComplete: () {},
        ),
      ),
    );
    await tester.pumpAndSettle();

    // Verify Schedule card headers: PICKUP DATE and DUE DATE (RETURN)
    expect(find.text('PICKUP DATE'), findsOneWidget);
    expect(find.text('DUE DATE (RETURN)'), findsOneWidget);
    expect(find.textContaining('Vehicle is due for return by'), findsOneWidget);

    // Verify Booking User Name input and registered customers
    expect(find.text('Booking User Name *'), findsOneWidget);
    expect(find.text('Quick Fill (Registered Customers)'), findsOneWidget);
    expect(find.text('Ayesha Khan'), findsOneWidget);

    // Tap existing customer "Ayesha Khan" to auto-fill
    await tester.tap(find.text('Ayesha Khan'));
    await tester.pumpAndSettle();

    // Verify name field is filled with customer name
    expect(find.text('Ayesha Khan'), findsWidgets);

    // Verify Price and Schedule Summary shows pickup, due date, and balance due
    expect(find.text('Price & Schedule Summary'), findsOneWidget);
    expect(find.text('Total Amount Due'), findsOneWidget);

    // Test typing a custom booking user name
    final nameField = find.widgetWithText(TextField, 'Booking User Name *');
    await tester.enterText(nameField, 'Dara Seng');
    await tester.pumpAndSettle();
    expect(find.text('Dara Seng'), findsOneWidget);
  });
}

