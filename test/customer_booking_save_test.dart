import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:salon_customer_app/core/navigation/app_navigation.dart';
import 'package:salon_customer_app/core/api/api_exception.dart';
import 'package:salon_customer_app/core/state/app_controller.dart';
import 'package:salon_customer_app/core/state/app_scope.dart';
import 'package:salon_customer_app/features/auth/signed_in_customer.dart';
import 'package:salon_customer_app/features/booking/data/customer_booking_api.dart';
import 'package:salon_customer_app/features/booking/data/mock_availability.dart';
import 'package:salon_customer_app/features/booking/screens/booking_flow_screen.dart';
import 'package:salon_customer_app/features/catalog/data/customer_catalogue_api.dart';
import 'package:salon_customer_app/features/catalog/data/salon_catalog.dart';
import 'package:salon_customer_app/features/catalog/models/salon_place.dart';
import 'package:salon_customer_app/features/catalog/models/salon_service.dart';
import 'package:salon_customer_app/features/catalog/models/service_category.dart';

import 'support/pump_app.dart';

void main() {
  testWidgets('a signed-in booking is sent to the salon', (tester) async {
    tester.view.physicalSize = const Size(390, 900);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    final booking = _ScriptedBooking();
    final controller = AppController()
      ..catalogueApi = _ScriptedCatalogue()
      ..bookingApi = booking;
    controller.signIn(
      SignedInCustomer(
        accessToken: 'token',
        username: '0770000001',
        fullName: 'Maya Fernando',
        expiresAt: DateTime(2026, 12, 1),
        customerId: 4,
      ),
    );
    await tester.pumpWidget(
      AppScope(
        controller: controller,
        child: MaterialApp(
          home: BookingFlowScreen(bookingApi: booking),
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
    await tapVisible(tester, find.byKey(const ValueKey('pick-date-1')));
    await tester.tap(find.byKey(const Key('booking-next')));
    await tester.pumpAndSettle();

    final slotKey = ValueKey<String>(MockAvailability.slotKey(const TimeOfDay(hour: 10, minute: 0)));
    await tester.scrollUntilVisible(find.byKey(slotKey), 240);
    await tester.tap(find.byKey(slotKey));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('booking-next')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('booking-next')));
    await tester.pumpAndSettle();

    expect(find.text('Sent to the salon. They will set the time.'), findsOneWidget);
    expect(booking.createdServiceId, 15);
    expect(controller.appointments.first.status.name, 'pending');
  });
}

class _ScriptedBooking extends CustomerBookingApi {
  int? createdServiceId;

  @override
  Future<List<CustomerAppointmentRecord>> list({required String accessToken}) async {
    if (createdServiceId == null) return const [];
    return [
      CustomerAppointmentRecord(
        appointmentId: 88,
        branchName: 'Studio',
        serviceId: 15,
        serviceName: 'Signature Blowout',
        appointmentDate: DateTime(2026, 11, 21),
        preferredStartTime: DateTime(2026, 11, 21, 10),
        status: 'Pending',
        cancellationRequest: 'None',
        createdDate: DateTime(2026, 11, 21),
      ),
    ];
  }

  @override
  Future<List<BookableService>> services({required String accessToken}) async {
    return const [
      BookableService(serviceId: 15, serviceName: 'Signature Blowout', durationMinutes: 45),
    ];
  }

  @override
  Future<int> create({
    required String accessToken,
    required int serviceId,
    required int branchId,
    required DateTime start,
    int? preferredEmployeeId,
    String? notes,
  }) async {
    if (serviceId != 15 || branchId != 1) {
      throw const ApiException('Unexpected service.');
    }
    createdServiceId = serviceId;
    return 88;
  }
}

class _ScriptedCatalogue extends CustomerCatalogueApi {
  @override
  Future<SalonCatalog> load(String accessToken) async {
    return const SalonCatalog(
      isLive: true,
      categories: [ServiceCategory(id: 'hair', name: 'Hair')],
      salons: [
        SalonPlace(
          id: '1',
          name: 'Studio',
          area: 'Colombo',
          highlight: 'Studio',
          rating: -1,
        ),
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
    final morning = DateTime(date.year, date.month, date.day, 10);
    return [
      (start: morning, available: true),
      (start: morning.add(const Duration(minutes: 15)), available: false),
    ];
  }
}
