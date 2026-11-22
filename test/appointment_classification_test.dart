import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:salon_customer_app/core/state/app_controller.dart';
import 'package:salon_customer_app/core/state/app_scope.dart';
import 'package:salon_customer_app/features/booking/models/appointment.dart';
import 'package:salon_customer_app/features/bookings/screens/my_bookings_screen.dart';

void main() {
  final today = DateTime(2026, 11, 22);

  Appointment visit({
    required DateTime start,
    required AppointmentStatus status,
    String serviceName = 'Signature Blowout',
    bool stored = true,
    DateTime? requested,
    DateTime? scheduled,
  }) {
    return Appointment(
      id: '${start.millisecondsSinceEpoch}-${status.name}',
      serviceId: '15',
      stylistId: '',
      start: start,
      status: status,
      storedOnServer: stored,
      serviceName: serviceName,
      requestedStart: requested,
      scheduledStart: scheduled,
    );
  }

  test('upcoming and past follow the salon date and keep cancelled distinct', () {
    final futurePending = visit(start: DateTime(2026, 11, 25, 10), status: AppointmentStatus.pending);
    final futureConfirmed = visit(start: DateTime(2026, 11, 26, 11), status: AppointmentStatus.confirmed);
    final pastConfirmed = visit(start: DateTime(2026, 11, 20, 9), status: AppointmentStatus.confirmed);
    final futureCancelled = visit(start: DateTime(2026, 11, 28, 9), status: AppointmentStatus.cancelled);
    final completed = visit(start: DateTime(2026, 11, 18, 9), status: AppointmentStatus.completed);
    final missed = visit(start: DateTime(2026, 11, 19, 9), status: AppointmentStatus.noShow);
    final requestedOnly = visit(
      start: DateTime(2026, 11, 24),
      status: AppointmentStatus.pending,
      requested: DateTime(2026, 11, 24, 15),
    );

    expect(futurePending.isHistory(today), isFalse);
    expect(futureConfirmed.isHistory(today), isFalse);
    expect(requestedOnly.applicableDay, DateTime(2026, 11, 24));
    expect(requestedOnly.isHistory(today), isFalse);
    expect(pastConfirmed.isHistory(today), isTrue);
    expect(futureCancelled.isHistory(today), isTrue);
    expect(futureCancelled.status.label, 'Cancelled');
    expect(completed.status.label, 'Completed');
    expect(missed.isHistory(today), isTrue);
    expect(futurePending.canRequestCancellation, isTrue);
    expect(pastConfirmed.canRequestCancellation, isFalse);
    expect(futureCancelled.canRequestCancellation, isFalse);
  });

  testWidgets('a future cancellation stays in Past and a past visit has no actions', (tester) async {
    final controller = AppController(appointments: [
      visit(start: DateTime(2099, 1, 2, 10), status: AppointmentStatus.pending, serviceName: 'Future colour'),
      visit(start: DateTime(2099, 1, 3, 10), status: AppointmentStatus.cancelled, serviceName: 'Future cut'),
      visit(start: DateTime(2020, 1, 2, 10), status: AppointmentStatus.confirmed, serviceName: 'Earlier blowout'),
    ]);

    await tester.pumpWidget(
      AppScope(
        controller: controller,
        child: const MaterialApp(home: MyBookingsScreen()),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Future colour'), findsOneWidget);
    expect(find.text('Future cut'), findsNothing);
    expect(find.text('Request cancellation'), findsOneWidget);

    await tester.tap(find.text('Past'));
    await tester.pumpAndSettle();

    expect(find.text('Future cut'), findsOneWidget);
    expect(find.text('Cancelled'), findsOneWidget);
    expect(find.text('Earlier blowout'), findsOneWidget);
    expect(find.text('Completed'), findsNothing);
    expect(find.text('Request cancellation'), findsNothing);
  });
}
