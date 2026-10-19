import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:vehicle_rental/main.dart';
import 'package:vehicle_rental/store.dart';
import 'package:vehicle_rental/src/localization/app_language.dart';
import 'package:vehicle_rental/src/screens/admin/widgets/customer_form_dialog.dart';
import 'package:vehicle_rental/src/screens/admin/widgets/customer_details_dialog.dart';

void main() {
  testWidgets('Customer CRUD: Create, Read, Update, Delete in Store and Dialogs', (tester) async {
    tester.view.physicalSize = const Size(1280, 1024);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);

    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();
    final store = RentalStore(prefs);

    // Initial count
    final initialCount = store.customers.length;

    // 1. CREATE CUSTOMER via CustomerFormDialog
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Builder(
            builder: (context) => ElevatedButton(
              onPressed: () => showDialog(
                context: context,
                builder: (_) => CustomerFormDialog(store: store),
              ),
              child: const Text('Open Add Customer'),
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.text('Open Add Customer'));
    await tester.pumpAndSettle();

    // Verify dialog fields
    expect(find.text('Add Customer'), findsNWidgets(2));
    await tester.enterText(find.widgetWithText(TextFormField, 'Full Name *'), 'Chan Dara');
    await tester.enterText(find.widgetWithText(TextFormField, 'Phone Number *'), '+855 12 999 888');
    await tester.enterText(find.widgetWithText(TextFormField, 'Email Address'), 'chandara@example.com');
    await tester.enterText(find.widgetWithText(TextFormField, "Driver's License / ID"), 'KH-DL-778899');
    await tester.enterText(find.widgetWithText(TextFormField, 'Address / Location'), 'BKK1, Phnom Penh');
    await tester.enterText(find.widgetWithText(TextFormField, 'Notes / Remarks'), 'VIP Customer');

    // Submit form
    final saveBtn = find.widgetWithText(FilledButton, 'Add Customer');
    await tester.tap(saveBtn);
    await tester.pumpAndSettle();

    // Verify customer added to store
    expect(store.customers.length, initialCount + 1);
    final newCustomer = store.customers.first;
    expect(newCustomer.name, 'Chan Dara');
    expect(newCustomer.phone, '+855 12 999 888');
    expect(newCustomer.email, 'chandara@example.com');
    expect(newCustomer.licenseNumber, 'KH-DL-778899');
    expect(newCustomer.address, 'BKK1, Phnom Penh');
    expect(newCustomer.notes, 'VIP Customer');

    // 2. UPDATE CUSTOMER via CustomerFormDialog
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Builder(
            builder: (context) => ElevatedButton(
              onPressed: () => showDialog(
                context: context,
                builder: (_) => CustomerFormDialog(store: store, customer: newCustomer),
              ),
              child: const Text('Open Edit Customer'),
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.text('Open Edit Customer'));
    await tester.pumpAndSettle();

    expect(find.text('Edit Customer'), findsOneWidget);
    // Change phone and notes
    await tester.enterText(find.widgetWithText(TextFormField, 'Phone Number *'), '+855 12 111 222');
    await tester.enterText(find.widgetWithText(TextFormField, 'Notes / Remarks'), 'VIP Customer • Corporate Account');

    await tester.tap(find.widgetWithText(FilledButton, 'Save Changes'));
    await tester.pumpAndSettle();

    final updatedCustomer = store.customers.firstWhere((c) => c.id == newCustomer.id);
    expect(updatedCustomer.phone, '+855 12 111 222');
    expect(updatedCustomer.notes, 'VIP Customer • Corporate Account');

    // 3. READ / VIEW CUSTOMER DETAILS
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Builder(
            builder: (context) => ElevatedButton(
              onPressed: () => showDialog(
                context: context,
                builder: (_) => CustomerDetailsDialog(
                  store: store,
                  customer: updatedCustomer,
                  onUpdated: () {},
                ),
              ),
              child: const Text('Open Customer Details'),
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.text('Open Customer Details'));
    await tester.pumpAndSettle();

    expect(find.text('Chan Dara'), findsOneWidget);
    expect(find.text('KH-DL-778899'), findsOneWidget);
    expect(find.text('BKK1, Phnom Penh'), findsOneWidget);
    expect(find.text('Total Bookings'), findsOneWidget);

    // 4. DELETE CUSTOMER
    await tester.tap(find.text('Delete Customer'));
    await tester.pumpAndSettle();

    expect(find.text('Are you sure you want to delete this customer? This action cannot be undone.'), findsOneWidget);
    await tester.tap(find.widgetWithText(FilledButton, 'Delete'));
    await tester.pumpAndSettle();

    expect(store.customers.any((c) => c.id == newCustomer.id), isFalse);
    expect(store.customers.length, initialCount);
  });

  testWidgets('Customer CRUD: Admin Workspace integrates full Customer List and KPI Metrics', (tester) async {
    tester.view.physicalSize = const Size(1440, 1024);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);

    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();
    final store = RentalStore(prefs);

    await tester.pumpWidget(
      MaterialApp(
        home: RentalHome(store: store),
      ),
    );
    await tester.pumpAndSettle();

    // Navigate to Admin Hub
    final adminNav = find.text('Admin Hub');
    if (adminNav.evaluate().isNotEmpty) {
      await tester.tap(adminNav);
      await tester.pumpAndSettle();
    }

    // Switch to Customers tab (Page 4)
    final customersTab = find.text('Customers');
    expect(customersTab, findsWidgets);
    await tester.tap(customersTab.first);
    await tester.pumpAndSettle();

    // Verify KPI Metrics
    expect(find.text('Total Customers'), findsOneWidget);
    expect(find.text('Active Renters'), findsOneWidget);
    expect(find.text('Total Spent'), findsOneWidget);

    // Verify Customers displayed with CRUD actions
    expect(find.text('Ayesha Khan'), findsOneWidget);
    expect(find.byIcon(Icons.visibility_outlined), findsWidgets);
    expect(find.byIcon(Icons.edit_outlined), findsWidgets);
    expect(find.byIcon(Icons.delete_outline_rounded), findsWidgets);

    // Switch to Khmer
    store.setLanguage(AppLanguage.khmer);
    await tester.pumpAndSettle();

    // Verify Khmer labels
    expect(find.text('អតិថិជនសរុប'), findsOneWidget);
    expect(find.text('កំពុងជួលរថយន្ត'), findsOneWidget);
    expect(find.text('ចំណាយសរុប'), findsOneWidget);
  });
}
