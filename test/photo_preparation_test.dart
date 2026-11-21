import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:image/image.dart' as img;
import 'package:salon_customer_app/features/ai_hair_studio/services/photo_preparation.dart';

import 'support/studio_images.dart';

void main() {
  const preparation = PhotoPreparation();

  test('compresses a large photo to a smaller jpeg', () {
    final prepared = preparation.prepare(
      solidJpeg(20, 80, 140, width: 2000, height: 1200),
    );

    expect(prepared.bytes.first, 0xFF);
    expect(prepared.bytes[1], 0xD8);
    final decoded = img.decodeJpg(prepared.bytes);
    expect(decoded, isNotNull);
    expect(decoded!.width, lessThanOrEqualTo(1024));
    expect(decoded.height, lessThanOrEqualTo(1024));
    expect(decoded.width, lessThan(2000));
  });

  test('accepts png input and returns jpeg bytes', () {
    final prepared = preparation.prepare(solidPng(12, 80, 40));

    expect(prepared.bytes[0], 0xFF);
    expect(prepared.bytes[1], 0xD8);
  });

  test('rejects empty, oversized, unknown, corrupt, and tiny images', () {
    expect(
      () => preparation.prepare(Uint8List(0)),
      throwsA(
        isA<PhotoPreparationException>().having(
          (error) => error.problem,
          'problem',
          PhotoPreparationProblem.empty,
        ),
      ),
    );

    expect(
      () => PhotoPreparation(maxInputBytes: 32).prepare(solidJpeg(1, 2, 3)),
      throwsA(
        isA<PhotoPreparationException>().having(
          (error) => error.problem,
          'problem',
          PhotoPreparationProblem.tooLarge,
        ),
      ),
    );

    expect(
      () => preparation.prepare(Uint8List.fromList(const [1, 2, 3, 4, 5, 6, 7, 8])),
      throwsA(
        isA<PhotoPreparationException>().having(
          (error) => error.problem,
          'problem',
          PhotoPreparationProblem.unsupported,
        ),
      ),
    );

    expect(
      () => preparation.prepare(
        Uint8List.fromList(const [0x89, 0x50, 0x4E, 0x47, 0x0D, 0x0A, 0x1A, 0x0A, 0, 1]),
      ),
      throwsA(
        isA<PhotoPreparationException>().having(
          (error) => error.problem,
          'problem',
          PhotoPreparationProblem.unreadable,
        ),
      ),
    );

    expect(
      () => preparation.prepare(solidJpeg(4, 5, 6, width: 40, height: 40)),
      throwsA(
        isA<PhotoPreparationException>().having(
          (error) => error.problem,
          'problem',
          PhotoPreparationProblem.tooSmall,
        ),
      ),
    );
  });
}
