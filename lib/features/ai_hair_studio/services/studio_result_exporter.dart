import 'dart:typed_data';

enum StudioExportStatus { saved, shared, unavailable, permissionDenied, failed }

class StudioExportResult {
  const StudioExportResult(this.status, this.message);

  final StudioExportStatus status;
  final String message;
}

abstract class StudioResultExporter {
  Future<StudioExportResult> save(Uint8List bytes, {required String mimeType});

  Future<StudioExportResult> share(Uint8List bytes, {required String mimeType});
}
