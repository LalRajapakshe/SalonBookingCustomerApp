import 'package:http/http.dart' as http;

import '../services/hair_studio_config.dart';
import '../services/hair_transformation_client.dart';
import '../services/http_hair_transformation_client.dart';
import '../services/image_picker_photo_source.dart';
import '../services/photo_preparation.dart';
import '../services/platform_result_exporter.dart';
import '../services/studio_photo_source.dart';
import '../services/studio_result_exporter.dart';
import '../services/style_reference_loader.dart';

class HairStudioBindings {
  HairStudioBindings({
    required this.photoSource,
    required this.preparation,
    required this.client,
    required this.exporter,
    required this.referenceLoader,
    http.Client? httpClient,
  }) : _httpClient = httpClient;

  final StudioPhotoSource photoSource;
  final PhotoPreparation preparation;
  final HairTransformationClient client;
  final StudioResultExporter exporter;
  final StyleReferenceLoader referenceLoader;
  final http.Client? _httpClient;

  /// Uses the compile-time proxy address when one has been supplied.
  /// The provider credential is never part of these bindings.
  factory HairStudioBindings.production() {
    final httpClient = http.Client();
    return HairStudioBindings(
      photoSource: ImagePickerPhotoSource(),
      preparation: const PhotoPreparation(),
      client: HttpHairTransformationClient(
        endpoint: HairStudioConfig.endpoint,
        httpClient: httpClient,
      ),
      exporter: const PlatformStudioExporter(),
      referenceLoader: const BundleStyleReferenceLoader(),
      httpClient: httpClient,
    );
  }

  void dispose() {
    client.dispose();
    _httpClient?.close();
  }
}
