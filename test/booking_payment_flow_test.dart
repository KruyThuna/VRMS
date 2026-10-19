import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:vehicle_rental/store.dart';
import 'package:vehicle_rental/src/localization/app_language.dart';
import 'package:vehicle_rental/src/screens/cart/rental_cart_screen.dart';

void main() {
  testWidgets('RentalCart end-to-end full payment flow with ABA KHQR', (tester) async {
    tester.view.physicalSize = const Size(1280, 1024);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);

    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();
    final store = RentalStore(prefs);

    final vehicle = RentalStore.tiggo9Vehicle;
    final now = DateTime.now();
    final pickupDate = DateTime(now.year, now.month, now.day).add(const Duration(days: 2));
    final dueDate = pickupDate.add(const Duration(days: 2)); // 3 days

    bool completed = false;

    await tester.pumpWidget(
      MaterialApp(
        home: RentalCart(
          store: store,
          items: [vehicle],
          from: pickupDate,
          to: dueDate,
          onRemove: (_) {},
          onComplete: () => completed = true,
        ),
      ),
    );
    await tester.pumpAndSettle();

    // Verify Payment Terms section is visible
    expect(find.text('Payment Method & Terms'), findsOneWidget);
    expect(find.text('Pay in Full (100%)'), findsOneWidget);
    expect(find.text('Pay 30% Deposit'), findsOneWidget);
    expect(find.text('Pay at Pickup (Cash / Card)'), findsOneWidget);

    // Verify KHQR view is displayed by default
    expect(find.text('ABA / KHQR Mobile Banking'), findsOneWidget);
    expect(find.text('Bakong National Payment'), findsOneWidget);
    expect(find.text('KHQR'), findsWidgets);

    // Fill customer booking details
    final nameField = find.widgetWithText(TextField, 'Booking User Name *');
    await tester.enterText(nameField, 'Kimleng Seng');

    final phoneField = find.widgetWithText(TextField, 'Phone Number *');
    await tester.enterText(phoneField, '+855 12 889 999');

    // Tap Confirm Reservation button (Pay in Full)
    final confirmBtn = find.textContaining('Confirm Reservation');
    expect(confirmBtn, findsOneWidget);
    await tester.ensureVisible(confirmBtn);
    await tester.tap(confirmBtn);
    await tester.pumpAndSettle();

    // Verify completion callback fired
    expect(completed, isTrue);

    // Verify created rental in store has paidCents == totalCents
    final createdRental = store.rentals.last;
    expect(createdRental.paidCents, createdRental.totalCents);
    expect(createdRental.balanceCents, 0);
    expect(createdRental.notes, contains('Pay in Full (100%)'));

    // Verify official confirmation receipt voucher
    expect(find.text('Reservation Receipt'), findsOneWidget);
    expect(find.text('PAID IN FULL'), findsOneWidget);
    expect(find.text('Kimleng Seng'), findsOneWidget);
    expect(find.text('+855 12 889 999'), findsOneWidget);
    expect(find.text('Back to Fleet Storefront'), findsOneWidget);
    expect(find.text('Print / Save Receipt'), findsOneWidget);
  });

  testWidgets('RentalCart 30% deposit payment flow calculates and saves deposit ledger', (tester) async {
    tester.view.physicalSize = const Size(1280, 1600);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);

    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();
    final store = RentalStore(prefs);

    final vehicle = RentalStore.tiggo9Vehicle;
    final now = DateTime.now();
    final pickupDate = DateTime(now.year, now.month, now.day).add(const Duration(days: 3));
    final dueDate = pickupDate.add(const Duration(days: 2));

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

    // Select "Pay 30% Deposit"
    final depositTile = find.text('Pay 30% Deposit');
    await tester.ensureVisible(depositTile);
    await tester.tap(depositTile);
    await tester.pumpAndSettle();

    // Switch to Credit / Debit Card
    final cardTab = find.text('Credit / Debit Card');
    await tester.ensureVisible(cardTab);
    await tester.tap(cardTab);
    await tester.pumpAndSettle();

    // Verify Card inputs are displayed
    expect(find.text('Card Number'), findsOneWidget);
    expect(find.text('Expiry (MM/YY)'), findsOneWidget);
    expect(find.text('CVV'), findsOneWidget);

    // Fill customer info
    await tester.enterText(find.widgetWithText(TextField, 'Booking User Name *'), 'Vannak Heng');
    await tester.enterText(find.widgetWithText(TextField, 'Phone Number *'), '+855 98 765 432');

    // Confirm reservation with deposit
    final confirmBtn = find.textContaining('Confirm Reservation');
    expect(confirmBtn, findsOneWidget);
    await tester.ensureVisible(confirmBtn);
    await tester.tap(confirmBtn);
    await tester.pumpAndSettle();

    // Verify rental recorded deposit
    final rental = store.rentals.last;
    final expectedDeposit = (rental.totalCents * 0.30).round();
    expect(rental.paidCents, expectedDeposit);
    expect(rental.balanceCents, rental.totalCents - expectedDeposit);
    expect(rental.notes, contains('30% Deposit'));

    // Verify receipt shows deposit paid status
    expect(find.text('DEPOSIT CONFIRMED (30%)'), findsOneWidget);
    expect(find.text('Vannak Heng'), findsOneWidget);
  });

  testWidgets('RentalCart Pay at Pickup (On Arrival) records zero prepayment', (tester) async {
    tester.view.physicalSize = const Size(1280, 1600);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);

    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();
    final store = RentalStore(prefs);

    final vehicle = RentalStore.tiggo9Vehicle;
    final now = DateTime.now();
    final pickupDate = DateTime(now.year, now.month, now.day).add(const Duration(days: 1));
    final dueDate = pickupDate.add(const Duration(days: 1));

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

    // Select "Pay at Pickup"
    final arrivalTile = find.text('Pay at Pickup (Cash / Card)');
    await tester.ensureVisible(arrivalTile);
    await tester.tap(arrivalTile);
    await tester.pumpAndSettle();

    // Verify Cash on Arrival notice appears
    expect(find.text('Cash on Arrival'), findsOneWidget);

    // Fill customer info
    await tester.enterText(find.widgetWithText(TextField, 'Booking User Name *'), 'Sophea Lim');
    await tester.enterText(find.widgetWithText(TextField, 'Phone Number *'), '+855 77 112 233');

    // Confirm reservation on arrival
    final confirmBtn = find.textContaining('Confirm Reservation');
    expect(confirmBtn, findsOneWidget);
    await tester.ensureVisible(confirmBtn);
    await tester.tap(confirmBtn);
    await tester.pumpAndSettle();

    // Verify rental has 0 paid
    final rental = store.rentals.last;
    expect(rental.paidCents, 0);
    expect(rental.balanceCents, rental.totalCents);
    expect(rental.notes, contains('Pay at Pickup'));

    // Verify confirmation shows pay on arrival status
    expect(find.text('PAY ON ARRIVAL'), findsOneWidget);
  });

  testWidgets('RentalCart switches all payment terms, methods and receipts to Khmer', (tester) async {
    tester.view.physicalSize = const Size(1280, 1600);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);

    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();
    final store = RentalStore(prefs);
    store.setLanguage(AppLanguage.khmer);

    final vehicle = RentalStore.tiggo9Vehicle;
    final now = DateTime.now();
    final pickupDate = DateTime(now.year, now.month, now.day).add(const Duration(days: 2));
    final dueDate = pickupDate.add(const Duration(days: 2));

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

    // Verify Khmer labels in payment section
    expect(find.text('វិធីសាស្ត្រទូទាត់ប្រាក់ & លក្ខខណ្ឌ'), findsOneWidget);
    expect(find.text('ទូទាត់ពេញលេញ (100%)'), findsOneWidget);
    expect(find.text('បង់ប្រាក់កក់ 30%'), findsOneWidget);
    expect(find.text('ទូទាត់ពេលទទួលរថយន្ត (ប្រាក់សុទ្ធ / កាត)'), findsOneWidget);
    expect(find.text('ស្កេនទូទាត់តាម KHQR / ABA'), findsOneWidget);
    expect(find.text('កាតឥណទាន / ឥណពន្ធ'), findsOneWidget);

    // Fill customer info
    await tester.enterText(find.widgetWithText(TextField, 'ឈ្មោះអ្នកកក់រថយន្ត *'), 'សុខា ចាន់');
    await tester.enterText(find.widgetWithText(TextField, 'លេខទូរស័ព្ទ *'), '+855 12 333 444');

    // Confirm booking
    final confirmBtn = find.ancestor(
      of: find.textContaining('បញ្ជាក់ការកក់ទុក'),
      matching: find.byType(FilledButton),
    );
    expect(confirmBtn, findsOneWidget);
    await tester.ensureVisible(confirmBtn);
    await tester.tap(confirmBtn);
    await tester.pumpAndSettle();

    // Verify Khmer confirmation receipt
    expect(find.text('ប័ណ្ណបញ្ជាក់ការកក់រថយន្ត'), findsOneWidget);
    expect(find.text('បានទូទាត់ពេញ 100%'), findsOneWidget);
    expect(find.text('សុខា ចាន់'), findsOneWidget);
    expect(find.text('ត្រឡប់ទៅកាន់ទំព័ររថយន្ត'), findsOneWidget);
    expect(find.text('បោះពុម្ពវិក្កយបត្រ'), findsOneWidget);
  });
}
