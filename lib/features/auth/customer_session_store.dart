import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import 'signed_in_customer.dart';

abstract class CustomerSessionStore {
  Future<SignedInCustomer?> read();

  Future<void> write(SignedInCustomer customer);

  Future<void> clear();
}

class MemoryCustomerSessionStore implements CustomerSessionStore {
  SignedInCustomer? saved;

  @override
  Future<void> clear() async {
    saved = null;
  }

  @override
  Future<SignedInCustomer?> read() async => saved;

  @override
  Future<void> write(SignedInCustomer customer) async {
    saved = customer;
  }
}

class PreferencesCustomerSessionStore implements CustomerSessionStore {
  const PreferencesCustomerSessionStore();

  static const _key = 'customer-session';

  @override
  Future<void> clear() async {
    final preferences = await SharedPreferences.getInstance();
    await preferences.remove(_key);
  }

  @override
  Future<SignedInCustomer?> read() async {
    final preferences = await SharedPreferences.getInstance();
    final raw = preferences.getString(_key);
    if (raw == null || raw.isEmpty) return null;
    final decoded = jsonDecode(raw);
    if (decoded is! Map) return null;
    final token = decoded['accessToken'];
    final username = decoded['username'];
    final fullName = decoded['fullName'];
    final expiresAt = DateTime.tryParse(decoded['expiresAt']?.toString() ?? '');
    if (token is! String || token.isEmpty || username is! String || fullName is! String || expiresAt == null) {
      return null;
    }
    final customerId = decoded['customerId'];
    return SignedInCustomer(
      accessToken: token,
      username: username,
      fullName: fullName,
      expiresAt: expiresAt,
      customerId: customerId is num ? customerId.toInt() : null,
    );
  }

  @override
  Future<void> write(SignedInCustomer customer) async {
    final preferences = await SharedPreferences.getInstance();
    await preferences.setString(
      _key,
      jsonEncode({
        'accessToken': customer.accessToken,
        'username': customer.username,
        'fullName': customer.fullName,
        'expiresAt': customer.expiresAt.toIso8601String(),
        'customerId': customer.customerId,
      }),
    );
  }
}
