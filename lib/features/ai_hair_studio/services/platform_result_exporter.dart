import 'package:flutter/services.dart';
import 'package:gal/gal.dart';
import 'package:share_plus/share_plus.dart';

import 'studio_result_exporter.dart';
import 'temporary_photo_file.dart';

class PlatformStudioExporter implements StudioResultExporter {
  const PlatformStudioExporter();

  @override
  Future<StudioExportResult> save(
    Uint8List bytes, {
    required String mimeType,
  }) async {
    if (!_canSave(mimeType)) {
      return const StudioExportResult(
        StudioExportStatus.failed,
        'This image format cannot be saved on this device.',
      );
    }
    try {
      final allowed = await Gal.hasAccess();
      if (!allowed) {
        final granted = await Gal.requestAccess();
        if (!granted) {
          return const StudioExportResult(
            StudioExportStatus.permissionDenied,
            'Photo library access was denied, so the look was not saved.',
          );
        }
      }
      await Gal.putImageBytes(bytes, name: 'lumiere-hair-look');
      return const StudioExportResult(
        StudioExportStatus.saved,
        'Saved to your photos.',
      );
    } on GalException catch (error) {
      if (error.type == GalExceptionType.accessDenied) {
        return const StudioExportResult(
          StudioExportStatus.permissionDenied,
          'Photo library access was denied, so the look was not saved.',
        );
      }
      if (error.type == GalExceptionType.notSupportedFormat) {
        return const StudioExportResult(
          StudioExportStatus.failed,
          'This image format cannot be saved on this device.',
        );
      }
      return const StudioExportResult(
        StudioExportStatus.unavailable,
        'Saving to photos is not available on this device. You can share the look instead.',
      );
    } on MissingPluginException {
      return const StudioExportResult(
        StudioExportStatus.unavailable,
        'Saving to photos is not available on this device. You can share the look instead.',
      );
    } catch (_) {
      return const StudioExportResult(
        StudioExportStatus.failed,
        'The look could not be saved.',
      );
    }
  }

  @override
  Future<StudioExportResult> share(
    Uint8List bytes, {
    required String mimeType,
  }) async {
    final shared = await createSharedImageFile(bytes, mimeType);
    try {
      await SharePlus.instance.share(
        ShareParams(
          files: [shared.xFile],
          subject: 'Lumière hairstyle preview',
          title: 'Lumière hairstyle preview',
          sharePositionOrigin: const Rect.fromLTWH(1, 1, 2, 2),
        ),
      );
      return const StudioExportResult(
        StudioExportStatus.shared,
        'Share sheet opened.',
      );
    } on MissingPluginException {
      return const StudioExportResult(
        StudioExportStatus.unavailable,
        'Sharing is not available on this device.',
      );
    } catch (_) {
      return const StudioExportResult(
        StudioExportStatus.failed,
        'The look could not be shared.',
      );
    } finally {
      await shared.cleanup();
    }
  }

  bool _canSave(String mimeType) {
    return mimeType == 'image/jpeg' || mimeType == 'image/png';
  }
}
