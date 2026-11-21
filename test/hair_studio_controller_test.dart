import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:salon_customer_app/features/ai_hair_studio/data/hair_catalog.dart';
import 'package:salon_customer_app/features/ai_hair_studio/models/hair_transformation.dart';
import 'package:salon_customer_app/features/ai_hair_studio/services/photo_preparation.dart';
import 'package:salon_customer_app/features/ai_hair_studio/services/studio_photo_source.dart';
import 'package:salon_customer_app/features/ai_hair_studio/state/hair_studio_controller.dart';

import 'support/fake_hair_studio.dart';
import 'support/studio_images.dart';

void main() {
  test('generate requires a photo and a hairstyle before calling the service', () async {
    final client = FakeHairTransformationClient();
    final controller = HairStudioController(bindings: studioBindings(client: client));
    addTearDown(controller.dispose);

    await controller.generate();
    expect(controller.failure?.code, HairStudioFailureCode.missingPhoto);
    expect(client.requests, isEmpty);

    final photos = FakePhotoSource(gallery: [StudioPhotoPick(solidJpeg(8, 8, 8))]);
    final withPhoto = HairStudioController(
      bindings: studioBindings(photoSource: photos, client: client),
    );
    addTearDown(withPhoto.dispose);
    await withPhoto.pickFromGallery();
    await withPhoto.generate();
    expect(withPhoto.failure?.code, HairStudioFailureCode.missingStyle);
    expect(client.requests, isEmpty);
    expect(withPhoto.photoBytes, isNotNull);
  });

  test('a second generate waits until the first one finishes', () async {
    final gate = Completer<void>();
    final client = FakeHairTransformationClient(
      outcomes: [
        HairTransformationOutcome.success(
          imageBytes: solidJpeg(3, 3, 3),
          mimeType: 'image/jpeg',
        ),
      ],
    )..gate = gate;
    final controller = HairStudioController(
      bindings: studioBindings(
        photoSource: FakePhotoSource(gallery: [StudioPhotoPick(solidJpeg(9, 1, 1))]),
        client: client,
      ),
    );
    addTearDown(controller.dispose);

    await controller.pickFromGallery();
    controller.selectStyle(HairCatalog.styles[1]);
    controller.setConsent(true);
    final first = controller.generate();
    await Future<void>.delayed(Duration.zero);
    final second = controller.generate();
    expect(controller.generating, isTrue);
    expect(client.requests, hasLength(1));

    gate.complete();
    await first;
    await second;

    expect(client.requests, hasLength(1));
    expect(controller.step, HairStudioStep.result);
    expect(controller.resultBytes, isNotNull);
  });

  test('retry keeps the selected photo, hairstyle, and colour', () async {
    final client = FakeHairTransformationClient(
      outcomes: [
        const HairTransformationOutcome.failure(HairStudioFailure.network),
        HairTransformationOutcome.success(
          imageBytes: solidJpeg(8, 9, 10),
          mimeType: 'image/jpeg',
        ),
      ],
    );
    final controller = HairStudioController(
      bindings: studioBindings(
        photoSource: FakePhotoSource(gallery: [StudioPhotoPick(solidJpeg(7, 7, 7))]),
        client: client,
      ),
    );
    addTearDown(controller.dispose);

    await controller.pickFromGallery();
    controller.selectStyle(HairCatalog.styles[1]);
    controller.setConsent(true);
    controller.selectColor(HairCatalog.colors[2]);
    final photo = controller.photoBytes;

    await controller.generate();
    expect(controller.failure, same(HairStudioFailure.network));
    expect(controller.photoBytes, photo);
    expect(controller.selectedStyle?.id, 'bob-cut');
    expect(controller.selectedColor?.id, 'caramel');
    expect(controller.resultBytes, isNull);

    await controller.generate();
    expect(controller.resultBytes, isNotNull);
    expect(controller.failure, isNull);
    expect(client.requests, hasLength(2));
    expect(client.requests.last.style.id, 'bob-cut');
    expect(client.requests.last.color?.id, 'caramel');
    expect(controller.photoBytes, photo);
  });

  test('generate does not upload without consent or an example photo', () async {
    final client = FakeHairTransformationClient();
    final loader = FixedReferenceLoader(solidJpeg(4, 5, 6));
    final controller = HairStudioController(
      bindings: studioBindings(
        photoSource: FakePhotoSource(gallery: [StudioPhotoPick(solidJpeg(7, 7, 7))]),
        client: client,
        referenceLoader: loader,
      ),
    );
    addTearDown(controller.dispose);

    await controller.pickFromGallery();
    controller.selectStyle(HairCatalog.styles[1]);
    await controller.generate();
    expect(controller.failure, same(HairStudioFailure.missingConsent));
    expect(client.requests, isEmpty);
    expect(loader.calls, 0);

    controller.setConsent(true);
    loader.bytes = null;
    await controller.generate();
    expect(controller.failure, same(HairStudioFailure.referenceUnavailable));
    expect(client.requests, isEmpty);
    expect(controller.resultBytes, isNull);
  });

  test('an echoed photo or example is not shown as a generated look', () async {
    final photo = solidJpeg(11, 12, 13);
    final client = FakeHairTransformationClient(
      outcomes: [
        HairTransformationOutcome.success(imageBytes: photo, mimeType: 'image/jpeg'),
      ],
    );
    final controller = HairStudioController(
      bindings: studioBindings(
        photoSource: FakePhotoSource(gallery: [StudioPhotoPick(photo)]),
        client: client,
        preparation: const PhotoPreparation(maxEdge: 64, minShortEdge: 8),
      ),
    );
    addTearDown(controller.dispose);

    await controller.pickFromGallery();
    controller.selectStyle(HairCatalog.styles[1]);
    controller.setConsent(true);
    final prepared = controller.photoBytes!;
    client.outcomes[0] = HairTransformationOutcome.success(
      imageBytes: prepared,
      mimeType: 'image/jpeg',
    );

    await controller.generate();
    expect(controller.failure, same(HairStudioFailure.unchangedResult));
    expect(controller.resultBytes, isNull);
    expect(controller.step, isNot(HairStudioStep.result));
  });
}
