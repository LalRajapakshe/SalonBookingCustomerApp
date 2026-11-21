import 'dart:typed_data';

import 'hair_style_option.dart';

class HairTransformationRequest {
  const HairTransformationRequest({
    required this.imageBytes,
    required this.mimeType,
    required this.style,
    this.color,
    this.referenceBytes,
  });

  final Uint8List imageBytes;
  final String mimeType;
  final HairStyleOption style;
  final HairColorOption? color;

  /// Bundled example photograph for the selected style. The proxy uploads this
  /// as the Perfect Corp reference image. It is not a customer result.
  final Uint8List? referenceBytes;
}

bool sameImageBytes(Uint8List left, Uint8List right) {
  if (identical(left, right)) {
    return true;
  }
  if (left.length != right.length) {
    return false;
  }
  for (var index = 0; index < left.length; index++) {
    if (left[index] != right[index]) {
      return false;
    }
  }
  return true;
}

enum HairStudioFailureCode {
  missingPhoto,
  missingStyle,
  missingConsent,
  referenceUnavailable,
  unchangedResult,
  notConnected,
  insecureConfiguration,
  timeout,
  network,
  unsupportedImage,
  rateLimited,
  tooLarge,
  provider,
}

class HairStudioFailure {
  const HairStudioFailure(this.code, this.message);

  final HairStudioFailureCode code;
  final String message;

  static const missingPhoto = HairStudioFailure(
    HairStudioFailureCode.missingPhoto,
    'Choose a photo before generating a look.',
  );

  static const missingStyle = HairStudioFailure(
    HairStudioFailureCode.missingStyle,
    'Choose a hairstyle before generating a look.',
  );

  static const missingConsent = HairStudioFailure(
    HairStudioFailureCode.missingConsent,
    'Agree to send this photo to Perfect Corp before generating a look. '
        'Nothing has been uploaded.',
  );

  static const referenceUnavailable = HairStudioFailure(
    HairStudioFailureCode.referenceUnavailable,
    'The example photo for this hairstyle is unavailable, so nothing was uploaded.',
  );

  static const unchangedResult = HairStudioFailure(
    HairStudioFailureCode.unchangedResult,
    'The service returned the original photo or the example style photo. '
        'That is not a new hairstyle, so it is not shown as your result.',
  );

  static const notConnected = HairStudioFailure(
    HairStudioFailureCode.notConnected,
    'AI hairstyle generation is not connected yet. Your photo was not uploaded, '
        'and a sample image is not being shown as your result.',
  );

  static const insecureConfiguration = HairStudioFailure(
    HairStudioFailureCode.insecureConfiguration,
    'The AI service address is not secure, so your photo was not uploaded.',
  );

  static const timeout = HairStudioFailure(
    HairStudioFailureCode.timeout,
    'The AI service took too long. Try again. Your photo and hairstyle are still selected.',
  );

  static const network = HairStudioFailure(
    HairStudioFailureCode.network,
    'The AI service could not be reached. Check your connection and try again. '
        'Your photo and hairstyle are still selected.',
  );

  static const unsupportedImage = HairStudioFailure(
    HairStudioFailureCode.unsupportedImage,
    'The AI service could not use this photo. Choose a clearer portrait and try again.',
  );

  static const shouldersNeeded = HairStudioFailure(
    HairStudioFailureCode.unsupportedImage,
    'The provider needs your shoulders in the photo. Choose another portrait and try again.',
  );

  static const faceAngle = HairStudioFailure(
    HairStudioFailureCode.unsupportedImage,
    'The provider needs a more front-facing photo. Choose another portrait and try again.',
  );

  static const facePose = HairStudioFailure(
    HairStudioFailureCode.unsupportedImage,
    'The provider could not use this pose. Choose a clearer, front-facing portrait and try again.',
  );

  static const landmarks = HairStudioFailure(
    HairStudioFailureCode.unsupportedImage,
    'The provider could not find a full face in this photo. Choose another portrait and try again.',
  );

  static const hairTooShort = HairStudioFailure(
    HairStudioFailureCode.unsupportedImage,
    'The provider could not apply this style to the hair in the photo. Try another portrait or style.',
  );

  static const rateLimited = HairStudioFailure(
    HairStudioFailureCode.rateLimited,
    'The AI service is busy right now. Wait a moment, then try again. '
        'Your photo and hairstyle are still selected.',
  );

  static const tooLarge = HairStudioFailure(
    HairStudioFailureCode.tooLarge,
    'That photo is too large for the AI service. Choose a smaller one and try again.',
  );

  static const provider = HairStudioFailure(
    HairStudioFailureCode.provider,
    'The AI service could not create a look. Try again. Your photo and hairstyle are still selected.',
  );

  static HairStudioFailure fromProviderCode(String code) {
    return switch (code) {
      'rate_limited' => rateLimited,
      'unsupported_image' => unsupportedImage,
      'timeout' => timeout,
      'too_large' => tooLarge,
      'error_no_shoulder' => shouldersNeeded,
      'error_large_face_angle' => faceAngle,
      'error_face_pose' => facePose,
      'error_insufficient_landmarks' => landmarks,
      'error_hair_too_short' => hairTooShort,
      _ => provider,
    };
  }
}

class HairTransformationOutcome {
  const HairTransformationOutcome.success({
    required this.imageBytes,
    required this.mimeType,
  }) : failure = null;

  const HairTransformationOutcome.failure(this.failure)
      : imageBytes = null,
        mimeType = null;

  final Uint8List? imageBytes;
  final String? mimeType;
  final HairStudioFailure? failure;

  bool get isSuccess => imageBytes != null && mimeType != null && failure == null;
}
