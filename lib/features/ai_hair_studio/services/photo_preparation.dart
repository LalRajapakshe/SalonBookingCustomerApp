import 'dart:math' as math;
import 'dart:typed_data';

import 'package:image/image.dart' as img;

enum PhotoPreparationProblem { empty, tooLarge, unsupported, unreadable, tooSmall }

class PhotoPreparationException implements Exception {
  const PhotoPreparationException(this.problem);

  final PhotoPreparationProblem problem;

  String get message => switch (problem) {
        PhotoPreparationProblem.empty => 'That photo is empty. Choose a different one.',
        PhotoPreparationProblem.tooLarge =>
          'That photo is too large. Choose one under 10 MB.',
        PhotoPreparationProblem.unsupported =>
          'That photo format is not supported. Choose a JPEG, PNG, or WebP image.',
        PhotoPreparationProblem.unreadable =>
          'That image could not be read. Choose a different photo.',
        PhotoPreparationProblem.tooSmall =>
          'That photo is too small. Choose a clearer portrait.',
      };
}

class PreparedPhoto {
  const PreparedPhoto(this.bytes);

  final Uint8List bytes;
}

/// Validates a picked photo, bakes orientation, and compresses it before any
/// upload. The original file is not retained here.
class PhotoPreparation {
  const PhotoPreparation({
    this.maxInputBytes = 10 * 1024 * 1024 - 1,
    this.maxEdge = 1024,
    this.minShortEdge = 128,
    this.jpegQuality = 85,
    this.maxOutputBytes = 3 * 1024 * 1024,
  });

  final int maxInputBytes;
  final int maxEdge;
  final int minShortEdge;
  final int jpegQuality;
  final int maxOutputBytes;

  PreparedPhoto prepare(Uint8List bytes) {
    if (bytes.isEmpty) {
      throw const PhotoPreparationException(PhotoPreparationProblem.empty);
    }
    if (bytes.length > maxInputBytes) {
      throw const PhotoPreparationException(PhotoPreparationProblem.tooLarge);
    }
    if (!_supportedSignature(bytes)) {
      throw const PhotoPreparationException(PhotoPreparationProblem.unsupported);
    }

    final img.Image? decoded;
    try {
      decoded = img.decodeImage(bytes);
    } catch (_) {
      throw const PhotoPreparationException(PhotoPreparationProblem.unreadable);
    }
    if (decoded == null) {
      throw const PhotoPreparationException(PhotoPreparationProblem.unreadable);
    }

    final oriented = img.bakeOrientation(decoded);
    final shortEdge = math.min(oriented.width, oriented.height);
    if (shortEdge < minShortEdge) {
      throw const PhotoPreparationException(PhotoPreparationProblem.tooSmall);
    }

    var quality = jpegQuality;
    var edge = maxEdge;
    Uint8List? encoded;
    for (var attempt = 0; attempt < 4; attempt++) {
      final scaled = _downscale(oriented, edge);
      encoded = img.encodeJpg(scaled, quality: quality);
      if (encoded.length <= maxOutputBytes) {
        return PreparedPhoto(encoded);
      }
      quality = math.max(55, quality - 12);
      edge = math.max(720, (edge * 0.8).round());
    }

    throw const PhotoPreparationException(PhotoPreparationProblem.tooLarge);
  }

  img.Image _downscale(img.Image source, int edge) {
    if (source.width <= edge && source.height <= edge) {
      return source;
    }
    if (source.width >= source.height) {
      return img.copyResize(
        source,
        width: edge,
        interpolation: img.Interpolation.average,
      );
    }
    return img.copyResize(
      source,
      height: edge,
      interpolation: img.Interpolation.average,
    );
  }

  bool _supportedSignature(Uint8List bytes) {
    if (bytes.length >= 3 &&
        bytes[0] == 0xFF &&
        bytes[1] == 0xD8 &&
        bytes[2] == 0xFF) {
      return true;
    }
    if (bytes.length >= 8 &&
        bytes[0] == 0x89 &&
        bytes[1] == 0x50 &&
        bytes[2] == 0x4E &&
        bytes[3] == 0x47) {
      return true;
    }
    if (bytes.length >= 6 &&
        bytes[0] == 0x47 &&
        bytes[1] == 0x49 &&
        bytes[2] == 0x46) {
      return true;
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
      return true;
    }
    return false;
  }
}
