import 'dart:async';
import 'dart:typed_data';

import 'package:http/http.dart' as http;
import 'package:salon_customer_app/features/ai_hair_studio/models/hair_style_option.dart';
import 'package:salon_customer_app/features/ai_hair_studio/models/hair_transformation.dart';
import 'package:salon_customer_app/features/ai_hair_studio/services/studio_photo_source.dart';
import 'package:salon_customer_app/features/ai_hair_studio/services/studio_result_exporter.dart';
import 'package:salon_customer_app/features/ai_hair_studio/services/style_reference_loader.dart';
import 'package:salon_customer_app/features/ai_hair_studio/state/hair_studio_bindings.dart';
import 'package:salon_customer_app/features/ai_hair_studio/services/hair_transformation_client.dart';
import 'package:salon_customer_app/features/ai_hair_studio/services/photo_preparation.dart';

import 'studio_images.dart';

/// Test double. It returns scripted bytes and does not perform AI generation.
class FakeHairTransformationClient implements HairTransformationClient {
  FakeHairTransformationClient({List<HairTransformationOutcome>? outcomes})
      : outcomes = outcomes ?? [];

  List<HairTransformationOutcome> outcomes;
  final requests = <HairTransformationRequest>[];
  Completer<void>? gate;
  bool echoRequest = false;

  @override
  Future<HairTransformationOutcome> transform(HairTransformationRequest request) async {
    requests.add(request);
    final pending = gate;
    if (pending != null) {
      await pending.future;
    }
    if (echoRequest) {
      return HairTransformationOutcome.success(
        imageBytes: Uint8List.fromList(request.imageBytes),
        mimeType: 'image/jpeg',
      );
    }
    if (outcomes.isEmpty) {
      return const HairTransformationOutcome.failure(HairStudioFailure.provider);
    }
    final index = requests.length - 1;
    final safeIndex = index < outcomes.length ? index : outcomes.length - 1;
    return outcomes[safeIndex];
  }

  @override
  void dispose() {}
}

class FakePhotoSource implements StudioPhotoSource {
  FakePhotoSource({List<StudioPhotoPick?>? gallery, this.cameraError})
      : gallery = gallery ?? [];

  final List<StudioPhotoPick?> gallery;
  final StudioPhotoException? cameraError;
  var galleryCalls = 0;
  var cameraCalls = 0;

  @override
  Future<StudioPhotoPick?> pickFromGallery() async {
    final index = galleryCalls;
    galleryCalls += 1;
    if (gallery.isEmpty) {
      return null;
    }
    if (index < gallery.length) {
      return gallery[index];
    }
    return gallery.last;
  }

  @override
  Future<StudioPhotoPick?> captureWithCamera() async {
    cameraCalls += 1;
    final error = cameraError;
    if (error != null) {
      throw error;
    }
    return null;
  }
}

class FakeStudioExporter implements StudioResultExporter {
  var saves = 0;
  var shares = 0;
  Uint8List? lastSaved;

  @override
  Future<StudioExportResult> save(Uint8List bytes, {required String mimeType}) async {
    saves += 1;
    lastSaved = bytes;
    return const StudioExportResult(
      StudioExportStatus.saved,
      'Saved to your photos.',
    );
  }

  @override
  Future<StudioExportResult> share(Uint8List bytes, {required String mimeType}) async {
    shares += 1;
    return const StudioExportResult(
      StudioExportStatus.shared,
      'Share sheet opened.',
    );
  }
}

class ThrowingHttpClient extends http.BaseClient {
  var calls = 0;

  @override
  Future<http.StreamedResponse> send(http.BaseRequest request) {
    calls += 1;
    throw StateError('The AI service should not be contacted');
  }
}

HairStudioBindings studioBindings({
  StudioPhotoSource? photoSource,
  HairTransformationClient? client,
  StudioResultExporter? exporter,
  PhotoPreparation? preparation,
  StyleReferenceLoader? referenceLoader,
}) {
  return HairStudioBindings(
    photoSource: photoSource ?? FakePhotoSource(),
    preparation: preparation ?? const PhotoPreparation(),
    client: client ?? FakeHairTransformationClient(),
    exporter: exporter ?? FakeStudioExporter(),
    referenceLoader: referenceLoader ?? FixedReferenceLoader(solidJpeg(4, 5, 6)),
  );
}

class FixedReferenceLoader implements StyleReferenceLoader {
  FixedReferenceLoader(this.bytes);

  Uint8List? bytes;
  var calls = 0;

  @override
  Future<Uint8List?> load(HairStyleOption style) async {
    calls += 1;
    return bytes == null ? null : Uint8List.fromList(bytes!);
  }
}
