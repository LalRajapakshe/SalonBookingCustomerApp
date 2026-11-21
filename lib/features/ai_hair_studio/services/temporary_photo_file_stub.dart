import 'dart:typed_data';

import 'package:share_plus/share_plus.dart';

import 'shared_image_file.dart';

export 'shared_image_file.dart';

Future<void> deleteLocalFile(String path) async {}

Future<SharedImageFile> createSharedImageFile(
  Uint8List bytes,
  String mimeType,
) async {
  return SharedImageFile(
    xFile: XFile.fromData(
      bytes,
      mimeType: mimeType,
      name: 'lumiere-hair-look${_extensionFor(mimeType)}',
    ),
    cleanup: () async {},
  );
}

String _extensionFor(String mimeType) {
  return switch (mimeType) {
    'image/png' => '.png',
    'image/webp' => '.webp',
    _ => '.jpg',
  };
}
