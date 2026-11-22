import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:salon_customer_app/core/api/api_exception.dart';
import 'package:salon_customer_app/core/navigation/app_navigation.dart';
import 'package:salon_customer_app/core/state/app_controller.dart';
import 'package:salon_customer_app/core/state/app_scope.dart';
import 'package:salon_customer_app/core/time/salon_time.dart';
import 'package:salon_customer_app/features/auth/signed_in_customer.dart';
import 'package:salon_customer_app/features/booking/data/customer_booking_api.dart';
import 'package:salon_customer_app/features/booking/screens/booking_flow_screen.dart';
import 'package:salon_customer_app/features/bookings/screens/my_bookings_screen.dart';
import 'package:salon_customer_app/features/catalog/data/customer_catalogue_api.dart';
import 'package:salon_customer_app/features/catalog/data/salon_catalog.dart';
import 'package:salon_customer_app/features/catalog/models/salon_place.dart';
import 'package:salon_customer_app/features/catalog/models/salon_service.dart';
import 'package:salon_customer_app/features/catalog/models/service_category.dart';

import 'support/pump_app.dart';

void main() {
  testWidgets('signed-in history shows salon appointments and an empty state', (tester) async {
    final booking = _HistoryBooking();
    final controller = AppController()..bookingApi = booking;
    controller.signIn(_customer);

    await tester.pumpWidget(_bookingsApp(controller));
    await tester.pump();
    await tester.pumpAndSettle();

    expect(find.text('Signature Blowout'), findsOneWidget);
    expect(find.text('Booking request'), findsOneWidget);
    expect(find.textContaining('Requested time'), findsOneWidget);
    expect(find.text('Stylist not assigned yet'), findsOneWidget);
    expect(find.text('Gel Manicure'), findsNothing);
    expect(find.text('Sample data'), findsNothing);

    booking.rows = const [];
    await tester.fling(find.byType(ListView), const Offset(0, 300), 1000);
    await tester.pumpAndSettle();

    expect(find.text('No upcoming visits yet'), findsOneWidget);
    expect(find.text('Signature Blowout'), findsNothing);
  });

  testWidgets('refresh shows a staff status change and cancellation decision', (tester) async {
    final booking = _HistoryBooking();
    final controller = AppController()..bookingApi = booking;
    controller.signIn(_customer);

    await tester.pumpWidget(_bookingsApp(controller));
    await tester.pumpAndSettle();

    expect(find.text('Request cancellation'), findsOneWidget);
    await tester.tap(find.text('Request cancellation'));
    await tester.pumpAndSettle();
    expect(find.text('Cancellation request is waiting for the salon.'), findsOneWidget);
    expect(find.text('Request cancellation'), findsNothing);

    booking.rows = [
      _record(status: 'Confirmed', cancellation: 'Declined', scheduled: DateTime(2026, 11, 22, 11)),
    ];
    await tester.fling(find.byType(ListView), const Offset(0, 300), 1000);
    await tester.pumpAndSettle();

    expect(find.text('Confirmed'), findsOneWidget);
    expect(find.textContaining('Confirmed time'), findsOneWidget);
    expect(find.text('The salon declined the cancellation request.'), findsOneWidget);
    expect(find.text('Asha'), findsOneWidget);
  });

  testWidgets('a live booking does not fall back to sample dates', (tester) async {
    tester.view.physicalSize = const Size(390, 900);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    final controller = AppController()
      ..catalogueApi = _FailingDates()
      ..bookingApi = _HistoryBooking();
    controller.signIn(_customer);

    await tester.pumpWidget(
      AppScope(
        controller: controller,
        child: MaterialApp(
          home: const BookingFlowScreen(),
          onGenerateRoute: AppNavigation.onGenerateRoute,
        ),
      ),
    );
    await tester.pumpAndSettle();

    await tapVisible(tester, find.byKey(const ValueKey('pick-service-15')));
    await tester.tap(find.byKey(const Key('booking-next')));
    await tester.pumpAndSettle();
    await tapVisible(tester, find.byKey(const ValueKey('pick-stylist-any')));
    await tester.tap(find.byKey(const Key('booking-next')));
    await tester.pumpAndSettle();

    expect(find.text('Dates are unavailable'), findsOneWidget);
    expect(find.text('Sample dates'), findsNothing);
    expect(find.byKey(const ValueKey('pick-date-0')), findsNothing);
  });

  testWidgets('approved cancellation and every service name are shown', (tester) async {
    final booking = _HistoryBooking()
      ..rows = [
        _record(
          status: 'Cancelled',
          cancellation: 'Approved',
          names: const ['Cut', 'Colour'],
        ),
      ];
    final controller = AppController()..bookingApi = booking;
    controller.signIn(_customer);

    await tester.pumpWidget(_bookingsApp(controller));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Past'));
    await tester.pumpAndSettle();

    expect(find.text('Cut, Colour'), findsOneWidget);
    expect(find.text('The salon approved the cancellation.'), findsOneWidget);
    expect(find.text('Cancelled'), findsOneWidget);
  });

  test('booking dates follow Asia/Colombo when the phone is on another day', () {
    final utc = DateTime.utc(2026, 11, 20, 20);
    final salonNow = SalonTime.now(utc);
    expect(salonNow, DateTime(2026, 11, 21, 1, 30));
    expect(SalonTime.today(utc), DateTime(2026, 11, 21));
    expect(SalonTime.isPastSlot(DateTime(2026, 11, 21), 1, 0, utc), isTrue);
    expect(SalonTime.isPastSlot(DateTime(2026, 11, 21), 2, 0, utc), isFalse);
    expect(SalonTime.isPastSlot(DateTime(2026, 11, 22), 1, 0, utc), isFalse);
  });

  testWidgets('guest bookings stay labelled as sample data', (tester) async {
    await pumpSalonApp(tester);
    await tapVisible(tester, find.text('Bookings'));
    await tapVisible(tester, find.text('Past'));
    expect(find.text('Sample visits in this preview.'), findsOneWidget);
    expect(find.text('Sample data'), findsOneWidget);
    expect(find.text('Gel Manicure'), findsOneWidget);
  });
}

Widget _bookingsApp(AppController controller) {
  return AppScope(
    controller: controller,
    child: MaterialApp(home: const MyBookingsScreen()),
  );
}

final DateTime _visitDay = SalonTime.today().add(const Duration(days: 2));

final _customer = SignedInCustomer(
  accessToken: 'token',
  username: '0770000001',
  fullName: 'Maya Fernando',
  expiresAt: DateTime(2026, 12, 1),
  customerId: 4,
);

CustomerAppointmentRecord _record({
  String status = 'Pending',
  String cancellation = 'None',
  DateTime? scheduled,
  List<String> names = const ['Signature Blowout'],
}) {
  return CustomerAppointmentRecord(
    appointmentId: 41,
    branchName: 'Negombo',
    serviceId: 15,
    serviceName: names.join(', '),
    serviceNames: names,
    appointmentDate: _visitDay,
    preferredStartTime: DateTime(_visitDay.year, _visitDay.month, _visitDay.day, 10),
    scheduledStartTime: scheduled == null
        ? null
        : DateTime(_visitDay.year, _visitDay.month, _visitDay.day, scheduled.hour, scheduled.minute),
    stylistName: scheduled == null ? null : 'Asha',
    status: status,
    cancellationRequest: cancellation,
    createdDate: DateTime(2026, 11, 20),
  );
}

class _HistoryBooking extends CustomerBookingApi {
  List<CustomerAppointmentRecord> rows = [_record()];

  @override
  Future<List<CustomerAppointmentRecord>> list({required String accessToken}) async => rows;

  @override
  Future<CustomerAppointmentRecord> requestCancellation({
    required String accessToken,
    required int appointmentId,
  }) async {
    rows = [_record(cancellation: 'AwaitingApproval')];
    return rows.single;
  }
}

class _FailingDates extends CustomerCatalogueApi {
  @override
  Future<SalonCatalog> load(String accessToken) async {
    return const SalonCatalog(
      isLive: true,
      categories: [ServiceCategory(id: 'hair', name: 'Hair')],
      salons: [
        SalonPlace(id: '1', name: 'Studio', area: 'Negombo', highlight: 'Studio', rating: -1),
      ],
      services: [
        SalonService(
          id: '15',
          categoryId: 'hair',
          salonId: '1',
          name: 'Signature Blowout',
          description: 'Blowout',
          price: 2500,
          durationMinutes: 45,
          stylistIds: [],
        ),
      ],
      stylists: [],
    );
  }

  @override
  Future<List<({DateTime start, bool available})>> availability({
    required String accessToken,
    required int branchId,
    required int serviceId,
    required DateTime date,
    int? employeeId,
  }) async {
    throw const ApiException('Salon calendar is offline.');
  }
}
