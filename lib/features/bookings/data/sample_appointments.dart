import '../../booking/models/appointment.dart';

/// Sample history so the past list has something to show on first launch.
///
/// These visits are not stored anywhere outside the running app.
class SampleAppointments {
  SampleAppointments._();

  static List<Appointment> seed({DateTime? now}) {
    final clock = now ?? DateTime.now();
    final past = clock.subtract(const Duration(days: 12, hours: 2));
    return [
      Appointment(
        id: 'sample-past-1',
        serviceId: 'svc-gel-manicure',
        stylistId: 'stylist-noah',
        start: DateTime(past.year, past.month, past.day, 15, 30),
        status: AppointmentStatus.completed,
        sample: true,
      ),
    ];
  }
}
