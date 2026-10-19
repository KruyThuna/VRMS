import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:vehicle_rental/main.dart';
import 'package:vehicle_rental/store.dart';
import 'package:vehicle_rental/src/localization/app_language.dart';
import 'package:vehicle_rental/src/screens/admin/widgets/brand_breakdown_table.dart';
import 'package:vehicle_rental/src/screens/admin/widgets/category_analytics_card.dart';
import 'package:vehicle_rental/src/screens/admin/widgets/post_vehicle_dialog.dart';

void main() {
  testWidgets('BrandBreakdownTable renders brands, fleet sizes, and handles selection', (tester) async {
    tester.view.physicalSize = const Size(1280, 1024);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() => tester.view.resetPhysicalSize());

    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();
    final store = RentalStore(prefs);

    String? selectedBrand;

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: SingleChildScrollView(
            child: BrandBreakdownTable(
              store: store,
              onSelectBrand: (brand) => selectedBrand = brand,
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    // Verify Title & Subtitle
    expect(find.text('Brand Performance Matrix'), findsOneWidget);
    expect(find.textContaining('Fleet distribution, asset valuation'), findsOneWidget);

    // Verify Brands present in inventory
    expect(find.text('CHERY'), findsWidgets);
    expect(find.text('TOYOTA'), findsWidgets);

    // Tap View Fleet button on CHERY brand
    final viewButtons = find.text('View Fleet');
    expect(viewButtons, findsWidgets);
    await tester.ensureVisible(viewButtons.first);
    await tester.tap(viewButtons.first);
    await tester.pumpAndSettle();

    expect(selectedBrand, isNotNull);
  });

  testWidgets('CategoryAnalyticsCard renders category metrics and triggers filter', (tester) async {
    tester.view.physicalSize = const Size(1280, 1024);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() => tester.view.resetPhysicalSize());

    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();
    final store = RentalStore(prefs);

    String? selectedCategory;

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: SingleChildScrollView(
            child: CategoryAnalyticsCard(
              store: store,
              onSelectCategory: (cat) => selectedCategory = cat,
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    // Verify Title & Categories
    expect(find.text('Category Distribution & Analytics'), findsOneWidget);
    expect(find.text('SUV'), findsWidgets);
    expect(find.text('Electric'), findsWidgets);

    // Tap on SUV card
    await tester.tap(find.text('SUV').first);
    await tester.pumpAndSettle();

    expect(selectedCategory, 'SUV');
  });

  testWidgets('RentalHome Executive Dashboard integrates Brand Table and switches to filtered Fleet', (tester) async {
    tester.view.physicalSize = const Size(1400, 1024);
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

    // Verify Executive KPIs
    expect(find.text('Available Fleet'), findsOneWidget);
    expect(find.text('Active Banners'), findsOneWidget);
    expect(find.text('Total Inventory Value'), findsOneWidget);

    // Verify Brand Breakdown Table on dashboard
    expect(find.text('Brand Performance Matrix'), findsOneWidget);

    // Tap "View Fleet" on the first brand in the table
    final viewBtn = find.text('View Fleet').first;
    await tester.ensureVisible(viewBtn);
    await tester.tap(viewBtn);
    await tester.pumpAndSettle();

    // Verify we navigated to page 1 (Fleet & Products)
    expect(find.text('Fleet & Products'), findsWidgets);
    expect(find.text('Reset Filters'), findsOneWidget);
  });

  testWidgets('PostVehicleDialog creates new vehicle and adds to fleet', (tester) async {
    tester.view.physicalSize = const Size(1280, 1024);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() => tester.view.resetPhysicalSize());

    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();
    final store = RentalStore(prefs);

    final initialCount = store.vehicles.length;
    String? messageSent;

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Builder(
            builder: (context) => ElevatedButton(
              onPressed: () {
                showDialog(
                  context: context,
                  builder: (ctx) => PostVehicleDialog(
                    store: store,
                    onMessage: (msg) => messageSent = msg,
                  ),
                );
              },
              child: const Text('Open Dialog'),
            ),
          ),
        ),
      ),
    );

    // Open dialog
    await tester.tap(find.text('Open Dialog'));
    await tester.pumpAndSettle();

    expect(find.text('Post New Fleet Product'), findsOneWidget);

    // Fill model name
    final nameField = find.widgetWithText(TextField, 'Car Model Name *');
    await tester.enterText(nameField, 'Chery Arrizo 8');

    // Tap TOYOTA brand quick pick chip
    await tester.tap(find.text('TOYOTA'));
    await tester.pumpAndSettle();

    // Tap Post Product
    await tester.tap(find.text('Post Product'));
    await tester.pumpAndSettle();

    // Verify new vehicle was added to store
    expect(store.vehicles.length, initialCount + 1);
    expect(store.vehicles.first.name, 'Chery Arrizo 8');
    expect(store.vehicles.first.brand, 'TOYOTA');
    expect(messageSent, contains('Chery Arrizo 8'));
  });

  testWidgets('Dashboard translates all telemetry and brand tables to Khmer', (tester) async {
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

    // Verify Khmer headers & labels in dashboard
    expect(find.text('តារាងវិភាគតាមម៉ាករថយន្ត'), findsOneWidget);
    expect(find.text('ការវិភាគ និងចែកចាយតាមប្រភេទរថយន្ត'), findsOneWidget);
    expect(find.text('ប្រតិបត្តិការរហ័ស'), findsOneWidget);
    expect(find.text('បន្ថែមផលិតផលរថយន្តថ្មី'), findsWidgets);
  });
}

