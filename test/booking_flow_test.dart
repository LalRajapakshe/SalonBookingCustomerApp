import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:salon_customer_app/core/format/display_format.dart';
import 'package:salon_customer_app/features/booking/data/mock_availability.dart';
import 'package:salon_customer_app/features/catalog/data/mock_catalog.dart';

import 'support/pump_app.dart';

void main() {
  testWidgets('booking cannot continue without a service', (tester) async {
    await pumpSalonApp(tester);
    await tapVisible(tester, find.byKey(const Key('start-booking')));

    expect(find.text('Choose a service'), findsOneWidget);
    await tester.tap(find.byKey(const Key('booking-next')));
    await tester.pumpAndSettle();
    expect(find.text('Choose a service'), findsOneWidget);
    expect(find.text('Select a service to continue.'), findsOneWidget);
  });

  testWidgets('a confirmed visit appears in upcoming bookings', (tester) async {
    await pumpSalonApp(tester);
    await tapVisible(tester, find.byKey(const Key('start-booking')));

    await tapVisible(tester, find.byKey(const ValueKey('pick-service-svc-blowout')));
    await tester.tap(find.byKey(const Key('booking-next')));
    await tester.pumpAndSettle();

    expect(find.text('Choose a stylist'), findsOneWidget);
    await tester.tap(find.byKey(const Key('booking-next')));
    await tester.pumpAndSettle();
    expect(find.text('Choose a stylist'), findsOneWidget);

    await tapVisible(tester, find.byKey(const ValueKey('pick-stylist-any')));
    await tester.tap(find.byKey(const Key('booking-next')));
    await tester.pumpAndSettle();

    await tapVisible(tester, find.byKey(const ValueKey('pick-date-1')));
    await tester.tap(find.byKey(const Key('booking-next')));
    await tester.pumpAndSettle();

    final tomorrow = DateTime.now().add(const Duration(days: 1));
    final date = DateTime(tomorrow.year, tomorrow.month, tomorrow.day);
    final slot = MockAvailability.slotsFor(
      date: date,
      stylistId: MockCatalog.anyStylistId,
    ).firstWhere((item) => item.available);
    final slotKey = ValueKey<String>(MockAvailability.slotKey(slot.time));

    await tester.scrollUntilVisible(find.byKey(slotKey), 240);
    await tester.tap(find.byKey(slotKey));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('booking-next')));
    await tester.pumpAndSettle();

    final service = MockCatalog.serviceById('svc-blowout')!;
    expect(find.text('Review'), findsOneWidget);
    expect(
      find.descendant(
        of: find.byKey(const Key('booking-summary')),
        matching: find.text(service.name),
      ),
      findsOneWidget,
    );
    expect(
      find.descendant(
        of: find.byKey(const Key('booking-summary')),
        matching: find.text(MockCatalog.anyStylistLabel),
      ),
      findsOneWidget,
    );
    expect(
      find.descendant(
        of: find.byKey(const Key('booking-summary')),
        matching: find.text(DisplayFormat.money(service.price)),
      ),
      findsOneWidget,
    );
    expect(
      find.descendant(
        of: find.byKey(const Key('booking-summary')),
        matching: find.text(DisplayFormat.duration(service.durationMinutes)),
      ),
      findsOneWidget,
    );
    expect(
      find.descendant(
        of: find.byKey(const Key('booking-summary')),
        matching: find.text(DisplayFormat.date(date)),
      ),
      findsOneWidget,
    );
    expect(
      find.descendant(
        of: find.byKey(const Key('booking-summary')),
        matching: find.text(DisplayFormat.time(slot.time)),
      ),
      findsOneWidget,
    );

    await tester.tap(find.byKey(const Key('booking-next')));
    await tester.pumpAndSettle();

    expect(find.text("You're booked"), findsOneWidget);
    expect(find.text('Saved in this session.'), findsOneWidget);
    expect(find.text(service.name), findsWidgets);

    await tester.tap(find.byKey(const Key('view-bookings')));
    await tester.pumpAndSettle();

    expect(find.text('My bookings'), findsOneWidget);
    expect(find.text('No upcoming visits yet'), findsNothing);
    expect(find.text(service.name), findsOneWidget);
    expect(find.text(MockCatalog.anyStylistLabel), findsOneWidget);
    expect(find.text('Confirmed'), findsOneWidget);
    expect(find.textContaining(DisplayFormat.time(slot.time)), findsOneWidget);
  });
}
