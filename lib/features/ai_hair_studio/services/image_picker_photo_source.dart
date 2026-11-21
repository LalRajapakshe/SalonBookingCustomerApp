import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';

import 'studio_photo_source.dart';
import 'temporary_photo_file.dart';

class ImagePickerPhotoSource implements StudioPhotoSource {
  ImagePickerPhotoSource({ImagePicker? picker}) : _picker = picker ?? ImagePicker();

  final ImagePicker _picker;

  static const double _maxEdge = 1600;
  static const int _quality = 85;

  @override
  Future<StudioPhotoPick?> pickFromGallery() {
    return _pick(ImageSource.gallery, camera: false);
  }

  @override
  Future<StudioPhotoPick?> captureWithCamera() {
    return _pick(ImageSource.camera, camera: true);
  }

  Future<StudioPhotoPick?> _pick(
    ImageSource source, {
    required bool camera,
  }) async {
    try {
      final file = await _picker.pickImage(
        source: source,
        maxWidth: _maxEdge,
        maxHeight: _maxEdge,
        imageQuality: _quality,
        requestFullMetadata: false,
        preferredCameraDevice: CameraDevice.front,
      );
      if (file == null) {
        return null;
      }
      final bytes = await file.readAsBytes();
      await deleteLocalFile(file.path);
      if (bytes.isEmpty) {
        throw const StudioPhotoException(StudioPhotoProblem.failed);
      }
      return StudioPhotoPick(bytes);
    } on StudioPhotoException {
      rethrow;
    } on PlatformException catch (error) {
      throw StudioPhotoException(_mapPlatform(error, camera: camera));
    } on MissingPluginException {
      throw StudioPhotoException(
        camera ? StudioPhotoProblem.unsupported : StudioPhotoProblem.failed,
      );
    } catch (_) {
      throw const StudioPhotoException(StudioPhotoProblem.failed);
    }
  }

  StudioPhotoProblem _mapPlatform(
    PlatformException error, {
    required bool camera,
  }) {
    final text = '${error.code} ${error.message ?? ''}'.toLowerCase();
    if (text.contains('denied') ||
        text.contains('restricted') ||
        text.contains('permission')) {
      return StudioPhotoProblem.permissionDenied;
    }
    if (camera &&
        (text.contains('unavailable') ||
            text.contains('not available') ||
            text.contains('no_available'))) {
      return StudioPhotoProblem.unsupported;
    }
    return StudioPhotoProblem.failed;
  }
}
