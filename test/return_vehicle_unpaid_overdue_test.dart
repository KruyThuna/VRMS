import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:vehicle_rental/models.dart';
import 'package:vehicle_rental/store.dart';
import 'package:vehicle_rental/src/screens/admin/widgets/return_vehicle_dialog.dart';
import 'package:vehicle_rental/main.dart';

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  group('Car Return Workflow - Overdue & Unpaid Balance Due', () {
    testWidgets('Displays overdue warning and unpaid balance due breakdown in ReturnVehicleDialog', (tester) async {
      tester.view.physicalSize = const Size(1280, 1024);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      final prefs = await SharedPreferences.getInstance();
      final store = RentalStore(prefs);

      // Create an overdue rental with unpaid balance
      final now = DateTime.now();
      final today = DateTime(now.year, now.month, now.day);
      final rentalStart = today.subtract(const Duration(days: 5));
      final rentalEnd = today.subtract(const Duration(days: 2)); // 2 days overdue

      final rental = Rental(
        'R-TEST-OVERDUE',
        'v1',
        'c1',
        rentalStart,
        rentalEnd,
        5000, // $50/day * 4 days = $200
        paidCents: 5000, // Paid $50, remaining balance $150
      );
      await store.addRental(rental);

      expect(rental.status(now), 'Overdue');
      expect(rental.balanceCents, 15000); // $150 balance due

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ReturnVehicleDialog(
              store: store,
              rental: rental,
              onUpdated: () {},
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Verify header and basic info
      expect(find.text('Return Vehicle & Check-In'), findsOneWidget);
      expect(find.textContaining('R-TEST-OVERDUE'), findsOneWidget);

      // Verify Overdue warning banner
      expect(find.text('Rental Period Expired / Overdue'), findsOneWidget);
      expect(find.textContaining('Overdue by 2 days'), findsOneWidget);

      // Verify Financial breakdown
      expect(find.text('Financial Summary'), findsOneWidget);
      expect(find.text('UNPAID DUE'), findsOneWidget);
      expect(find.text('\$150.00'), findsWidgets); // Balance due metric + prefilled text field

      // Verify Option A and Option B buttons exist
      expect(find.text('Settle Balance & Return'), findsOneWidget);
      expect(find.text('Return with Pending Debt'), findsOneWidget);

      // Verify payment methods are selectable
      expect(find.text('ABA KHQR'), findsOneWidget);
      expect(find.text('Cash'), findsOneWidget);
      expect(find.text('Card'), findsOneWidget);
    });

    testWidgets('Option A: Settle Balance & Return collects payment and returns car to inventory', (tester) async {
      tester.view.physicalSize = const Size(1280, 1024);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      final prefs = await SharedPreferences.getInstance();
      final store = RentalStore(prefs);

      final now = DateTime.now();
      final today = DateTime(now.year, now.month, now.day);

      final rental = Rental(
        'R-SETTLE-TEST',
        'v1',
        'c1',
        today.subtract(const Duration(days: 3)),
        today.subtract(const Duration(days: 1)),
        10000,
        paidCents: 5000,
      );
      await store.addRental(rental);

      bool updated = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ReturnVehicleDialog(
              store: store,
              rental: rental,
              onUpdated: () => updated = true,
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Tap Settle Balance & Return
      final settleBtn = find.text('Settle Balance & Return');
      await tester.tap(settleBtn);
      await tester.pumpAndSettle();

      expect(updated, isTrue);

      final updatedRental = store.rentals.firstWhere((r) => r.id == 'R-SETTLE-TEST');
      expect(updatedRental.returned, isTrue);
      expect(updatedRental.balanceCents, 0); // Settled!
      expect(updatedRental.status(DateTime.now()), 'Returned');
      expect(updatedRental.notes, contains('Payment Settlement'));
    });

    testWidgets('Option B: Return with Pending Debt returns car to inventory while recording debt note', (tester) async {
      tester.view.physicalSize = const Size(1280, 1024);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      final prefs = await SharedPreferences.getInstance();
      final store = RentalStore(prefs);

      final now = DateTime.now();
      final today = DateTime(now.year, now.month, now.day);

      final rental = Rental(
        'R-DEBT-TEST',
        'v1',
        'c1',
        today.subtract(const Duration(days: 4)),
        today.subtract(const Duration(days: 1)),
        8000,
        paidCents: 8000, // Total = 32000, paid = 8000, balance = 24000
      );
      await store.addRental(rental);

      bool updated = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ReturnVehicleDialog(
              store: store,
              rental: rental,
              onUpdated: () => updated = true,
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Enter inspection notes
      final notesField = find.byType(TextField).last;
      await tester.enterText(notesField, 'Customer promised bank transfer tomorrow morning');

      // Tap Return with Pending Debt
      final debtBtn = find.text('Return with Pending Debt');
      await tester.tap(debtBtn);
      await tester.pumpAndSettle();

      expect(updated, isTrue);

      final updatedRental = store.rentals.firstWhere((r) => r.id == 'R-DEBT-TEST');
      expect(updatedRental.returned, isTrue);
      expect(updatedRental.balanceCents, greaterThan(0)); // Debt is kept!
      expect(updatedRental.notes, contains('Return Audit: Car returned to inventory with outstanding unpaid balance'));
      expect(updatedRental.notes, contains('Customer promised bank transfer tomorrow morning'));
    });

    testWidgets('Clean Return when rental is fully paid (\$0 balance)', (tester) async {
      tester.view.physicalSize = const Size(1280, 1024);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      final prefs = await SharedPreferences.getInstance();
      final store = RentalStore(prefs);

      final now = DateTime.now();
      final today = DateTime(now.year, now.month, now.day);

      final rental = Rental(
        'R-CLEAN-TEST',
        'v1',
        'c1',
        today.subtract(const Duration(days: 2)),
        today,
        5000,
        paidCents: 15000, // Fully paid
      );
      await store.addRental(rental);

      expect(rental.balanceCents, 0);

      bool updated = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ReturnVehicleDialog(
              store: store,
              rental: rental,
              onUpdated: () => updated = true,
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Should show FULLY PAID badge
      expect(find.text('FULLY PAID'), findsOneWidget);

      // Should show standard Return Car button (no debt or settle buttons)
      expect(find.text('Return Car'), findsOneWidget);
      expect(find.text('Return with Pending Debt'), findsNothing);

      await tester.tap(find.text('Return Car'));
      await tester.pumpAndSettle();

      expect(updated, isTrue);
      final updatedRental = store.rentals.firstWhere((r) => r.id == 'R-CLEAN-TEST');
      expect(updatedRental.returned, isTrue);
    });

    testWidgets('Admin Dashboard integrates Return Car in Management Hub sidebar and navigates to returnsHub', (tester) async {
      tester.view.physicalSize = const Size(1280, 1024);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      final prefs = await SharedPreferences.getInstance();
      final store = RentalStore(prefs);

      // Add one active rental and one overdue rental
      final now = DateTime.now();
      final today = DateTime(now.year, now.month, now.day);
      await store.addRental(
        Rental(
          'R-NAV-OVERDUE',
          'v1',
          'c1',
          today.subtract(const Duration(days: 4)),
          today.subtract(const Duration(days: 1)),
          6000,
          paidCents: 6000,
        ),
      );

      await tester.pumpWidget(
        MaterialApp(
          home: RentalHome(store: store),
        ),
      );
      await tester.pumpAndSettle();

      // Verify Dashboard quick operations has Return Car button
      expect(find.widgetWithText(FilledButton, store.t('return_car')), findsOneWidget);

      // Verify Overdue Alert Banner is visible on Dashboard
      expect(find.text(store.t('overdue_banner_alert')), findsOneWidget);

      // Verify Return Car item in sidebar (MANAGEMENT HUB)
      final returnNav = find.widgetWithText(ListTile, store.t('return_car'));
      expect(returnNav, findsOneWidget);

      // Tap Return Car in sidebar
      await tester.tap(returnNav);
      await tester.pumpAndSettle();

      // Verify we arrived on Fleet Returns Hub page
      expect(find.text(store.t('awaiting_return')), findsOneWidget);
      expect(find.text(store.t('overdue_only')), findsWidgets);
      expect(find.text(store.t('unpaid_only')), findsWidgets);
      expect(find.text(store.t('returned_history')), findsWidgets);

      // Verify vehicle cards have return action buttons
      expect(find.textContaining('Check-In & Return'), findsWidgets);

      // Verify top right quick action button
      expect(find.text(store.t('quick_return_action')), findsOneWidget);
    });
  });
}
