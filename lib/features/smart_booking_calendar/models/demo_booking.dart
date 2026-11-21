/// A booking that exists only in the calendar preview.
///
/// It is not an appointment in the existing Bookings tab.
class DemoBooking {
  const DemoBooking({
    required this.id,
    required this.slotId,
    required this.serviceId,
    required this.stylistId,
    required this.start,
    required this.durationMinutes,
    required this.price,
  });

  final String id;
  final String slotId;
  final String serviceId;
  final String stylistId;
  final DateTime start;
  final int durationMinutes;
  final int price;
}

/// The selection shown on the review screen before confirmation.
class DemoBookingDraft {
  const DemoBookingDraft({
    required this.slotId,
    required this.serviceId,
    required this.stylistId,
    required this.start,
    required this.durationMinutes,
    required this.price,
  });

  final String slotId;
  final String serviceId;
  final String stylistId;
  final DateTime start;
  final int durationMinutes;
  final int price;
}
