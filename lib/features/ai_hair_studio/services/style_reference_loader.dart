import 'package:flutter/services.dart';

import '../models/hair_style_option.dart';

abstract class StyleReferenceLoader {
  Future<Uint8List?> load(HairStyleOption style);
}

class BundleStyleReferenceLoader implements StyleReferenceLoader {
  const BundleStyleReferenceLoader();

  @override
  Future<Uint8List?> load(HairStyleOption style) async {
    try {
      final data = await rootBundle.load(style.assetPath);
      if (data.lengthInBytes == 0) {
        return null;
      }
      return data.buffer.asUint8List(data.offsetInBytes, data.lengthInBytes);
    } catch (_) {
      return null;
    }
  }
}
