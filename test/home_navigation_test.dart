import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:salon_customer_app/app.dart';
import 'package:salon_customer_app/features/catalog/data/mock_catalog.dart';

import 'support/pump_app.dart';

void main() {
  testWidgets('home shows the customer landing sections', (tester) async {
    await pumpSalonApp(tester);

    expect(find.text('Lumière'), findsOneWidget);
    expect(find.text(MockCatalog.customer.firstName), findsOneWidget);
    expect(find.text('Categories'), findsOneWidget);
    expect(find.text('Popular services'), findsOneWidget);
    expect(find.text('Book a visit'), findsOneWidget);
    expect(find.byKey(const ValueKey('home-category-hair')), findsOneWidget);

    await tester.scrollUntilVisible(
      find.text('Stylists'),
      400,
      scrollable: verticalScrollable(),
    );
    expect(find.text('Stylists'), findsOneWidget);

    await tester.scrollUntilVisible(
      find.text('Kollupitiya'),
      300,
      scrollable: verticalScrollable(),
    );
    expect(find.text('Studios'), findsOneWidget);
    expect(find.text('Kollupitiya'), findsOneWidget);
    expect(find.text('4.9'), findsWidgets);

    await tester.scrollUntilVisible(
      find.text('Offers'),
      400,
      scrollable: verticalScrollable(),
    );
    expect(find.text('Offers'), findsOneWidget);
    expect(find.text('Facials worth leaving the house for'), findsOneWidget);
  });

  testWidgets('bottom navigation opens explore, bookings, and profile', (tester) async {
    await pumpSalonApp(tester);

    await tapVisible(tester, find.text('Explore'));
    expect(find.text('Discover'), findsOneWidget);

    await tapVisible(tester, find.text('Bookings'));
    expect(find.text('My bookings'), findsOneWidget);
    expect(find.text('No upcoming visits yet'), findsOneWidget);

    await tapVisible(tester, find.text('Past'));
    expect(find.text('Gel Manicure'), findsOneWidget);
    expect(find.text('Noah Silva'), findsOneWidget);
    expect(find.text('Completed'), findsOneWidget);

    await tapVisible(tester, find.text('Profile'));
    expect(find.text(MockCatalog.customer.fullName), findsOneWidget);
    expect(find.text(MockCatalog.customer.email), findsOneWidget);
    expect(find.text(MockCatalog.customer.phone), findsOneWidget);
  });

  testWidgets('profile actions explain that account changes are not available', (tester) async {
    await pumpSalonApp(tester);
    await tapVisible(tester, find.text('Profile'));
    await tapVisible(tester, find.byKey(const Key('profile-edit')));

    expect(find.text('Not available yet'), findsOneWidget);
    expect(
      find.text('Profile changes are not part of this preview.'),
      findsOneWidget,
    );

    await tester.tap(find.text('Close'));
    await tester.pumpAndSettle();
    expect(find.text('Not available yet'), findsNothing);
  });

  testWidgets('tabs stay within a narrow phone layout', (tester) async {
    tester.view.physicalSize = const Size(320, 700);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(const SalonCustomerApp(requireLogin: false));
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);

    for (final label in ['Explore', 'Bookings', 'Profile', 'Home']) {
      await tester.tap(find.text(label));
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
    }

    await tester.tap(find.text('Bookings'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Past'));
    await tester.pumpAndSettle();
    expect(find.text('Gel Manicure'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
