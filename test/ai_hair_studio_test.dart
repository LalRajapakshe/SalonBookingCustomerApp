import 'dart:async';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:salon_customer_app/core/theme/app_theme.dart';
import 'package:salon_customer_app/features/ai_hair_studio/data/hair_catalog.dart';
import 'package:salon_customer_app/features/ai_hair_studio/models/hair_transformation.dart';
import 'package:salon_customer_app/features/ai_hair_studio/screens/hair_studio_screen.dart';
import 'package:salon_customer_app/features/ai_hair_studio/services/http_hair_transformation_client.dart';
import 'package:salon_customer_app/features/ai_hair_studio/services/studio_photo_source.dart';
import 'package:salon_customer_app/features/ai_hair_studio/state/hair_studio_bindings.dart';
import 'package:salon_customer_app/features/ai_hair_studio/widgets/style_reference_photo.dart';

import 'support/fake_hair_studio.dart';
import 'support/pump_app.dart';
import 'support/studio_images.dart';

void main() {
  testWidgets('home opens AI Hair Studio and can return to the existing app', (tester) async {
    await pumpSalonApp(tester);

    expect(find.text('AI HAIR STUDIO'), findsOneWidget);
    expect(find.text('Book a visit'), findsOneWidget);
    expect(find.text('Popular services'), findsOneWidget);

    await tapVisible(tester, find.byKey(const Key('home-ai-hair-studio')));
    expect(find.text('Example style photos, not your photo.'), findsOneWidget);
    expect(find.text('Example'), findsWidgets);
    expect(find.byKey(const Key('example-photo-long-layers')), findsOneWidget);
    expect(find.byKey(const Key('generated-look')), findsNothing);
    expect(find.byKey(const Key('generated-look')), findsNothing);
    await _scrollTo(tester, find.byKey(const Key('hair-studio-privacy')));
    expect(find.byKey(const Key('hair-studio-privacy')), findsOneWidget);

    await tester.tap(find.byKey(const Key('hair-studio-back')));
    await tester.pumpAndSettle();
    expect(find.text('Popular services'), findsOneWidget);
    expect(find.text('Home'), findsOneWidget);

    await tapVisible(tester, find.text('Bookings'));
    expect(find.text('No upcoming visits yet'), findsOneWidget);
    await tester.tap(find.text('Past'));
    await tester.pumpAndSettle();
    expect(find.text('Gel Manicure'), findsOneWidget);
  });

  testWidgets('hairstyle chooser shows a distinct example photo for each style', (tester) async {
    await _pumpStudio(tester, studioBindings());
    final paths = <String>{};
    for (final style in HairCatalog.styles) {
      final photo = tester.widget<StyleReferencePhoto>(
        find.byKey(Key('hair-style-photo-${style.id}')),
      );
      expect(photo.assetPath, style.assetPath);
      expect(paths.add(style.assetPath), isTrue);
      expect(find.text(style.name), findsWidgets);
    }
    expect(paths, hasLength(7));
    expect(find.text('Example style photos, not your photo.'), findsOneWidget);
    expect(find.byKey(const Key('generated-look')), findsNothing);
  });

  testWidgets('a missing example asset shows a placeholder instead of a result', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: StyleReferencePhoto(assetPath: 'assets/images/hair_studio/missing.jpg'),
        ),
      ),
    );
    await tester.pump();
    expect(find.text('Example photo unavailable'), findsOneWidget);
    expect(find.byKey(const Key('generated-look')), findsNothing);
  });

  testWidgets('generate does nothing until the customer consents', (tester) async {
    final client = FakeHairTransformationClient(
      outcomes: [
        HairTransformationOutcome.success(
          imageBytes: solidJpeg(12, 180, 90),
          mimeType: 'image/jpeg',
        ),
      ],
    );
    await _pumpStudio(
      tester,
      studioBindings(
        photoSource: FakePhotoSource(gallery: [StudioPhotoPick(solidJpeg(180, 30, 70))]),
        client: client,
      ),
    );
    await _openReview(tester);
    await tester.tap(find.byKey(const Key('generate-my-look')));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 50));

    expect(client.requests, isEmpty);
    expect(find.textContaining('Nothing has been uploaded'), findsOneWidget);
    expect(find.byKey(const Key('generated-look')), findsNothing);
  });

  testWidgets('an unchanged provider image is not shown as a result', (tester) async {
    final client = FakeHairTransformationClient()..echoRequest = true;
    await _pumpStudio(
      tester,
      studioBindings(
        photoSource: FakePhotoSource(gallery: [StudioPhotoPick(solidJpeg(15, 25, 35))]),
        client: client,
      ),
    );
    await _openReview(tester);
    await _giveConsent(tester);
    await tester.tap(find.byKey(const Key('generate-my-look')));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 50));

    expect(client.requests, hasLength(1));
    expect(find.textContaining('not shown as your result'), findsOneWidget);
    expect(find.byKey(const Key('generated-look')), findsNothing);
  });

  testWidgets('selects, replaces, and removes a photo', (tester) async {
    final photos = FakePhotoSource(
      gallery: [
        null,
        StudioPhotoPick(solidJpeg(220, 20, 60)),
        StudioPhotoPick(solidJpeg(20, 20, 220)),
      ],
    );
    await _pumpStudio(tester, studioBindings(photoSource: photos));

    await tester.tap(find.byKey(const Key('try-on-my-photo')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('pick-gallery')));
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('photo-preview')), findsNothing);
    expect(find.text('The photo could not be opened. Please try again.'), findsNothing);

    await tester.tap(find.byKey(const Key('pick-gallery')));
    await tester.pumpAndSettle();
    final first = _previewBytes(tester);

    await tester.tap(find.byKey(const Key('replace-photo')));
    await tester.pumpAndSettle();
    expect(_previewBytes(tester), isNot(first));

    await tester.tap(find.byKey(const Key('remove-photo')));
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('photo-preview')), findsNothing);
  });

  testWidgets('camera permission denial and an unsupported photo stay recoverable', (tester) async {
    final photos = FakePhotoSource(
      gallery: [StudioPhotoPick(Uint8List.fromList(const [9, 8, 7, 6, 5, 4, 3, 2]))],
      cameraError: const StudioPhotoException(StudioPhotoProblem.permissionDenied),
    );
    await _pumpStudio(tester, studioBindings(photoSource: photos));
    await tester.tap(find.byKey(const Key('try-on-my-photo')));
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(const Key('pick-camera')));
    await tester.pumpAndSettle();
    expect(find.textContaining('Photo access was denied'), findsOneWidget);

    await tester.tap(find.byKey(const Key('pick-gallery')));
    await tester.pumpAndSettle();
    expect(find.textContaining('not supported'), findsOneWidget);
    expect(find.byKey(const Key('photo-preview')), findsNothing);
  });

  testWidgets('requires a photo and a hairstyle, then highlights a colour', (tester) async {
    final photos = FakePhotoSource(gallery: [StudioPhotoPick(solidJpeg(80, 40, 90))]);
    await _pumpStudio(tester, studioBindings(photoSource: photos));

    await tester.tap(find.byKey(const Key('try-on-my-photo')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('continue-photo')));
    await tester.pumpAndSettle();
    expect(find.text('Choose a photo to continue.'), findsOneWidget);

    await tester.tap(find.byKey(const Key('pick-gallery')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('continue-photo')));
    await tester.pumpAndSettle();
    await _scrollTo(tester, find.byKey(const Key('hair-color-keep')));
    expect(find.byKey(const Key('hair-color-check-keep')), findsOneWidget);

    await tester.tap(find.byKey(const Key('continue-style')));
    await tester.pumpAndSettle();
    expect(find.text('Choose a hairstyle to continue.'), findsOneWidget);

    await _scrollTo(tester, find.byKey(const Key('hair-style-bob-cut')));
    await tester.tap(find.byKey(const Key('hair-style-bob-cut')));
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('hair-style-check-bob-cut')), findsOneWidget);

    await _scrollTo(tester, find.byKey(const Key('hair-color-caramel')));
    await tester.tap(find.byKey(const Key('hair-color-caramel')));
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('hair-color-check-caramel')), findsOneWidget);
    expect(find.byKey(const Key('hair-color-check-keep')), findsNothing);
  });

  testWidgets('shows loading, a provider error, and retry without losing the look', (tester) async {
    final client = FakeHairTransformationClient(
      outcomes: [
        const HairTransformationOutcome.failure(HairStudioFailure.provider),
        HairTransformationOutcome.success(
          imageBytes: solidJpeg(12, 180, 90),
          mimeType: 'image/jpeg',
        ),
      ],
    );
    final photos = FakePhotoSource(gallery: [StudioPhotoPick(solidJpeg(180, 30, 70))]);
    await _pumpStudio(
      tester,
      studioBindings(photoSource: photos, client: client),
    );
    await _openReview(tester);
    await _giveConsent(tester);

    final gate = Completer<void>();
    client.gate = gate;
    await tester.tap(find.byKey(const Key('generate-my-look')));
    await tester.pump();
    expect(find.byKey(const Key('generation-progress')), findsOneWidget);
    expect(find.byKey(const Key('generate-my-look')), findsNothing);
    expect(client.requests, hasLength(1));

    gate.complete();
    client.gate = null;
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 50));
    expect(find.byKey(const Key('generation-error')), findsOneWidget);
    expect(find.byKey(const Key('generated-look')), findsNothing);
    expect(find.text('Bob cut'), findsOneWidget);

    await tester.tap(find.byKey(const Key('retry-generation')));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 50));
    expect(find.byKey(const Key('generated-look')), findsOneWidget);
    expect(find.text('Generated from the photo you submitted.'), findsOneWidget);
    expect(find.text('Example style photos, not your photo.'), findsNothing);
    expect(client.requests, hasLength(2));
    expect(client.requests.last.style.id, 'bob-cut');
  });

  testWidgets('an unconnected service does not upload or show a pretend result', (tester) async {
    final transport = ThrowingHttpClient();
    final photos = FakePhotoSource(gallery: [StudioPhotoPick(solidJpeg(10, 20, 30))]);
    await _pumpStudio(
      tester,
      studioBindings(
        photoSource: photos,
        client: HttpHairTransformationClient(endpoint: '', httpClient: transport),
      ),
    );
    await _openReview(tester);
    await _giveConsent(tester);
    await tester.tap(find.byKey(const Key('generate-my-look')));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 50));

    expect(transport.calls, 0);
    expect(find.textContaining('was not uploaded'), findsOneWidget);
    expect(find.byKey(const Key('generated-look')), findsNothing);
    expect(find.byKey(const Key('retry-generation')), findsOneWidget);
  });

  testWidgets('saves and shares a generated look, then tries another style', (tester) async {
    final exporter = FakeStudioExporter();
    final client = FakeHairTransformationClient(
      outcomes: [
        HairTransformationOutcome.success(
          imageBytes: solidJpeg(40, 90, 140),
          mimeType: 'image/jpeg',
        ),
        HairTransformationOutcome.success(
          imageBytes: solidJpeg(140, 90, 40),
          mimeType: 'image/jpeg',
        ),
      ],
    );
    final photos = FakePhotoSource(gallery: [StudioPhotoPick(solidJpeg(60, 60, 60))]);
    await _pumpStudio(
      tester,
      studioBindings(photoSource: photos, client: client, exporter: exporter),
    );
    await _openReview(tester);
    await _giveConsent(tester);
    await tester.tap(find.byKey(const Key('generate-my-look')));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 50));

    expect(find.byKey(const Key('before-after-slider')), findsOneWidget);
    await _scrollTo(tester, find.byKey(const Key('save-result')));
    await tester.tap(find.byKey(const Key('save-result')));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));
    expect(exporter.saves, 1);
    expect(find.text('Saved to your photos.'), findsOneWidget);
    await tester.pump(const Duration(seconds: 5));
    await tester.pumpAndSettle();

    await _scrollTo(tester, find.byKey(const Key('share-result')));
    await tester.tap(find.byKey(const Key('share-result')));
    await tester.pump();
    expect(exporter.shares, 1);

    await _scrollTo(tester, find.byKey(const Key('try-another-style')));
    await tester.tap(find.byKey(const Key('try-another-style')));
    await tester.pumpAndSettle();
    await tester.pump(const Duration(seconds: 5));
    await tester.pumpAndSettle();
    expect(find.text('Choose a look'), findsOneWidget);
    await _scrollTo(tester, find.byKey(const Key('hair-style-short-pixie')));
    await tester.tap(find.byKey(const Key('hair-style-short-pixie')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('continue-style')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('generate-my-look')));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 50));
    expect(client.requests.last.style.id, 'short-pixie');
    expect(find.byKey(const Key('generated-look')), findsOneWidget);
  });

  testWidgets('the studio flow fits a narrow phone', (tester) async {
    final client = FakeHairTransformationClient(
      outcomes: [
        HairTransformationOutcome.success(
          imageBytes: solidJpeg(200, 100, 80),
          mimeType: 'image/jpeg',
        ),
      ],
    );
    await _pumpStudio(
      tester,
      studioBindings(
        photoSource: FakePhotoSource(gallery: [StudioPhotoPick(solidJpeg(80, 100, 200))]),
        client: client,
      ),
      size: const Size(320, 640),
    );

    expect(tester.takeException(), isNull);
    await _openReview(tester);
    await _giveConsent(tester);
    expect(tester.takeException(), isNull);
    await tester.tap(find.byKey(const Key('generate-my-look')));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 50));
    expect(find.byKey(const Key('generated-look')), findsOneWidget);
    await _scrollTo(tester, find.byKey(const Key('share-result')));
    expect(tester.takeException(), isNull);
  });
}

Future<void> _pumpStudio(
  WidgetTester tester,
  HairStudioBindings bindings, {
  Size size = const Size(390, 844),
}) async {
  tester.view.physicalSize = size;
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);
  await tester.pumpWidget(
    MaterialApp(
      theme: AppTheme.light,
      home: HairStudioScreen(bindings: bindings),
    ),
  );
  await tester.pumpAndSettle();
}

Future<void> _openReview(WidgetTester tester) async {
  await tester.tap(find.byKey(const Key('try-on-my-photo')));
  await tester.pumpAndSettle();
  await tester.tap(find.byKey(const Key('pick-gallery')));
  await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('continue-photo')));
  await tester.pumpAndSettle();
  await _scrollTo(tester, find.byKey(const Key('hair-style-bob-cut')));
  await tester.tap(find.byKey(const Key('hair-style-bob-cut')));
  await tester.pumpAndSettle();
  final caramel = find.byKey(const Key('hair-color-caramel'));
  await _scrollTo(tester, caramel);
  await tester.tap(caramel);
  await tester.pumpAndSettle();
  await tester.tap(find.byKey(const Key('continue-style')));
  await tester.pumpAndSettle();
  expect(find.byKey(const Key('review-colour')), findsOneWidget);
  expect(find.text('Caramel'), findsWidgets);
}

Future<void> _giveConsent(WidgetTester tester) async {
  final consent = find.byKey(const Key('generation-consent'));
  await _scrollTo(tester, consent);
  await tester.tap(consent);
  await tester.pumpAndSettle();
}

Future<void> _scrollTo(WidgetTester tester, Finder finder) async {
  final scrollable = find.descendant(
    of: find.byKey(const Key('ai-hair-studio-screen')),
    matching: find.byWidgetPredicate(
      (widget) => widget is Scrollable && widget.axisDirection == AxisDirection.down,
    ),
  );
  if (finder.evaluate().isEmpty) {
    await tester.scrollUntilVisible(
      finder,
      300,
      scrollable: scrollable,
    );
    await tester.pumpAndSettle();
  }
  await tester.ensureVisible(finder);
  await tester.pumpAndSettle();
}

List<int> _previewBytes(WidgetTester tester) {
  final image = tester.widget<Image>(
    find.descendant(
      of: find.byKey(const Key('photo-preview')),
      matching: find.byType(Image),
    ),
  );
  return (image.image as MemoryImage).bytes;
}
