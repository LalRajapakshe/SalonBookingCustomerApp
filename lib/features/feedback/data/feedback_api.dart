import '../../../core/api/api_client.dart';

class PendingFeedback {
  const PendingFeedback({
    required this.appointmentServiceId,
    required this.serviceName,
    required this.stylistName,
    required this.appointmentDate,
  });

  final int appointmentServiceId;
  final String serviceName;
  final String stylistName;
  final String appointmentDate;

  factory PendingFeedback.fromJson(Map<String, dynamic> json) => PendingFeedback(
        appointmentServiceId: (json['appointmentServiceId'] as num).toInt(),
        serviceName: json['serviceName'] as String? ?? 'Service',
        stylistName: json['stylistName'] as String? ?? 'Stylist',
        appointmentDate: json['appointmentDate'] as String? ?? '',
      );
}

class FeedbackApi {
  FeedbackApi(this._client, this._token);

  final ApiClient _client;
  final String? _token;

  Future<List<PendingFeedback>> pending() async {
    final rows = await _client.getJsonList('/api/CustomerFeedback/pending', accessToken: _token);
    return rows.whereType<Map<String, dynamic>>().map(PendingFeedback.fromJson).toList();
  }

  Future<void> submit({required int appointmentServiceId, required int rating, String? comment}) async {
    await _client.postJson('/api/CustomerFeedback', {
      'appointmentServiceId': appointmentServiceId,
      'rating': rating,
      'comment': comment,
    }, accessToken: _token);
  }
}
