import '../../../core/time/salon_time.dart';

enum AppointmentStatus {
  pending('Booking request'),
  confirmed('Confirmed'),
  checkedIn('Checked in'),
  inProgress('In progress'),
  completed('Completed'),
  cancelled('Cancelled'),
  noShow('No show');

  const AppointmentStatus(this.label);

  final String label;

  bool get isOpen => switch (this) {
        pending || confirmed || checkedIn || inProgress => true,
        completed || cancelled || noShow => false,
      };

  static AppointmentStatus fromApi(String? value) => switch (value) {
        'Pending' => pending,
        'Confirmed' => confirmed,
        'CheckedIn' => checkedIn,
        'InProgress' => inProgress,
        'Completed' => completed,
        'Cancelled' => cancelled,
        'NoShow' => noShow,
        _ => pending,
      };
}

enum CancellationRequest {
  none,
  requested,
  declined,
  approved;

  static CancellationRequest fromApi(String? value) => switch (value) {
        'Requested' || 'AwaitingApproval' => requested,
        'Declined' => declined,
        'Approved' => approved,
        _ => none,
      };
}

class Appointment {
  const Appointment({
    required this.id,
    required this.serviceId,
    required this.stylistId,
    required this.start,
    required this.status,
    this.storedOnServer = false,
    this.sample = false,
    this.branchName,
    this.serviceName,
    this.serviceNames = const [],
    this.stylistName,
    this.requestedStart,
    this.scheduledStart,
    this.createdAt,
    this.cancellationRequest = CancellationRequest.none,
  });

  final String id;
  final String serviceId;
  final String stylistId;
  final DateTime start;
  final AppointmentStatus status;

  /// True when the salon API stored this visit.
  final bool storedOnServer;

  /// True for the guest preview history. It is not a salon appointment.
  final bool sample;

  final String? branchName;
  final String? serviceName;
  final List<String> serviceNames;
  final String? stylistName;
  final DateTime? requestedStart;
  final DateTime? scheduledStart;
  final DateTime? createdAt;
  final CancellationRequest cancellationRequest;

  /// Calendar day used for Upcoming and Past.
  /// A saved start time wins. Otherwise the requested time, then the visit date.
  /// These values are salon wall-clock dates, compared with Asia/Colombo today.
  DateTime get applicableDay {
    final when = scheduledStart ?? requestedStart ?? start;
    return DateTime(when.year, when.month, when.day);
  }

  /// History holds cancelled, completed, and no-show visits on any date,
  /// plus any other visit whose applicable day is before the salon today.
  /// The same salon day stays upcoming. Cancelled is not treated as completed.
  bool isHistory([DateTime? salonToday]) {
    if (status == AppointmentStatus.cancelled ||
        status == AppointmentStatus.completed ||
        status == AppointmentStatus.noShow) {
      return true;
    }
    final today = salonToday ?? SalonTime.today();
    final day = DateTime(today.year, today.month, today.day);
    return applicableDay.isBefore(day);
  }

  bool get canRequestCancellation =>
      storedOnServer &&
      !isHistory() &&
      cancellationRequest != CancellationRequest.requested &&
      cancellationRequest != CancellationRequest.approved &&
      status.isOpen;
}
