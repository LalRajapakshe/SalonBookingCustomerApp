import '../../core/api/api_client.dart';
import '../../core/api/api_exception.dart';
import 'signed_in_customer.dart';

class CustomerAuthApi {
  CustomerAuthApi({ApiClient? client}) : _client = client ?? ApiClient();

  final ApiClient _client;

  /// `POST /api/Auth/login`. Only a user linked to a customer may continue.
  Future<SignedInCustomer> login({
    required String username,
    required String password,
    String? tenantCode,
  }) async {
    final payload = <String, dynamic>{
      'username': username.trim(),
      'password': password,
    };
    final code = tenantCode?.trim();
    if (code != null && code.isNotEmpty) payload['tenantCode'] = code;

    final body = await _client.postJson('/api/Auth/login', payload);
    final token = body['accessToken'];
    if (token is! String || token.isEmpty) {
      throw const ApiException('Sign in did not return a token.');
    }

    final profile = body['profile'];
    if (profile is! Map) {
      throw const ApiException('Sign in did not return a customer profile.');
    }
    if (!_isCustomer(profile['userCategory'])) {
      throw const ApiException('This sign-in is for a customer account.');
    }

    final fullName = profile['fullName'];
    return SignedInCustomer(
      accessToken: token,
      username: body['username'] as String? ?? username.trim(),
      fullName: fullName is String && fullName.trim().isNotEmpty ? fullName.trim() : username.trim(),
      expiresAt: DateTime.tryParse(body['expiresAt'] as String? ?? '') ?? DateTime.now(),
      customerId: _int(profile['customerId']),
    );
  }

  static bool _isCustomer(Object? value) {
    if (value is num) return value.toInt() == 3;
    if (value is String) return value.toLowerCase() == 'customer';
    return false;
  }

  static int? _int(Object? value) {
    if (value is num) return value.toInt();
    return null;
  }
}
