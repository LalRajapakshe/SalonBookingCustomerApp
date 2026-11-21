enum AppointmentStatus {
  pending('Pending'),
  confirmed('Confirmed'),
  completed('Completed');

  const AppointmentStatus(this.label);

  final String label;
}

class Appointment {
  const Appointment({
    required this.id,
    required this.serviceId,
    required this.stylistId,
    required this.start,
    required this.status,
    this.storedOnServer = false,
  });

  final String id;
  final String serviceId;
  final String stylistId;
  final DateTime start;
  final AppointmentStatus status;

  /// True when the salon API stored this visit.
  final bool storedOnServer;
}
