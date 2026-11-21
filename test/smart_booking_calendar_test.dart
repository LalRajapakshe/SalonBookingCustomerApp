import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:salon_customer_app/core/format/display_format.dart';
import 'package:salon_customer_app/core/navigation/app_navigation.dart';
import 'package:salon_customer_app/core/theme/app_theme.dart';
import 'package:salon_customer_app/features/catalog/data/mock_catalog.dart';
import 'package:salon_customer_app/features/smart_booking_calendar/data/demo_availability.dart';
import 'package:salon_customer_app/features/smart_booking_calendar/screens/smart_calendar_screen.dart';
import 'package:salon_customer_app/features/smart_booking_calendar/state/calendar_controller.dart';
import 'package:salon_customer_app/features/smart_booking_calendar/state/calendar_scope.dart';
import 'package:salon_customer_app/features/smart_booking_calendar/widgets/month_calendar.dart';
import 'package:salon_customer_app/shared/widgets/app_primary_button.dart';

import 'support/pump_app.dart';

void main() {
  final saturdayNoon = DateTime(2026, 10, 17, 12);

  test('demo slots skip past times, empty days, and booked ids', () {
    final saturday = DemoAvailability.slotsFor(
      date: DateTime(2026, 10, 17),
      now: saturdayNoon,
    );
    expect(saturday.map((slot) => slot.start.hour), [15]);
    expect(saturday.single.start.minute, 0);

    final mondayMorning = DateTime(2026, 10, 19, 10);
    final monday = DemoAvailability.slotsFor(
      date: mondayMorning,
      now: mondayMorning,
    );
    expect(monday.map((slot) => slot.start.hour), isNot(contains(10)));
    expect(monday.first.start, DateTime(2026, 10, 19, 11, 30));

    expect(
      DemoAvailability.slotsFor(
        date: DateTime(2026, 10, 18),
        now: DateTime(2026, 10, 18, 9),
      ),
      isEmpty,
    );
    expect(DemoAvailability.hasTemplate(DateTime(2026, 10, 18)), isFalse);

    final wednesday = DemoAvailability.slotsFor(
      date: DateTime(2026, 10, 21),
      now: DateTime(2026, 10, 21, 8),
    );
    expect(wednesday, hasLength(2));

    final openMonday = DemoAvailability.slotsFor(
      date: DateTime(2026, 10, 19),
      now: DateTime(2026, 10, 19, 8),
    );
    final hidden = DemoAvailability.slotsFor(
      date: DateTime(2026, 10, 19),
      now: DateTime(2026, 10, 19, 8),
      bookedSlotIds: {openMonday.first.id},
    );
    expect(hidden, hasLength(openMonday.length - 1));
    expect(hidden.any((slot) => slot.id == openMonday.first.id), isFalse);
  });

  test('month navigation crosses years and confirmation cannot be repeated', () {
    final controller = CalendarController(now: () => DateTime(2026, 1, 15, 9));
    expect(controller.visibleMonth, DateTime(2026, 1, 1));
    expect(controller.selectedDate, DateTime(2026, 1, 15));

    controller.showPreviousMonth();
    expect(controller.visibleMonth, DateTime(2025, 12, 1));
    expect(controller.selectedDate, DateTime(2025, 12, 1));

    controller.showNextMonth();
    expect(controller.visibleMonth, DateTime(2026, 1, 1));
    expect(controller.selectedDate, DateTime(2026, 1, 15));

    controller.showNextMonth();
    expect(controller.visibleMonth, DateTime(2026, 2, 1));
    expect(controller.selectedDate, DateTime(2026, 2, 1));

    final bookingController = CalendarController(now: () => DateTime(2026, 10, 19, 8));
    bookingController.selectService('not-real');
    expect(bookingController.serviceId, isNull);
    bookingController.selectService('svc-blowout');
    bookingController.selectStylist('stylist-noah');
    expect(bookingController.stylistId, isNull);
    bookingController.selectStylist(MockCatalog.anyStylistId);

    final slot = bookingController.slotsFor(bookingController.selectedDate).first;
    bookingController.selectSlot(slot.id);
    var reentered = false;
    bookingController.addListener(() {
      if (reentered) return;
      reentered = true;
      expect(bookingController.confirm(), isNull);
    });

    final booking = bookingController.confirm();
    expect(booking, isNotNull);
    expect(booking!.serviceId, 'svc-blowout');
    expect(booking.price, 4500);
    expect(booking.durationMinutes, 45);
    expect(bookingController.confirm(), isNull);
    expect(bookingController.bookings, hasLength(1));
    expect(
      bookingController.slotsFor(DateTime(2026, 10, 19)).any((item) => item.id == slot.id),
      isFalse,
    );
    bookingController.selectSlot(slot.id);
    expect(bookingController.selectedSlotId, isNull);
    expect(bookingController.canReview, isFalse);
  });

  testWidgets('calendar renders demo times and moves between months', (tester) async {
    await pumpCalendar(tester, now: saturdayNoon);

    expect(find.byKey(const Key('calendar-demo-notice')), findsOneWidget);
    expect(find.textContaining('not live salon availability'), findsOneWidget);
    expect(tester.widget<Text>(find.byKey(const Key('calendar-month-label'))).data, 'October 2026');
    expect(find.text('Sat, Oct 17, 2026'), findsOneWidget);
    expect(find.text('3:00 PM'), findsOneWidget);
    expect(find.text('11:00 AM'), findsNothing);

    await tester.tap(find.byKey(ValueKey(calendarDayKey(DateTime(2026, 10, 18)))));
    await tester.pumpAndSettle();
    expect(find.text('Sun, Oct 18, 2026'), findsOneWidget);
    expect(find.text('No demo openings'), findsOneWidget);
    expect(find.text('3:00 PM'), findsNothing);

    await tester.tap(find.byKey(ValueKey(calendarDayKey(DateTime(2026, 10, 16)))));
    await tester.pumpAndSettle();
    expect(find.text('No demo times left'), findsOneWidget);

    await tester.tap(find.byKey(ValueKey(calendarDayKey(DateTime(2026, 10, 19)))));
    await tester.pumpAndSettle();
    expect(find.text('Mon, Oct 19, 2026'), findsOneWidget);
    expect(find.text('10:00 AM'), findsOneWidget);
    expect(find.text('4:30 PM'), findsOneWidget);

    await tester.tap(find.byKey(const Key('calendar-next-month')));
    await tester.pumpAndSettle();
    expect(tester.widget<Text>(find.byKey(const Key('calendar-month-label'))).data, 'November 2026');
    expect(find.text('No demo openings'), findsOneWidget);

    await tester.tap(find.byKey(const Key('calendar-prev-month')));
    await tester.pumpAndSettle();
    expect(tester.widget<Text>(find.byKey(const Key('calendar-month-label'))).data, 'October 2026');
    expect(find.text('Sat, Oct 17, 2026'), findsOneWidget);
    expect(find.text('3:00 PM'), findsOneWidget);
  });

  testWidgets('review confirms one local demo booking and blocks the slot', (tester) async {
    final controller = await pumpCalendar(tester, now: saturdayNoon);

    expect(
      tester.widget<AppPrimaryButton>(find.byKey(const Key('calendar-review'))).onPressed,
      isNull,
    );

    await tester.tap(find.byKey(const ValueKey('calendar-service-svc-blowout')));
    await tester.pumpAndSettle();
    await tester.scrollUntilVisible(
      find.byKey(const Key('calendar-service-summary')),
      200,
      scrollable: verticalScrollable().last,
    );
    expect(find.text('Signature Blowout'), findsWidgets);
    expect(find.text('45 min'), findsWidgets);
    expect(find.text('Sample price Rs 4,500'), findsOneWidget);
    await tester.scrollUntilVisible(
      find.byKey(const ValueKey('calendar-stylist-any')),
      200,
      scrollable: verticalScrollable().last,
    );
    expect(find.byKey(const ValueKey('calendar-stylist-stylist-noah')), findsNothing);
    expect(find.byKey(const ValueKey('calendar-stylist-stylist-amara')), findsWidgets);

    await tester.tap(find.byKey(const ValueKey('calendar-stylist-any')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const ValueKey('calendar-slot-20261017-1500')));
    await tester.pumpAndSettle();
    expect(
      tester.widget<AppPrimaryButton>(find.byKey(const Key('calendar-review'))).onPressed,
      isNotNull,
    );

    await tester.tap(find.byKey(const Key('calendar-review')));
    await tester.pumpAndSettle();
    expect(find.text('Review demo booking'), findsOneWidget);
    expect(find.textContaining('does not reserve a salon appointment'), findsOneWidget);
    expect(
      find.descendant(
        of: find.byKey(const Key('booking-summary')),
        matching: find.text('Signature Blowout'),
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
        matching: find.text('3:00 PM'),
      ),
      findsOneWidget,
    );
    expect(
      find.descendant(
        of: find.byKey(const Key('booking-summary')),
        matching: find.text('45 min'),
      ),
      findsOneWidget,
    );
    expect(
      find.descendant(
        of: find.byKey(const Key('booking-summary')),
        matching: find.text('Rs 4,500'),
      ),
      findsOneWidget,
    );

    await tester.tap(find.byKey(const Key('calendar-confirm')));
    await tester.tap(find.byKey(const Key('calendar-confirm')), warnIfMissed: false);
    await tester.pumpAndSettle();

    expect(find.text('Demo booking saved'), findsOneWidget);
    expect(find.textContaining('A salon has not confirmed this time'), findsOneWidget);
    expect(controller.bookings, hasLength(1));
    expect(controller.confirm(), isNull);
    expect(controller.bookings, hasLength(1));

    await tester.tap(find.byKey(const Key('calendar-back')));
    await tester.pumpAndSettle();
    expect(find.text('No demo times left'), findsOneWidget);
    expect(find.text('3:00 PM'), findsNothing);
    expect(
      tester.widget<AppPrimaryButton>(find.byKey(const Key('calendar-review'))).onPressed,
      isNull,
    );
  });

  testWidgets('a catalogue service can prefill the calendar', (tester) async {
    await pumpCalendar(
      tester,
      now: saturdayNoon,
      initialServiceId: 'svc-gel-manicure',
    );
    expect(find.text('Gel Manicure'), findsWidgets);
    expect(find.text('Sample price Rs 3,500'), findsOneWidget);
    await tester.scrollUntilVisible(
      find.byKey(const Key('calendar-stylist-list')),
      200,
      scrollable: verticalScrollable().last,
    );
    await tester.scrollUntilVisible(
      find.byKey(const ValueKey('calendar-stylist-stylist-noah')),
      80,
      scrollable: find.descendant(
        of: find.byKey(const Key('calendar-stylist-list')),
        matching: find.byType(Scrollable),
      ),
    );
    expect(find.text('Noah Silva'), findsOneWidget);

    await pumpCalendar(tester, now: saturdayNoon, initialServiceId: 'missing-service');
    expect(find.text('Choose a service from the catalogue to continue.'), findsOneWidget);
  });

  testWidgets('a demo booking does not change the existing bookings screen', (tester) async {
    await pumpSalonApp(tester);
    await tester.scrollUntilVisible(
      find.byKey(const Key('home-open-calendar')),
      400,
      scrollable: verticalScrollable(),
    );
    await tester.tap(find.byKey(const Key('home-open-calendar')));
    await tester.pumpAndSettle();
    expect(find.textContaining('not live salon availability'), findsOneWidget);

    final now = DateTime.now();
    final day = nextDemoDay(now);
    final slot = DemoAvailability.slotsFor(date: day, now: now).first;
    await revealMonth(tester, day);
    await tester.tap(find.byKey(ValueKey(calendarDayKey(day))));
    await tester.pumpAndSettle();

    await tester.scrollUntilVisible(
      find.byKey(const ValueKey('calendar-service-svc-blowout')),
      250,
      scrollable: verticalScrollable().last,
    );
    await tester.tap(find.byKey(const ValueKey('calendar-service-svc-blowout')));
    await tester.pumpAndSettle();

    await tester.scrollUntilVisible(
      find.byKey(const ValueKey('calendar-stylist-any')),
      250,
      scrollable: verticalScrollable().last,
    );
    await tester.tap(find.byKey(const ValueKey('calendar-stylist-any')));
    await tester.pumpAndSettle();

    final slotKey = ValueKey('calendar-slot-${slot.id}');
    await tester.scrollUntilVisible(
      find.byKey(slotKey),
      250,
      scrollable: verticalScrollable().last,
    );
    await tester.tap(find.byKey(slotKey));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('calendar-review')));
    await tester.pumpAndSettle();
    expect(find.text(DisplayFormat.timeOf(slot.start)), findsWidgets);
    await tester.tap(find.byKey(const Key('calendar-confirm')));
    await tester.pumpAndSettle();
    expect(find.text('Demo booking saved'), findsOneWidget);
    await tester.scrollUntilVisible(
      find.byKey(const Key('calendar-finish')),
      200,
      scrollable: verticalScrollable().last,
    );
    await tester.tap(find.byKey(const Key('calendar-finish')));
    await tester.pumpAndSettle();
    expect(find.text('Home'), findsOneWidget);
    expect(find.text('Explore'), findsOneWidget);
    expect(find.text('Bookings'), findsOneWidget);
    expect(find.text('Profile'), findsOneWidget);

    await tester.tap(find.text('Bookings'));
    await tester.pumpAndSettle();
    expect(find.text('My bookings'), findsOneWidget);
    expect(find.text('No upcoming visits yet'), findsOneWidget);
    await tester.tap(find.text('Past'));
    await tester.pumpAndSettle();
    expect(find.text('Gel Manicure'), findsOneWidget);
    expect(find.text('Completed'), findsOneWidget);
  });
}

DateTime nextDemoDay(DateTime now) {
  var day = DateTime(now.year, now.month, now.day);
  for (var index = 0; index < 45; index++) {
    if (DemoAvailability.slotsFor(date: day, now: now).isNotEmpty) return day;
    day = day.add(const Duration(days: 1));
  }
  throw StateError('No demo day found');
}

Future<void> revealMonth(WidgetTester tester, DateTime day) async {
  final target = calendarMonthLabel(DateTime(day.year, day.month));
  for (var index = 0; index < 8; index++) {
    final label = tester.widget<Text>(find.byKey(const Key('calendar-month-label'))).data;
    if (label == target) return;
    await tester.tap(find.byKey(const Key('calendar-next-month')));
    await tester.pumpAndSettle();
  }
}

Future<CalendarController> pumpCalendar(
  WidgetTester tester, {
  required DateTime now,
  String? initialServiceId,
}) async {
  tester.view.physicalSize = const Size(390, 900);
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);
  final controller = CalendarController(now: () => now);
  await tester.pumpWidget(
    CalendarScope(
      controller: controller,
      child: MaterialApp(
        theme: AppTheme.light,
        home: SmartCalendarScreen(initialServiceId: initialServiceId),
        onGenerateRoute: AppNavigation.onGenerateRoute,
      ),
    ),
  );
  await tester.pumpAndSettle();
  return controller;
}
