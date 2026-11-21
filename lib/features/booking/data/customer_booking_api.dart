import '../../../core/api/api_client.dart';
import '../../../core/api/api_exception.dart';

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
