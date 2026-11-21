import 'dart:typed_data';

enum StudioPhotoProblem { permissionDenied, unsupported, failed }

class StudioPhotoException implements Exception {
  const StudioPhotoException(this.problem);

  final StudioPhotoProblem problem;

  String get message => switch (problem) {
        StudioPhotoProblem.permissionDenied =>
          'Photo access was denied. You can allow it in your device settings and try again.',
        StudioPhotoProblem.unsupported =>
          'The camera is not available on this device. You can choose a photo from the gallery instead.',
        StudioPhotoProblem.failed => 'The photo could not be opened. Please try again.',
      };
}

class StudioPhotoPick {
  const StudioPhotoPick(this.bytes);

  final Uint8List bytes;
}

/// Gallery and camera access. Returning null means the customer cancelled.
abstract class StudioPhotoSource {
  Future<StudioPhotoPick?> pickFromGallery();

  Future<StudioPhotoPick?> captureWithCamera();
}
