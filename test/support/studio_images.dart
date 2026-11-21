import 'dart:typed_data';

import 'package:image/image.dart' as img;

Uint8List solidJpeg(int red, int green, int blue, {int width = 180, int height = 160}) {
  final picture = img.Image(width: width, height: height);
  img.fill(picture, color: img.ColorRgb8(red, green, blue));
  return img.encodeJpg(picture, quality: 90);
}

Uint8List solidPng(int red, int green, int blue, {int size = 160}) {
  final picture = img.Image(width: size, height: size);
  img.fill(picture, color: img.ColorRgb8(red, green, blue));
  return img.encodePng(picture);
}
