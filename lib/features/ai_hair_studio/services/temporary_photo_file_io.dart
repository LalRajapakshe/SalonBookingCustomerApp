import 'dart:io';
import 'dart:typed_data';

import 'package:share_plus/share_plus.dart';

import 'shared_image_file.dart';

export 'shared_image_file.dart';

Future<void> deleteLocalFile(String path) async {
  try {
    if (path.isEmpty || path.startsWith('content:') || path.startsWith('blob:')) {
      return;
    }
    final file = File(path);
    if (await file.exists()) {
      await file.delete();
    }
  } catch (_) {
    // The picker cache is temporary. Keeping the in-memory copy is enough.
  }
}

Future<SharedImageFile> createSharedImageFile(
  Uint8List bytes,
  String mimeType,
) async {
  final directory = await Directory.systemTemp.createTemp('lumiere_hair_share');
  final extension = switch (mimeType) {
    'image/png' => '.png',
    'image/webp' => '.webp',
    _ => '.jpg',
  };
  final file = File(
    '${directory.path}${Platform.pathSeparator}lumiere-hair-look$extension',
  );
  await file.writeAsBytes(bytes, flush: true);
  return SharedImageFile(
    xFile: XFile(
      file.path,
      mimeType: mimeType,
      name: 'lumiere-hair-look$extension',
    ),
    cleanup: () async {
      try {
        if (await file.exists()) {
          await file.delete();
        }
      } catch (_) {}
      try {
        if (await directory.exists()) {
          await directory.delete(recursive: true);
        }
      } catch (_) {}
    },
  );
}
