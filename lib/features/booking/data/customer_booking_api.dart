import '../../../core/api/api_client.dart';
import '../../../core/api/api_exception.dart';
import '../models/appointment.dart';

class BookableService {
  const BookableService({
    required this.serviceId,
    required this.serviceName,
    required this.durationMinutes,
  });

  final int serviceId;
  final String serviceName;
  final int durationMinutes;
}

class CustomerAppointmentRecord {
  const CustomerAppointmentRecord({
    required this.appointmentId,
    required this.branchName,
    required this.serviceId,
    required this.serviceName,
    this.serviceNames = const [],
    required this.appointmentDate,
    required this.status,
    required this.cancellationRequest,
    required this.createdDate,
    this.preferredStartTime,
    this.scheduledStartTime,
    this.stylistName,
  });

  final int appointmentId;
  final String branchName;
  final int serviceId;
  final String serviceName;
  final List<String> serviceNames;
  final DateTime appointmentDate;
  final DateTime? preferredStartTime;
  final DateTime? scheduledStartTime;
  final String? stylistName;
  final String status;
  final String cancellationRequest;
  final DateTime createdDate;

  factory CustomerAppointmentRecord.fromJson(Map<String, dynamic> json) {
    final date = _parse(json['appointmentDate']) ?? DateTime.now();
    return CustomerAppointmentRecord(
      appointmentId: json['appointmentId'] is num ? (json['appointmentId'] as num).toInt() : 0,
      branchName: json['branchName'] as String? ?? '',
      serviceId: json['serviceId'] is num ? (json['serviceId'] as num).toInt() : 0,
      serviceName: json['serviceName'] as String? ?? '',
      serviceNames: _serviceNames(json),
      appointmentDate: DateTime(date.year, date.month, date.day),
      preferredStartTime: _parse(json['preferredStartTime']),
      scheduledStartTime: _parse(json['scheduledStartTime']),
      stylistName: json['stylistName'] as String?,
      status: json['status'] as String? ?? 'Pending',
      cancellationRequest: json['cancellationRequest'] as String? ?? 'None',
      createdDate: _parse(json['createdDate']) ?? DateTime.now(),
    );
  }

  Appointment toAppointment() {
    final when = scheduledStartTime ?? preferredStartTime ?? appointmentDate;
    return Appointment(
      id: '$appointmentId',
      serviceId: '$serviceId',
      stylistId: '',
      start: when,
      status: AppointmentStatus.fromApi(status),
      storedOnServer: true,
      branchName: branchName,
      serviceName: serviceName,
      serviceNames: serviceNames.isEmpty ? [serviceName] : serviceNames,
      stylistName: stylistName,
      requestedStart: preferredStartTime,
      scheduledStart: scheduledStartTime,
      createdAt: createdDate,
      cancellationRequest: CancellationRequest.fromApi(cancellationRequest),
    );
  }

  static List<String> _serviceNames(Map<String, dynamic> json) {
    final raw = json['serviceNames'];
    if (raw is List) {
      return [
        for (final item in raw)
          if (item is String && item.trim().isNotEmpty) item.trim(),
      ];
    }
    final single = json['serviceName'] as String?;
    if (single == null || single.trim().isEmpty) return const [];
    return [single.trim()];
  }

  static DateTime? _parse(Object? value) {
    if (value is! String || value.isEmpty) return null;
    return DateTime.tryParse(value);
  }
}

class CustomerBookingApi {
  CustomerBookingApi({ApiClient? client}) : _client = client ?? ApiClient();

  final ApiClient _client;

  /// Services at the signed-in customer's branch.
  Future<List<BookableService>> services({required String accessToken}) async {
    final rows = await _client.getJsonList(
      '/api/CustomerAppointments/services',
      accessToken: accessToken,
    );
    return [
      for (final row in rows)
        if (row is Map<String, dynamic>)
          BookableService(
            serviceId: row['serviceId'] is num ? (row['serviceId'] as num).toInt() : 0,
            serviceName: row['serviceName'] as String? ?? '',
            durationMinutes: row['durationMinutes'] is num ? (row['durationMinutes'] as num).toInt() : 0,
          ),
    ];
  }

  /// Saves a pending appointment. The salon assigns the time slot afterwards.
  Future<int> create({
    required String accessToken,
    required int serviceId,
    required int branchId,
    required DateTime start,
    int? preferredEmployeeId,
    String? notes,
  }) async {
    final saved = await _client.postJson(
      '/api/CustomerAppointments',
      {
        'serviceId': serviceId,
        'branchId': branchId,
        'appointmentDate': _dateOnly(start),
        'preferredStartTime': _timestamp(start),
        if (preferredEmployeeId != null && preferredEmployeeId > 0)
          'preferredEmployeeId': preferredEmployeeId,
        if (notes != null && notes.trim().isNotEmpty) 'notes': notes.trim(),
      },
      accessToken: accessToken,
    );
    final id = saved['appointmentId'];
    if (id is! num || id <= 0) {
      throw const ApiException('The salon did not store the appointment.');
    }
    return id.toInt();
  }

  /// Appointments for the signed-in customer. The server decides who that is.
  Future<List<CustomerAppointmentRecord>> list({required String accessToken}) async {
    final rows = await _client.getJsonList(
      '/api/CustomerAppointments',
      accessToken: accessToken,
    );
    return [
      for (final row in rows)
        if (row is Map<String, dynamic>) CustomerAppointmentRecord.fromJson(row),
    ];
  }

  /// Asks the salon to cancel. The appointment stays in its current status.
  Future<CustomerAppointmentRecord> requestCancellation({
    required String accessToken,
    required int appointmentId,
  }) async {
    final saved = await _client.postJson(
      '/api/CustomerAppointments/$appointmentId/cancellation-request',
      const {},
      accessToken: accessToken,
    );
    return CustomerAppointmentRecord.fromJson(saved);
  }

  static String _dateOnly(DateTime value) {
    final month = value.month.toString().padLeft(2, '0');
    final day = value.day.toString().padLeft(2, '0');
    return '${value.year}-$month-$day';
  }

  static String _timestamp(DateTime value) {
    String two(int number) => number.toString().padLeft(2, '0');
    return '${_dateOnly(value)}T${two(value.hour)}:${two(value.minute)}:00';
  }
}
