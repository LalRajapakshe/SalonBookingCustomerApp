import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:salon_customer_app/app.dart';
import 'package:salon_customer_app/core/format/display_format.dart';
import 'package:salon_customer_app/features/catalog/data/mock_catalog.dart';

import 'support/pump_app.dart';

void main() {
  testWidgets('search and category filters stay on the device', (tester) async {
    await pumpSalonApp(tester);
    await tapVisible(tester, find.text('Explore'));

    await tester.enterText(find.byKey(const Key('explore-search')), 'balayage');
    await tester.pumpAndSettle();

    expect(find.text('Balayage and Gloss'), findsOneWidget);
    expect(find.text('Gel Manicure'), findsNothing);
    expect(find.text('Signature Blowout'), findsNothing);

    await tester.enterText(find.byKey(const Key('explore-search')), '');
    await tester.pumpAndSettle();

    await tester.scrollUntilVisible(
      find.byKey(const ValueKey('explore-category-nails')),
      100,
      scrollable: find.descendant(
        of: find.byKey(const Key('explore-category-scroller')),
        matching: find.byType(Scrollable),
      ),
    );
    await tester.tap(find.byKey(const ValueKey('explore-category-nails')));
    await tester.pumpAndSettle();

    expect(find.text('Gel Manicure'), findsOneWidget);
    expect(find.text('Soft Gel Extensions'), findsOneWidget);
    expect(find.text('Signature Blowout'), findsNothing);
  });

  testWidgets('an unknown search shows an empty state', (tester) async {
    await pumpSalonApp(tester);
    await tapVisible(tester, find.text('Explore'));
    await tester.enterText(find.byKey(const Key('explore-search')), 'no-such-service');
    await tester.pumpAndSettle();

    expect(find.text('No matches'), findsOneWidget);
    await tester.tap(find.text('Clear filters'));
    await tester.pumpAndSettle();
    expect(find.text('No matches'), findsNothing);

    await tester.scrollUntilVisible(
      find.byKey(const ValueKey('explore-service-svc-blowout')),
      300,
      scrollable: verticalScrollable(),
    );
    expect(find.byKey(const ValueKey('explore-service-svc-blowout')), findsOneWidget);
  });

  testWidgets('explore stays within the screen when the keyboard is open', (tester) async {
    tester.view.physicalSize = const Size(320, 640);
    tester.view.devicePixelRatio = 1;
    tester.view.viewInsets = const FakeViewPadding(bottom: 280);
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    addTearDown(tester.view.resetViewInsets);

    await tester.pumpWidget(const SalonCustomerApp(requireLogin: false));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Explore'));
    await tester.pumpAndSettle();
    await tester.enterText(find.byKey(const Key('explore-search')), 'glow');
    await tester.pumpAndSettle();

    expect(tester.takeException(), isNull);
    expect(find.text('Glow Facial'), findsOneWidget);
  });

  testWidgets('service details show price, duration, and booking entry', (tester) async {
    await pumpSalonApp(tester);
    await tapVisible(tester, find.text('Explore'));

    final service = MockCatalog.serviceById('svc-blowout')!;
    await tester.enterText(find.byKey(const Key('explore-search')), 'blowout');
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const ValueKey('explore-service-svc-blowout')));
    await tester.pumpAndSettle();

    expect(find.text(service.description), findsOneWidget);
    expect(find.text(DisplayFormat.money(service.price)), findsOneWidget);
    expect(find.text(DisplayFormat.duration(service.durationMinutes)), findsOneWidget);
    expect(find.text('Amara Jayawardena'), findsOneWidget);
    expect(find.text('Book appointment'), findsOneWidget);

    await tester.tap(find.byKey(const Key('book-appointment')));
    await tester.pumpAndSettle();
    expect(find.text('Choose a stylist'), findsOneWidget);

    await tester.pageBack();
    await tester.pumpAndSettle();
    expect(find.text('Choose a service'), findsOneWidget);

    await tester.pageBack();
    await tester.pumpAndSettle();
    expect(find.text('Book appointment'), findsOneWidget);
  });
}
