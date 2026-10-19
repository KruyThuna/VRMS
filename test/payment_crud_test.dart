import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:vehicle_rental/main.dart';
import 'package:vehicle_rental/store.dart';
import 'package:vehicle_rental/src/screens/admin/widgets/payment_form_dialog.dart';
import 'package:vehicle_rental/src/screens/admin/widgets/payment_details_dialog.dart';

void main() {
  testWidgets(
      'Payment CRUD: Store operations (Record, Settle, Update, Reset, Stats)',
      (tester) async {
    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();
    final store = RentalStore(prefs);

    final rental = store.rentals.first;
    final total = rental.totalCents;

    // 1. Check initial stats
    expect(store.totalRentalBilledCents, greaterThan(0));
    expect(store.totalRentalRevenueCents, greaterThanOrEqualTo(0));
    expect(store.totalRentalReceivablesCents, greaterThanOrEqualTo(0));

    // 2. Partial payment
    final initialPaid = rental.paidCents;
    await store.recordRentalPayment(rental.id, 1000);
    expect(store.rentals.first.paidCents, (initialPaid + 1000).clamp(0, total));

    // 3. Settle in full
    await store.settleRentalPayment(rental.id);
    expect(store.rentals.first.paidCents, total);
    expect(store.rentals.first.balanceCents, 0);
    expect(store.fullyPaidRentalsCount, greaterThanOrEqualTo(1));

    // 4. Update payment amount & note
    await store.updateRentalPayment(rental.id, 2500,
        notes: 'Adjusted by Admin');
    expect(store.rentals.first.paidCents, 2500);
    expect(store.rentals.first.notes, 'Adjusted by Admin');

    // 5. Reset to $0
    await store.resetRentalPayment(rental.id);
    expect(store.rentals.first.paidCents, 0);
    expect(store.rentals.first.balanceCents, total);
    expect(store.unpaidRentalsCount, greaterThanOrEqualTo(1));
  });

  testWidgets('Payment CRUD: PaymentFormDialog records and adjusts payment',
      (tester) async {
    tester.view.physicalSize = const Size(1280, 1024);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() => tester.view.resetPhysicalSize());

    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();
    final store = RentalStore(prefs);

    final rental = store.rentals.first;
    await store.resetRentalPayment(rental.id);

    bool saved = false;

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Builder(
            builder: (ctx) => ElevatedButton(
              onPressed: () => showDialog(
                context: ctx,
                builder: (_) => PaymentFormDialog(
                  store: store,
                  preselectedRental: rental,
                  onSaved: () => saved = true,
                ),
              ),
              child: const Text('Open Payment Form'),
            ),
          ),
        ),
      ),
    );

    // Open Dialog
    await tester.tap(find.text('Open Payment Form'));
    await tester.pumpAndSettle();

    // Verify dialog header and vehicle info
    expect(find.text('Record Rental Payment'), findsOneWidget);
    expect(find.byType(DropdownButtonFormField<String>), findsOneWidget);

    // Verify Quick Presets
    final fullPreset = find.text('Full Balance');
    expect(fullPreset, findsOneWidget);
    await tester.tap(fullPreset);
    await tester.pumpAndSettle();

    // Switch payment method to Cash
    final cashChip = find.text('Cash');
    expect(cashChip, findsOneWidget);
    await tester.tap(cashChip);
    await tester.pumpAndSettle();

    // Tap confirm payment button
    final confirmBtn = find.text('Confirm Payment');
    expect(confirmBtn, findsOneWidget);
    await tester.tap(confirmBtn);
    await tester.pumpAndSettle();

    expect(saved, isTrue);
    final updated = store.rentals.firstWhere((r) => r.id == rental.id);
    expect(updated.paidCents, updated.totalCents);
    expect(updated.notes, contains('Method: Cash'));
  });

  testWidgets(
      'Payment CRUD: PaymentDetailsDialog shows full invoice and actions',
      (tester) async {
    tester.view.physicalSize = const Size(1280, 1024);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() => tester.view.resetPhysicalSize());

    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();
    final store = RentalStore(prefs);

    final rental = store.rentals.first;
    bool updated = false;

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Builder(
            builder: (ctx) => ElevatedButton(
              onPressed: () => showDialog(
                context: ctx,
                builder: (_) => PaymentDetailsDialog(
                  store: store,
                  rental: rental,
                  onUpdated: () => updated = true,
                ),
              ),
              child: const Text('Open Invoice'),
            ),
          ),
        ),
      ),
    );

    // Open Invoice Dialog
    await tester.tap(find.text('Open Invoice'));
    await tester.pumpAndSettle();

    // Verify invoice header
    expect(find.text('Official Payment Receipt & Invoice'), findsOneWidget);
    expect(find.text('REC-${rental.id}'), findsOneWidget);
    expect(find.text('Financial Statement'), findsOneWidget);

    // Check action buttons
    expect(find.text('Reset \$0'), findsOneWidget);
    expect(find.text('Edit'), findsOneWidget);

    // Settle full payment if button is present
    final settleBtn = find.text('Settle Full');
    if (settleBtn.evaluate().isNotEmpty) {
      await tester.tap(settleBtn);
      await tester.pumpAndSettle();
      expect(updated, isTrue);
      final settledRental = store.rentals.firstWhere((r) => r.id == rental.id);
      expect(settledRental.balanceCents, 0);
    }
  });

  testWidgets(
      'Payment CRUD: Admin Workspace integrates full Payments Ledger & KPI Metrics',
      (tester) async {
    tester.view.physicalSize = const Size(1280, 1024);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() => tester.view.resetPhysicalSize());

    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();
    final store = RentalStore(prefs);

    await tester.pumpWidget(
      MaterialApp(
        home: RentalHome(store: store),
      ),
    );
    await tester.pumpAndSettle();

    // Navigate to Payments tab (index 6: 'Payments' in English)
    final paymentsNav = find.text(store.t('payments'));
    expect(paymentsNav, findsOneWidget);
    await tester.tap(paymentsNav);
    await tester.pumpAndSettle();

    // Verify Action button in top bar
    expect(find.text(store.t('record_new_payment')), findsOneWidget);

    // Verify KPI Cards
    expect(find.text(store.t('total_billed')), findsOneWidget);
    expect(find.text(store.t('total_collected')), findsOneWidget);
    expect(find.text(store.t('total_receivables')), findsOneWidget);

    // Verify Filter chips
    expect(find.text(store.t('filter_all')), findsOneWidget);

    // Verify payment card action buttons
    expect(find.byIcon(Icons.receipt_rounded), findsWidgets);

    // Tap record payment in top bar to open dialog
    await tester.tap(find.text(store.t('record_new_payment')));
    await tester.pumpAndSettle();
    expect(find.byType(PaymentFormDialog), findsOneWidget);

    // Close dialog
    await tester.tap(find.byIcon(Icons.close_rounded));
    await tester.pumpAndSettle();
    expect(find.byType(PaymentFormDialog), findsNothing);
  });
}
