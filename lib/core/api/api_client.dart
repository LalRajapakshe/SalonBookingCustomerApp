import 'dart:convert';

import 'package:http/http.dart' as http;

import 'api_config.dart';
import 'api_exception.dart';

class ApiClient {
  ApiClient({http.Client? httpClient, String? baseUrl})
      : _http = httpClient ?? http.Client(),
        _baseUrl = baseUrl ?? ApiConfig.baseUrl;

  final http.Client _http;
  final String _baseUrl;

  Future<Map<String, dynamic>> getJson(String path, {String? accessToken}) async {
    final decoded = await _send(
      () => _http.get(Uri.parse('$_baseUrl$path'), headers: _headers(accessToken)),
    );
    if (decoded is Map<String, dynamic>) return decoded;
    throw const ApiException('The server returned an unexpected response.');
  }

  Future<List<int>> getBytes(String path, {String? accessToken}) async {
    final http.Response response;
    try {
      response = await _http.get(Uri.parse('$_baseUrl$path'), headers: _headers(accessToken));
    } catch (_) {
      throw const ApiException('Cannot reach the salon server.');
    }
    if (response.statusCode >= 200 && response.statusCode < 300) {
      return response.bodyBytes;
    }
    throw ApiException(_message(response), statusCode: response.statusCode);
  }

  Future<List<dynamic>> getJsonList(String path, {String? accessToken}) async {
    final decoded = await _send(
      () => _http.get(Uri.parse('$_baseUrl$path'), headers: _headers(accessToken)),
    );
    if (decoded is List) return decoded;
    throw const ApiException('The server returned an unexpected response.');
  }

  Future<Map<String, dynamic>> postJson(
    String path,
    Map<String, dynamic> body, {
    String? accessToken,
  }) async {
    final http.Response response;
    try {
      response = await _http.post(
        Uri.parse('$_baseUrl$path'),
        headers: _headers(accessToken, json: true),
        body: jsonEncode(body),
      );
    } catch (_) {
      throw const ApiException('Cannot reach the salon server.');
    }

    if (response.statusCode >= 200 && response.statusCode < 300) {
      final decoded = response.body.isEmpty ? null : jsonDecode(response.body);
      if (decoded is Map<String, dynamic>) return decoded;
      throw const ApiException('The server returned an unexpected response.');
    }

    throw ApiException(_message(response), statusCode: response.statusCode);
  }

  Future<Object?> _send(Future<http.Response> Function() request) async {
    final http.Response response;
    try {
      response = await request();
    } catch (_) {
      throw const ApiException('Cannot reach the salon server.');
    }

    if (response.statusCode >= 200 && response.statusCode < 300) {
      if (response.body.isEmpty) return null;
      return jsonDecode(response.body);
    }

    throw ApiException(_message(response), statusCode: response.statusCode);
  }

  Map<String, String> _headers(String? accessToken, {bool json = false}) {
    final headers = <String, String>{'Accept': 'application/json'};
    if (json) headers['Content-Type'] = 'application/json';
    if (accessToken != null && accessToken.isNotEmpty) {
      headers['Authorization'] = 'Bearer $accessToken';
    }
    return headers;
  }

  String _message(http.Response response) {
    try {
      final decoded = jsonDecode(response.body);
      if (decoded is Map && decoded['title'] is String && (decoded['title'] as String).isNotEmpty) {
        return decoded['title'] as String;
      }
      if (decoded is Map && decoded['detail'] is String && (decoded['detail'] as String).isNotEmpty) {
        return decoded['detail'] as String;
      }
    } catch (_) {}

    if (response.statusCode == 401) return 'Invalid username or password.';
    return 'The request failed (${response.statusCode}).';
  }
}
