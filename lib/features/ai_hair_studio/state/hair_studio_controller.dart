import 'package:flutter/foundation.dart';

import '../models/hair_style_option.dart';
import '../models/hair_transformation.dart';
import '../services/photo_preparation.dart';
import '../services/studio_photo_source.dart';
import '../services/studio_result_exporter.dart';
import 'hair_studio_bindings.dart';

enum HairStudioStep { landing, photo, style, review, result }

class HairStudioController extends ChangeNotifier {
  HairStudioController({required HairStudioBindings bindings}) : _bindings = bindings;

  final HairStudioBindings _bindings;
  final List<HairStudioStep> _stack = [HairStudioStep.landing];

  Uint8List? _photoBytes;
  String? _photoMessage;
  String? _styleMessage;
  HairStyleOption? _selectedStyle;
  HairColorOption? _selectedColor;
  bool _picking = false;
  bool _generating = false;
  bool _hasConsent = false;
  HairStudioFailure? _failure;
  Uint8List? _resultBytes;
  String? _resultMimeType;
  bool _disposed = false;

  HairStudioStep get step => _stack.last;
  bool get canLeave => _stack.length == 1 && !_generating;
  bool get picking => _picking;
  bool get generating => _generating;
  bool get hasConsent => _hasConsent;
  bool get hasPhoto => _photoBytes != null;

  Uint8List? get photoBytes => _photoBytes;
  String? get photoMessage => _photoMessage;
  String? get styleMessage => _styleMessage;
  HairStyleOption? get selectedStyle => _selectedStyle;
  HairColorOption? get selectedColor => _selectedColor;
  HairStudioFailure? get failure => _failure;
  Uint8List? get resultBytes => _resultBytes;
  String? get resultMimeType => _resultMimeType;

  void openPhoto() => _push(HairStudioStep.photo);

  void continueFromPhoto() {
    if (_photoBytes == null) {
      _photoMessage = 'Choose a photo to continue.';
      _notify();
      return;
    }
    _photoMessage = null;
    _push(HairStudioStep.style);
  }

  void continueFromStyle() {
    if (_selectedStyle == null) {
      _styleMessage = 'Choose a hairstyle to continue.';
      _notify();
      return;
    }
    _styleMessage = null;
    _push(HairStudioStep.review);
  }

  /// Returns true when this controller handled the back action.
  bool back() {
    if (_generating) {
      return true;
    }
    if (_stack.length <= 1) {
      return false;
    }
    _stack.removeLast();
    _notify();
    return true;
  }

  void selectStyle(HairStyleOption style) {
    _selectedStyle = style;
    _styleMessage = null;
    _failure = null;
    _notify();
  }

  void selectColor(HairColorOption? color) {
    _selectedColor = color;
    _failure = null;
    _notify();
  }

  void setConsent(bool value) {
    if (_hasConsent == value) {
      return;
    }
    _hasConsent = value;
    if (value && _failure == HairStudioFailure.missingConsent) {
      _failure = null;
    }
    _notify();
  }

  Future<void> pickFromGallery() {
    return _pick(_bindings.photoSource.pickFromGallery);
  }

  Future<void> captureWithCamera() {
    return _pick(_bindings.photoSource.captureWithCamera);
  }

  void removePhoto() {
    _photoBytes = null;
    _photoMessage = null;
    _hasConsent = false;
    _resultBytes = null;
    _resultMimeType = null;
    _failure = null;
    _notify();
  }

  Future<void> generate() async {
    if (_generating || _disposed) {
      return;
    }
    final photo = _photoBytes;
    final style = _selectedStyle;
    if (photo == null) {
      _failure = HairStudioFailure.missingPhoto;
      _notify();
      return;
    }
    if (style == null) {
      _failure = HairStudioFailure.missingStyle;
      _notify();
      return;
    }
    if (!_hasConsent) {
      _failure = HairStudioFailure.missingConsent;
      _notify();
      return;
    }

    _generating = true;
    _failure = null;
    _resultBytes = null;
    _resultMimeType = null;
    _notify();

    final reference = await _bindings.referenceLoader.load(style);
    if (_disposed) {
      return;
    }
    if (reference == null || reference.isEmpty) {
      _generating = false;
      _failure = HairStudioFailure.referenceUnavailable;
      _notify();
      return;
    }

    HairTransformationOutcome outcome;
    try {
      outcome = await _bindings.client.transform(
        HairTransformationRequest(
          imageBytes: photo,
          mimeType: 'image/jpeg',
          style: style,
          color: _selectedColor,
          referenceBytes: reference,
        ),
      );
    } catch (_) {
      outcome = const HairTransformationOutcome.failure(HairStudioFailure.provider);
    }

    if (_disposed) {
      return;
    }
    _generating = false;
    final returned = outcome.imageBytes;
    final echoed = outcome.isSuccess &&
        returned != null &&
        (sameImageBytes(returned, photo) || sameImageBytes(returned, reference));
    if (outcome.isSuccess && returned != null && !echoed) {
      _resultBytes = returned;
      _resultMimeType = outcome.mimeType;
      _failure = null;
      _stack.add(HairStudioStep.result);
    } else if (echoed) {
      _resultBytes = null;
      _resultMimeType = null;
      _failure = HairStudioFailure.unchangedResult;
    } else {
      _resultBytes = null;
      _resultMimeType = null;
      _failure = outcome.failure ?? HairStudioFailure.provider;
    }
    _notify();
  }

  void tryAnotherStyle() {
    _resultBytes = null;
    _resultMimeType = null;
    _failure = null;
    _stack
      ..clear()
      ..addAll(const [
        HairStudioStep.landing,
        HairStudioStep.photo,
        HairStudioStep.style,
      ]);
    _notify();
  }

  Future<StudioExportResult> saveResult() {
    final bytes = _resultBytes;
    final mimeType = _resultMimeType;
    if (bytes == null || mimeType == null) {
      return Future.value(
        const StudioExportResult(
          StudioExportStatus.failed,
          'There is no generated look to save.',
        ),
      );
    }
    return _bindings.exporter.save(bytes, mimeType: mimeType);
  }

  Future<StudioExportResult> shareResult() {
    final bytes = _resultBytes;
    final mimeType = _resultMimeType;
    if (bytes == null || mimeType == null) {
      return Future.value(
        const StudioExportResult(
          StudioExportStatus.failed,
          'There is no generated look to share.',
        ),
      );
    }
    return _bindings.exporter.share(bytes, mimeType: mimeType);
  }

  Future<void> _pick(Future<StudioPhotoPick?> Function() action) async {
    if (_picking || _generating || _disposed) {
      return;
    }
    _picking = true;
    _photoMessage = null;
    _notify();
    try {
      final picked = await action();
      if (_disposed || picked == null) {
        return;
      }
      final prepared = _bindings.preparation.prepare(picked.bytes);
      _photoBytes = prepared.bytes;
      _hasConsent = false;
      _photoMessage = null;
      _resultBytes = null;
      _resultMimeType = null;
      _failure = null;
    } on PhotoPreparationException catch (error) {
      _photoMessage = error.message;
    } on StudioPhotoException catch (error) {
      _photoMessage = error.message;
    } catch (_) {
      _photoMessage = const StudioPhotoException(StudioPhotoProblem.failed).message;
    } finally {
      _picking = false;
      _notify();
    }
  }

  void _push(HairStudioStep step) {
    _stack.add(step);
    _notify();
  }

  void _notify() {
    if (!_disposed) {
      notifyListeners();
    }
  }

  @override
  void dispose() {
    _disposed = true;
    _photoBytes = null;
    _resultBytes = null;
    super.dispose();
  }
}
