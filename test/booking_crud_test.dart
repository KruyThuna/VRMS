import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:vehicle_rental/main.dart';
import 'package:vehicle_rental/store.dart';
import 'package:vehicle_rental/models.dart';
import 'package:vehicle_rental/src/localization/app_language.dart';
import 'package:vehicle_rental/src/screens/admin/widgets/booking_form_dialog.dart';
import 'package:vehicle_rental/src/screens/admin/widgets/booking_details_dialog.dart';

void main() {
  testWidgets('Booking CRUD: Store operations (Add, Update, Delete, Return, Pay)', (tester) async {
    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();
    final store = RentalStore(prefs);

    final initialCount = store.rentals.length;
    final vehicle = store.vehicles.first;
    final customer = store.customers.first;
    final now = DateTime.now();

    // 1. CREATE
    final newRental = Rental(
      'R-TEST-999',
      vehicle.id,
      customer.id,
      now,
      now.add(const Duration(days: 3)),
      5000,
      paidCents: 5000,
      notes: 'VIP customer booking',
    );
    await store.addRental(newRental);
    expect(store.rentals.length, initialCount + 1);
    expect(store.rentals.first.id, 'R-TEST-999');

    // 2. READ & ANALYTICS
    expect(store.totalRentalRevenueCents, greaterThan(0));
    expect(store.totalRentalReceivablesCents, greaterThanOrEqualTo(0));

    // 3. UPDATE
    final updatedRental = newRental.copyWith(notes: 'Updated VIP booking note');
    await store.updateRental(updatedRental);
    expect(store.rentals.first.notes, 'Updated VIP booking note');

    // 4. RECORD PAYMENT
    await store.recordRentalPayment(newRental.id, 2000);
    expect(store.rentals.first.paidCents, 7000);

    // 5. RETURN CAR
    expect(store.rentals.first.returned, isFalse);
    await store.returnRentalVehicle(newRental.id);
    expect(store.rentals.first.returned, isTrue);

    // 6. DELETE
    await store.deleteRental(newRental.id);
    expect(store.rentals.length, initialCount);
  });

  testWidgets('Booking CRUD: BookingFormDialog creates new booking', (tester) async {
    tester.view.physicalSize = const Size(1280, 1024);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() => tester.view.resetPhysicalSize());

    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();
    final store = RentalStore(prefs);
    final initialCount = store.rentals.length;

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Builder(
            builder: (ctx) => ElevatedButton(
              onPressed: () => showDialog(
                context: ctx,
                builder: (_) => BookingFormDialog(store: store),
              ),
              child: const Text('Open Booking Form'),
            ),
          ),
        ),
      ),
    );

    // Open Dialog
    await tester.tap(find.text('Open Booking Form'));
    await tester.pumpAndSettle();

    expect(find.text('New Booking'), findsOneWidget);
    expect(find.text('Financial Summary'), findsOneWidget);

    // Tap Create Booking
    await tester.tap(find.text('Create Booking'));
    await tester.pumpAndSettle();

    expect(store.rentals.length, initialCount + 1);
  });

  testWidgets('Booking CRUD: BookingDetailsDialog renders contract and operations', (tester) async {
    tester.view.physicalSize = const Size(1280, 1024);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() => tester.view.resetPhysicalSize());

    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();
    final store = RentalStore(prefs);
    final rental = store.rentals.first;

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Builder(
            builder: (ctx) => ElevatedButton(
              onPressed: () => showDialog(
                context: ctx,
                builder: (_) => BookingDetailsDialog(
                  store: store,
                  rental: rental,
                  onUpdated: () {},
                ),
              ),
              child: const Text('Open Booking Details'),
            ),
          ),
        ),
      ),
    );

    // Open Details Dialog
    await tester.tap(find.text('Open Booking Details'));
    await tester.pumpAndSettle();

    expect(find.text(rental.id), findsOneWidget);
    expect(find.text('Vehicle Specifications'), findsOneWidget);
    expect(find.text('Customer Profile'), findsOneWidget);
    expect(find.text('Rental Period'), findsOneWidget);
    expect(find.text('Financial Summary'), findsOneWidget);

    // Verify Action buttons present
    expect(find.text('Delete Booking'), findsOneWidget);
    expect(find.text('Edit Booking'), findsOneWidget);
    expect(find.text('Close'), findsOneWidget);
  });

  testWidgets('Booking CRUD: Admin Hub Bookings screen renders KPIs, filters, and actions in Khmer', (tester) async {
    tester.view.physicalSize = const Size(1400, 1024);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() => tester.view.resetPhysicalSize());

    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();
    final store = RentalStore(prefs);
    store.setLanguage(AppLanguage.khmer);

    await tester.pumpWidget(
      MaterialApp(
        home: RentalHome(store: store),
      ),
    );
    await tester.pumpAndSettle();

    // Navigate to page 5 (Bookings / ការកក់រថយន្ត)
    final bookingsNav = find.text('ការកក់រថយន្ត');
    expect(bookingsNav, findsWidgets);
    await tester.tap(bookingsNav.first);
    await tester.pumpAndSettle();

    // Verify Khmer KPI Cards
    expect(find.text('ការកក់សរុប'), findsOneWidget);
    expect(find.text('កំពុងជួល'), findsWidgets);
    expect(find.text('បានប្រគល់រួច'), findsWidgets);
    expect(find.text('ចំណូលប្រមូលបាន'), findsOneWidget);

    // Verify Action buttons on rental cards
    expect(find.text('មើលព័ត៌មានលម្អិត'), findsWidgets);
    expect(find.text('កែប្រែការកក់'), findsWidgets);
  });
}

