import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:vehicle_rental/main.dart';
import 'package:vehicle_rental/store.dart';
import 'package:vehicle_rental/src/localization/app_language.dart';
import 'package:vehicle_rental/src/localization/app_translations.dart';
import 'package:vehicle_rental/src/screens/storefront/widgets/professional_booking_date_dialog.dart';
import 'package:vehicle_rental/src/screens/storefront/widgets/professional_car_detail_card.dart';

void main() {
  test('AppTranslations dictionary returns correct English and Khmer strings', () {
    expect(AppTranslations.tr('home', AppLanguage.english), 'Home');
    expect(AppTranslations.tr('home', AppLanguage.khmer), 'ទំព័រដើម');

    expect(AppTranslations.tr('browse_cars', AppLanguage.english), 'Browse Our Cars');
    expect(AppTranslations.tr('browse_cars', AppLanguage.khmer), 'ស្វែងរករថយន្តរបស់យើង');

    expect(AppTranslations.tr('cart', AppLanguage.english), 'Reservation Cart');
    expect(AppTranslations.tr('cart', AppLanguage.khmer), 'កន្ត្រកកក់រថយន្ត');

    expect(AppTranslations.tr('engine', AppLanguage.english), 'Engine');
    expect(AppTranslations.tr('engine', AppLanguage.khmer), 'កម្លាំងម៉ាស៊ីន');
  });

  test('RentalStore switches and persists language correctly', () async {
    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();
    final store = RentalStore(prefs);

    expect(store.language, AppLanguage.english);

    int notifications = 0;
    store.addListener(() => notifications++);

    store.setLanguage(AppLanguage.khmer);
    expect(store.language, AppLanguage.khmer);
    expect(notifications, 1);
    expect(store.t('admin_workspace'), 'ផ្ទាំងគ្រប់គ្រងរដ្ឋបាល');

    // Reload from SharedPreferences
    final reloaded = RentalStore(prefs);
    expect(reloaded.language, AppLanguage.khmer);

    store.setLanguage(AppLanguage.english);
    expect(store.language, AppLanguage.english);
    expect(store.t('admin_workspace'), 'Admin Workspace');
  });

  testWidgets('ProfessionalBookingDateDialog renders in Khmer when language is set to Khmer', (tester) async {
    tester.view.physicalSize = const Size(1280, 900);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() => tester.view.resetPhysicalSize());

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: ProfessionalBookingDateDialog(
            initialStart: DateTime(2026, 10, 15),
            initialEnd: DateTime(2026, 10, 18),
            language: AppLanguage.khmer,
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('កាលវិភាគ & រយៈពេលជួល'), findsOneWidget);
    expect(find.text('កាលបរិច្ឆេទទទួលរថយន្ត'), findsOneWidget);
    expect(find.textContaining('បញ្ជាក់ការកក់'), findsOneWidget);
  });

  testWidgets('ProfessionalCarDetailCard renders in Khmer when language is set to Khmer', (tester) async {
    tester.view.physicalSize = const Size(1280, 900);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() => tester.view.resetPhysicalSize());

    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();
    final store = RentalStore(prefs);
    final tiggo = store.vehicles.firstWhere((v) => v.id == 'v_tiggo9');

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: ProfessionalCarDetailCard(
            vehicle: tiggo,
            isInCart: false,
            language: AppLanguage.khmer,
            onAddToCart: () {},
            onClose: () {},
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('លក្ខណៈបច្ចេកទេសដំណើរការ'), findsOneWidget);
    expect(find.text('ល្បឿនអតិបរមា'), findsOneWidget);
    expect(find.text('ដាក់ក្នុងកន្ត្រក'), findsOneWidget);
  });

  testWidgets('App reactive toggle dynamically switches all text between Khmer and English', (tester) async {
    tester.view.physicalSize = const Size(1280, 900);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() => tester.view.resetPhysicalSize());

    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();
    final store = RentalStore(prefs);

    await tester.pumpWidget(DriveLineApp(store: store));
    await tester.pumpAndSettle();

    // Verify initial English
    expect(find.text('FEATURED CARS'), findsOneWidget);

    // Switch to Khmer
    store.setLanguage(AppLanguage.khmer);
    await tester.pumpAndSettle();

    // Verify Khmer text
    expect(find.text('រថយន្តពិសេស'), findsOneWidget);

    // Test 1-click language switcher pill tapping
    await tester.tap(find.text('ខ្មែរ').first);
    await tester.pumpAndSettle();
    expect(store.language, AppLanguage.khmer);
    expect(find.text('រថយន្តពិសេស'), findsOneWidget);

    await tester.tap(find.text('EN').first);
    await tester.pumpAndSettle();
    expect(store.language, AppLanguage.english);
    expect(find.text('FEATURED CARS'), findsOneWidget);
  });

  testWidgets('Interactive service cards open dedicated modals when tapped', (tester) async {
    tester.view.physicalSize = const Size(1280, 900);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() => tester.view.resetPhysicalSize());

    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();
    final store = RentalStore(prefs);

    await tester.pumpWidget(DriveLineApp(store: store));
    await tester.pumpAndSettle();

    // Tap on Monthly & Corporate Fleet service card
    await tester.scrollUntilVisible(
      find.text('Monthly & Corporate Fleet'),
      500,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.pumpAndSettle();
    await tester.tap(find.text('Monthly & Corporate Fleet'));
    await tester.pumpAndSettle();

    // Verify Monthly & Corporate Fleet Dialog opened
    expect(find.text('Monthly & Corporate Fleet'), findsWidgets);
    await tester.tap(find.text('Close'));
    await tester.pumpAndSettle();

    // Tap on Airport & Doorstep Delivery
    await tester.tap(find.text('Airport & Doorstep Delivery'));
    await tester.pumpAndSettle();

    // Verify Airport & Doorstep Delivery Dialog opened
    expect(find.text('Airport & Doorstep Delivery'), findsWidgets);
    await tester.tap(find.text('Close'));
    await tester.pumpAndSettle();

    // Tap on Full Insurance & 24/7 Rescue
    await tester.tap(find.text('Full Insurance & 24/7 Rescue'));
    await tester.pumpAndSettle();

    // Verify Vehicle Inspection Dialog opened
    expect(find.text('150+ Point Vehicle Inspection'), findsOneWidget);
    await tester.tap(find.text('Close'));
    await tester.pumpAndSettle();
  });
}

