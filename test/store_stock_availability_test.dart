import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:vehicle_rental/store.dart';
import 'package:vehicle_rental/storefront.dart';
import 'package:vehicle_rental/src/localization/app_language.dart';
import 'package:vehicle_rental/src/screens/storefront/widgets/professional_car_detail_card.dart';

void main() {
  testWidgets('Storefront displays Showroom Fleet Stock metrics, badges, and filters', (tester) async {
    tester.view.physicalSize = const Size(1280, 1600);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() => tester.view.resetPhysicalSize());

    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();
    final store = RentalStore(prefs);

    await tester.pumpWidget(
      MaterialApp(
        home: Storefront(
          store: store,
          managementBuilder: (_) => const SizedBox(),
        ),
      ),
    );
    await tester.pumpAndSettle();

    // 1. Verify Showroom Stock & Fleet Status section header
    final headerFinder = find.textContaining('SHOWROOM STOCK & FLEET STATUS');
    await tester.ensureVisible(headerFinder);
    await tester.pumpAndSettle();
    expect(headerFinder, findsOneWidget);

    // 2. Verify Stock Filter Chips with live metrics
    final allChip = find.text('All Fleet (8)');
    final availChip = find.text('Available in Stock (6)');
    final unavailChip = find.text('Unavailable / Booked (2)');

    expect(allChip, findsOneWidget);
    expect(availChip, findsOneWidget);
    expect(unavailChip, findsOneWidget);

    // 3. Verify Stock Badges are rendered on vehicle cards
    expect(find.text('AVAILABLE IN STOCK'), findsWidgets);
    expect(find.text('CURRENTLY BOOKED'), findsWidgets);

    // 4. Test filtering by 'Unavailable / Booked'
    await tester.ensureVisible(unavailChip);
    await tester.tap(unavailChip);
    await tester.pumpAndSettle();

    // In unavailable view, only unavailable vehicles should be displayed
    expect(find.text('AVAILABLE IN STOCK'), findsNothing);
    expect(find.text('CURRENTLY BOOKED'), findsWidgets);

    // 5. Test filtering by 'Available in Stock'
    await tester.ensureVisible(availChip);
    await tester.tap(availChip);
    await tester.pumpAndSettle();

    // In available view, all displayed cars should have 'AVAILABLE IN STOCK'
    expect(find.text('AVAILABLE IN STOCK'), findsWidgets);
    expect(find.text('CURRENTLY BOOKED'), findsNothing);

    // 6. Reset back to 'All Fleet'
    await tester.ensureVisible(allChip);
    await tester.tap(allChip);
    await tester.pumpAndSettle();
    expect(find.text('AVAILABLE IN STOCK'), findsWidgets);
    expect(find.text('CURRENTLY BOOKED'), findsWidgets);
  });

  testWidgets('Attempting to reserve an unavailable vehicle triggers the guidance dialog', (tester) async {
    tester.view.physicalSize = const Size(1280, 1600);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() => tester.view.resetPhysicalSize());

    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();
    final store = RentalStore(prefs);

    await tester.pumpWidget(
      MaterialApp(
        home: Storefront(
          store: store,
          managementBuilder: (_) => const SizedBox(),
        ),
      ),
    );
    await tester.pumpAndSettle();

    // Filter to unavailable cars
    final unavailChip = find.text('Unavailable / Booked (2)');
    await tester.ensureVisible(unavailChip);
    await tester.tap(unavailChip);
    await tester.pumpAndSettle();

    // Find the reservation button on an unavailable card
    final unavailableButton = find.byTooltip('CURRENTLY BOOKED');
    expect(unavailableButton, findsWidgets);

    await tester.ensureVisible(unavailableButton.first);
    await tester.tap(unavailableButton.first);
    await tester.pumpAndSettle();

    // Verify the guidance dialog appears
    expect(find.text('Vehicle Unavailable for Selected Dates'), findsOneWidget);
    expect(find.text('Adjust Rental Dates'), findsOneWidget);
    expect(find.text('Show Available Fleet'), findsOneWidget);

    // Tap Show Available Fleet
    await tester.tap(find.text('Show Available Fleet'));
    await tester.pumpAndSettle();

    // Dialog should be dismissed and filter switched to Available
    expect(find.text('Vehicle Unavailable for Selected Dates'), findsNothing);
    expect(find.text('AVAILABLE IN STOCK'), findsWidgets);
    expect(find.text('CURRENTLY BOOKED'), findsNothing);
  });

  testWidgets('ProfessionalCarDetailCard respects vehicle availability and status in Khmer', (tester) async {
    tester.view.physicalSize = const Size(1280, 900);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() => tester.view.resetPhysicalSize());

    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();
    final store = RentalStore(prefs);
    final rentedCar = store.vehicles.firstWhere((v) => store.vehicleStatus(v) == 'Rented');

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: ProfessionalCarDetailCard(
            vehicle: rentedCar,
            isAvailable: false,
            vehicleStatus: 'Rented',
            isInCart: false,
            language: AppLanguage.khmer,
            onAddToCart: () {},
            onClose: () {},
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    // Status badge should show Khmer for Rented/Booked
    expect(find.text('បានកក់ទុក / កំពុងជួល'), findsWidgets);
  });

  testWidgets('Single card in 4-grid maintains 1/4th column width without stretching to 100%', (tester) async {
    tester.view.physicalSize = const Size(1280, 1600);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() => tester.view.resetPhysicalSize());

    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();
    final store = RentalStore(prefs);

    await tester.pumpWidget(
      MaterialApp(
        home: Storefront(
          store: store,
          managementBuilder: (_) => const SizedBox(),
        ),
      ),
    );
    await tester.pumpAndSettle();

    // Verify 'All' category chip is not duplicated
    final allCategoryChips = find.widgetWithText(ChoiceChip, 'All');
    expect(allCategoryChips, findsOneWidget);

    // Select 'Luxury' category (which contains only BMW 4 Series)
    final luxuryChip = find.text('Luxury');
    await tester.ensureVisible(luxuryChip);
    await tester.tap(luxuryChip);
    await tester.pumpAndSettle();

    // Verify only 1 card is displayed
    final bmwText = find.text('BMW 4 Series');
    expect(bmwText, findsOneWidget);

    // Verify card width is approximately 1/4th of the 1200px container (~285px) and NOT 1200px!
    final cardSize = tester.getSize(find.ancestor(of: bmwText, matching: find.byType(SizedBox)).first);
    expect(cardSize.width, lessThan(350.0));
    expect(cardSize.width, greaterThan(250.0));
  });
}
