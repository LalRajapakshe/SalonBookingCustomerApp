import 'dart:async';
import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:salon_customer_app/features/ai_hair_studio/data/hair_catalog.dart';
import 'package:salon_customer_app/features/ai_hair_studio/models/hair_transformation.dart';
import 'package:salon_customer_app/features/ai_hair_studio/services/hair_studio_config.dart';
import 'package:salon_customer_app/features/ai_hair_studio/services/http_hair_transformation_client.dart';

import 'support/fake_hair_studio.dart';
import 'support/studio_images.dart';

void main() {
  final portrait = solidJpeg(30, 40, 50);

  test('request carries the style, colour preference, and example photo', () {
    final reference = solidJpeg(1, 2, 3);
    final request = _request(portrait, reference: reference);
    expect(request.style.id, 'bob-cut');
    expect(request.color?.id, 'caramel');
    expect(request.referenceBytes, reference);
    expect(request.style.assetPath, 'assets/images/hair_studio/bob_cut.jpg');
  });

  test('does not contact the network when the endpoint is missing or unsafe', () async {
    final transport = ThrowingHttpClient();
    for (final endpoint in [
      '',
      'http://hair.example/v1/hair',
      'https://user:secret@hair.example/v1/hair',
      'https://hair.example/v1/hair?api_key=secret',
    ]) {
      final client = HttpHairTransformationClient(
        endpoint: endpoint,
        httpClient: transport,
      );
      final outcome = await client.transform(_request(portrait));
      expect(outcome.isSuccess, isFalse);
      expect(outcome.imageBytes, isNull);
    }
    expect(transport.calls, 0);
    expect(HairStudioConfig.isAcceptableEndpoint('https://hair.example/v1/hair'), isTrue);
  });

  test('posts the photo and preferences without an authorization header', () async {
    final transport = _ScriptClient((request) async {
      final multipart = request as http.MultipartRequest;
      expect(multipart.fields['styleId'], 'bob-cut');
      expect(multipart.fields['styleName'], 'Bob cut');
      expect(multipart.fields['colorId'], 'caramel');
      expect(multipart.fields['provider'], 'perfect-corp-hair-transfer');
      expect(multipart.fields.containsKey('editInstruction'), isFalse);
      expect(multipart.fields.containsKey('apiKey'), isFalse);
      final photo = multipart.files.singleWhere((file) => file.field == 'photo');
      final reference = multipart.files.singleWhere((file) => file.field == 'reference');
      expect(photo.filename, 'photo.jpg');
      expect(photo.length, portrait.length);
      expect(reference.filename, 'bob-cut.jpg');
      expect(reference.length, 5);
      expect(
        multipart.headers.keys.any((key) => key.toLowerCase() == 'authorization'),
        isFalse,
      );
      return _response(200, solidJpeg(1, 2, 3), type: 'image/jpeg');
    });
    final client = HttpHairTransformationClient(
      endpoint: 'https://hair.example/v1/hair',
      httpClient: transport,
    );

    final outcome = await client.transform(_request(portrait));

    expect(transport.calls, 1);
    expect(outcome.isSuccess, isTrue);
    expect(outcome.mimeType, 'image/jpeg');
    expect(outcome.imageBytes, isNot(portrait));
  });

  test('maps provider failures and never treats them as a generated image', () async {
    final cases = <int, HairStudioFailure>{
      429: HairStudioFailure.rateLimited,
      415: HairStudioFailure.unsupportedImage,
      413: HairStudioFailure.tooLarge,
      500: HairStudioFailure.provider,
      302: HairStudioFailure.insecureConfiguration,
    };

    for (final entry in cases.entries) {
      final client = HttpHairTransformationClient(
        endpoint: 'https://hair.example/v1/hair',
        httpClient: _ScriptClient((_) async => _response(entry.key, [1, 2, 3, 4])),
      );
      final outcome = await client.transform(_request(portrait));
      expect(outcome.isSuccess, isFalse);
      expect(outcome.failure, same(entry.value));
      expect(outcome.imageBytes, isNull);
    }
  });

  test('reads a provider error code and a timeout without exposing the body', () async {
    final coded = HttpHairTransformationClient(
      endpoint: 'https://hair.example/v1/hair',
      httpClient: _ScriptClient(
        (_) async => _response(
          422,
          '{"code":"rate_limited","detail":"ignore this body"}'.codeUnits,
          type: 'application/json',
        ),
      ),
    );
    final codedOutcome = await coded.transform(_request(portrait));
    expect(codedOutcome.failure, same(HairStudioFailure.rateLimited));
    expect(codedOutcome.failure!.message, isNot(contains('ignore this body')));

    final pending = Completer<http.StreamedResponse>();
    final slow = HttpHairTransformationClient(
      endpoint: 'https://hair.example/v1/hair',
      httpClient: _ScriptClient((_) => pending.future),
      timeout: const Duration(milliseconds: 20),
    );
    final timedOut = await slow.transform(_request(portrait));
    pending.complete(_response(500, const []));
    expect(timedOut.failure, same(HairStudioFailure.timeout));
    expect(timedOut.imageBytes, isNull);
  });

  test('does not treat the original or the example photo as a generated result', () async {
    final reference = solidJpeg(9, 9, 9);
    final echoedPhoto = HttpHairTransformationClient(
      endpoint: 'https://hair.example/v1/hair',
      httpClient: _ScriptClient(
        (_) async => _response(200, portrait, type: 'image/jpeg'),
      ),
    );
    final echoed = await echoedPhoto.transform(_request(portrait, reference: reference));
    expect(echoed.isSuccess, isFalse);
    expect(echoed.failure, same(HairStudioFailure.unchangedResult));
    expect(echoed.imageBytes, isNull);

    final echoedReference = HttpHairTransformationClient(
      endpoint: 'https://hair.example/v1/hair',
      httpClient: _ScriptClient(
        (_) async => _response(200, reference, type: 'image/jpeg'),
      ),
    );
    final copied = await echoedReference.transform(
      _request(portrait, reference: reference),
    );
    expect(copied.failure, same(HairStudioFailure.unchangedResult));
    expect(copied.imageBytes, isNull);
  });

  test('does not upload when the example photo is missing', () async {
    final transport = ThrowingHttpClient();
    final client = HttpHairTransformationClient(
      endpoint: 'https://hair.example/v1/hair',
      httpClient: transport,
    );
    final outcome = await client.transform(
      HairTransformationRequest(
        imageBytes: portrait,
        mimeType: 'image/jpeg',
        style: HairCatalog.styles.first,
      ),
    );
    expect(outcome.failure, same(HairStudioFailure.referenceUnavailable));
    expect(outcome.imageBytes, isNull);
    expect(transport.calls, 0);
  });

  test('maps a documented Perfect Corp pose error without showing an image', () async {
    final client = HttpHairTransformationClient(
      endpoint: 'https://hair.example/v1/hair',
      httpClient: _ScriptClient(
        (_) async => _response(
          422,
          '{"code":"error_face_pose"}'.codeUnits,
          type: 'application/json',
        ),
      ),
    );
    final outcome = await client.transform(_request(portrait));
    expect(outcome.isSuccess, isFalse);
    expect(outcome.failure, same(HairStudioFailure.facePose));
    expect(outcome.imageBytes, isNull);
    expect(outcome.failure!.message, isNot(contains('error_face_pose')));
  });
}

HairTransformationRequest _request(Uint8List bytes, {Uint8List? reference}) {
  return HairTransformationRequest(
    imageBytes: bytes,
    mimeType: 'image/jpeg',
    style: HairCatalog.styles.firstWhere((style) => style.id == 'bob-cut'),
    color: HairCatalog.colors.firstWhere((color) => color.id == 'caramel'),
    referenceBytes: reference ?? Uint8List.fromList(const [1, 2, 3, 4, 5]),
  );
}

http.StreamedResponse _response(int status, List<int> body, {String? type}) {
  return http.StreamedResponse(
    Stream<List<int>>.value(body),
    status,
    headers: {if (type != null) 'content-type': type},
  );
}

class _ScriptClient extends http.BaseClient {
  _ScriptClient(this._handler);

  final Future<http.StreamedResponse> Function(http.BaseRequest request) _handler;
  var calls = 0;

  @override
  Future<http.StreamedResponse> send(http.BaseRequest request) {
    calls += 1;
    return _handler(request);
  }
}
