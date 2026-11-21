import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';

import 'package:http/http.dart' as http;

import '../models/hair_transformation.dart';
import 'hair_studio_config.dart';
import 'hair_transformation_client.dart';

class HttpHairTransformationClient implements HairTransformationClient {
  HttpHairTransformationClient({
    required String endpoint,
    http.Client? httpClient,
    this.timeout = const Duration(seconds: 120),
    this.maxUploadBytes = 10 * 1024 * 1024 - 1,
    this.maxResponseBytes = 8 * 1024 * 1024,
  }) : endpoint = endpoint.trim(),
       _client = httpClient ?? http.Client(),
       _ownsClient = httpClient == null;

  final String endpoint;
  final Duration timeout;
  final int maxUploadBytes;
  final int maxResponseBytes;
  final http.Client _client;
  final bool _ownsClient;

  @override
  Future<HairTransformationOutcome> transform(
    HairTransformationRequest request,
  ) {
    return _transform(request).timeout(
      timeout,
      onTimeout: () => const HairTransformationOutcome.failure(HairStudioFailure.timeout),
    );
  }

  Future<HairTransformationOutcome> _transform(
    HairTransformationRequest request,
  ) async {
    final trimmed = endpoint.trim();
    if (trimmed.isEmpty) {
      return const HairTransformationOutcome.failure(HairStudioFailure.notConnected);
    }
    if (!HairStudioConfig.isAcceptableEndpoint(trimmed)) {
      return const HairTransformationOutcome.failure(
        HairStudioFailure.insecureConfiguration,
      );
    }
    final reference = request.referenceBytes;
    if (reference == null || reference.isEmpty) {
      return const HairTransformationOutcome.failure(
        HairStudioFailure.referenceUnavailable,
      );
    }
    if (request.imageBytes.isEmpty ||
        request.imageBytes.length > maxUploadBytes ||
        reference.length > maxUploadBytes) {
      return const HairTransformationOutcome.failure(HairStudioFailure.tooLarge);
    }

    final outgoing = http.MultipartRequest('POST', Uri.parse(trimmed))
      ..followRedirects = false
      ..headers['accept'] = 'image/jpeg, image/png, image/webp, application/json'
      ..headers['user-agent'] = 'LumiereHairStudio/1.0'
      ..fields['provider'] = 'perfect-corp-hair-transfer'
      ..fields['styleId'] = request.style.id
      ..fields['styleName'] = request.style.name
      ..fields['colorId'] = request.color?.id ?? ''
      ..fields['colorName'] = request.color?.name ?? ''
      ..files.add(
        http.MultipartFile.fromBytes(
          'photo',
          request.imageBytes,
          filename: 'photo.jpg',
          contentType: http.MediaType('image', 'jpeg'),
        ),
      )
      ..files.add(
        http.MultipartFile.fromBytes(
          'reference',
          reference,
          filename: '${request.style.id}.jpg',
          contentType: http.MediaType('image', 'jpeg'),
        ),
      );

    try {
      final streamed = await _client.send(outgoing);
      final declaredLength = int.tryParse(streamed.headers['content-length'] ?? '');
      if (declaredLength != null && declaredLength > maxResponseBytes) {
        return const HairTransformationOutcome.failure(HairStudioFailure.tooLarge);
      }

      final builder = BytesBuilder(copy: false);
      var total = 0;
      await for (final chunk in streamed.stream) {
        total += chunk.length;
        if (total > maxResponseBytes) {
          return const HairTransformationOutcome.failure(HairStudioFailure.tooLarge);
        }
        builder.add(chunk);
      }
      final body = builder.takeBytes();
      return _interpret(
        request: request,
        statusCode: streamed.statusCode,
        contentType: streamed.headers['content-type'],
        body: body,
      );
    } on TimeoutException {
      return const HairTransformationOutcome.failure(HairStudioFailure.timeout);
    } on http.ClientException {
      return const HairTransformationOutcome.failure(HairStudioFailure.network);
    } catch (_) {
      return const HairTransformationOutcome.failure(HairStudioFailure.network);
    }
  }

  HairTransformationOutcome _interpret({
    required HairTransformationRequest request,
    required int statusCode,
    required String? contentType,
    required Uint8List body,
  }) {
    if (statusCode >= 300 && statusCode < 400) {
      return const HairTransformationOutcome.failure(
        HairStudioFailure.insecureConfiguration,
      );
    }

    final providerCode = _providerCode(body, contentType);
    if (statusCode == 200 && providerCode == null && _isImage(body)) {
      final reference = request.referenceBytes;
      if (sameImageBytes(body, request.imageBytes) ||
          (reference != null && sameImageBytes(body, reference))) {
        return const HairTransformationOutcome.failure(HairStudioFailure.unchangedResult);
      }
      return HairTransformationOutcome.success(
        imageBytes: body,
        mimeType: _mimeType(body, contentType),
      );
    }

    if (providerCode != null) {
      return HairTransformationOutcome.failure(
        HairStudioFailure.fromProviderCode(providerCode),
      );
    }

    return switch (statusCode) {
      408 => const HairTransformationOutcome.failure(HairStudioFailure.timeout),
      413 => const HairTransformationOutcome.failure(HairStudioFailure.tooLarge),
      415 || 422 => const HairTransformationOutcome.failure(
          HairStudioFailure.unsupportedImage,
        ),
      429 => const HairTransformationOutcome.failure(HairStudioFailure.rateLimited),
      _ => const HairTransformationOutcome.failure(HairStudioFailure.provider),
    };
  }

  String? _providerCode(Uint8List body, String? contentType) {
    if (body.isEmpty || body.length > 8192) {
      return null;
    }
    final type = (contentType ?? '').toLowerCase();
    final looksLikeJson = type.contains('json') || body.first == 0x7B;
    if (!looksLikeJson) {
      return null;
    }
    try {
      final decoded = jsonDecode(utf8.decode(body));
      if (decoded is Map<String, dynamic>) {
        final code = decoded['code'];
        if (code is String && code.isNotEmpty) {
          return code;
        }
      }
    } catch (_) {
      return null;
    }
    return null;
  }

  bool _isImage(Uint8List bytes) => _imageMime(bytes) != null;

  String _mimeType(Uint8List bytes, String? contentType) {
    return _imageMime(bytes) ??
        (contentType?.split(';').first.trim().toLowerCase() ?? 'image/jpeg');
  }

  String? _imageMime(Uint8List bytes) {
    if (bytes.length >= 3 && bytes[0] == 0xFF && bytes[1] == 0xD8 && bytes[2] == 0xFF) {
      return 'image/jpeg';
    }
    if (bytes.length >= 8 &&
        bytes[0] == 0x89 &&
        bytes[1] == 0x50 &&
        bytes[2] == 0x4E &&
        bytes[3] == 0x47) {
      return 'image/png';
    }
    if (bytes.length >= 12 &&
        bytes[0] == 0x52 &&
        bytes[1] == 0x49 &&
        bytes[2] == 0x46 &&
        bytes[3] == 0x46 &&
        bytes[8] == 0x57 &&
        bytes[9] == 0x45 &&
        bytes[10] == 0x42 &&
        bytes[11] == 0x50) {
      return 'image/webp';
    }
    return null;
  }

  @override
  void dispose() {
    if (_ownsClient) {
      _client.close();
    }
  }
}
