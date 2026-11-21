import 'dart:io';
import 'dart:math';
import 'dart:typed_data';

/// Builds original reference art for the inspiration gallery.
///
/// These illustrations are generated locally. They are not photographs of a
/// customer, stylist, or salon.
void main() {
  final root = File(Platform.script.toFilePath()).parent.parent;
  final directory = Directory('${root.path}${Platform.pathSeparator}assets${Platform.pathSeparator}images${Platform.pathSeparator}inspiration');
  directory.createSync(recursive: true);

  const specs = <_ArtSpec>[
    _ArtSpec('layered_cut', _Motif.waves, 11, [0xF6D7E4, 0xC084FC, 0xBE185D]),
    _ArtSpec('textured_bob', _Motif.bob, 23, [0xFDE68A, 0xF9A8D4, 0x7C3AED]),
    _ArtSpec('curtain_bangs', _Motif.fringe, 37, [0xFFE4E6, 0xF9A8D4, 0x9D174D]),
    _ArtSpec('pixie_shape', _Motif.crop, 41, [0xE9D5FF, 0xA78BFA, 0x4C1D95]),
    _ArtSpec('blunt_lob', _Motif.bob, 53, [0xFFEDD5, 0xFB7185, 0x9F1239]),
    _ArtSpec('lived_in_shag', _Motif.waves, 67, [0xFBCFE8, 0xF59E0B, 0x7C2D12]),
    _ArtSpec('sunlit_balayage', _Motif.melt, 71, [0xFEF3C7, 0xFBBF24, 0xB45309]),
    _ArtSpec('chocolate_gloss', _Motif.melt, 83, [0xE7C8B0, 0x92400E, 0x44403C]),
    _ArtSpec('money_pieces', _Motif.melt, 97, [0xFEF9C3, 0xFDE047, 0xA16207]),
    _ArtSpec('rose_brown', _Motif.melt, 103, [0xFCE7F3, 0xE11D48, 0x881337]),
    _ArtSpec('silk_finish', _Motif.silk, 109, [0xF8FAFC, 0xC4B5FD, 0x6D28D9]),
    _ArtSpec('blowout_waves', _Motif.waves, 127, [0xFDF2F8, 0xF472B6, 0x9D174D]),
    _ArtSpec('nude_manicure', _Motif.nail, 131, [0xFFF7ED, 0xE7C3B0, 0xBE185D]),
    _ArtSpec('cherry_tips', _Motif.nail, 139, [0xFFE4E6, 0xFB7185, 0x9F1239]),
    _ArtSpec('pink_nail_art', _Motif.nail, 149, [0xFCE7F3, 0xF472B6, 0xDB2777]),
    _ArtSpec('soft_gel', _Motif.nail, 157, [0xF5F3FF, 0xC4B5FD, 0x6D28D9]),
    _ArtSpec('soft_glam', _Motif.petals, 163, [0xFFF1F2, 0xF9A8D4, 0xBE185D]),
    _ArtSpec('berry_evening', _Motif.petals, 173, [0xFBCFE8, 0xBE123C, 0x4C1D95]),
    _ArtSpec('dewy_day', _Motif.petals, 181, [0xECFEFF, 0xF9A8D4, 0xA21CAF]),
    _ArtSpec('glass_skin', _Motif.ripples, 191, [0xF0FDFA, 0x99F6E4, 0x0F766E]),
    _ArtSpec('hydration', _Motif.ripples, 197, [0xEFF6FF, 0x93C5FD, 0x6D28D9]),
    _ArtSpec('glow_prep', _Motif.ripples, 211, [0xFFF7ED, 0xFDBA74, 0xBE185D]),
  ];

  final hashes = <int>{};
  for (final spec in specs) {
    final bytes = _render(spec);
    final hash = Object.hashAll(bytes);
    if (!hashes.add(hash)) {
      throw StateError('Duplicate image for ${spec.name}');
    }
    final file = File('${directory.path}${Platform.pathSeparator}${spec.name}.png');
    file.writeAsBytesSync(_encodePng(bytes, _width, _height));
  }
}

const _width = 540;
const _height = 720;

enum _Motif { waves, bob, fringe, crop, melt, silk, nail, petals, ripples }

class _ArtSpec {
  const _ArtSpec(this.name, this.motif, this.seed, this.colors);

  final String name;
  final _Motif motif;
  final int seed;
  final List<int> colors;
}

Uint8List _render(_ArtSpec spec) {
  final rgb = Uint8List(_width * _height * 3);
  final rng = _Rng(spec.seed);
  final a = _Rgb.fromInt(spec.colors[0]);
  final b = _Rgb.fromInt(spec.colors[1]);
  final c = _Rgb.fromInt(spec.colors[2]);

  for (var y = 0; y < _height; y++) {
    for (var x = 0; x < _width; x++) {
      final nx = x / (_width - 1);
      final ny = y / (_height - 1);
      final tone = (nx * 0.28 + ny * 0.72).clamp(0.0, 1.0);
      var color = _Rgb.lerp(a, b, tone);
      color = _Rgb.lerp(color, c, nx * ny * 0.35);
      _set(rgb, x, y, color);
    }
  }

  _orb(rgb, _width * (0.22 + rng.next() * 0.2), _height * (0.18 + rng.next() * 0.1), 180, b, 0.28);
  _orb(rgb, _width * (0.72 + rng.next() * 0.1), _height * (0.62 + rng.next() * 0.1), 220, c, 0.22);
  _orb(rgb, _width * 0.5, _height * 0.42, 120, _Rgb.lerp(a, const _Rgb(255, 255, 255), 0.7), 0.2);

  switch (spec.motif) {
    case _Motif.waves:
      for (var i = 0; i < 6; i++) {
        _ribbon(
          rgb,
          yBase: 150 + i * 82,
          amplitude: 22 + i * 3,
          thickness: 14,
          phase: i * 0.7,
          frequency: 2.2 + (i % 2) * 0.4,
          color: i.isEven ? const _Rgb(255, 247, 250) : c,
          alpha: i.isEven ? 0.55 : 0.28,
        );
      }
    case _Motif.bob:
      _arc(rgb, _width * 0.5, _height * 0.46, 150, 190, 16, const _Rgb(255, 250, 252), 0.7);
      _arc(rgb, _width * 0.5, _height * 0.5, 116, 150, 8, c, 0.45);
    case _Motif.fringe:
      for (var i = 0; i < 9; i++) {
        _ribbon(
          rgb,
          yBase: 210,
          amplitude: 16,
          thickness: 7,
          phase: i * 0.35,
          frequency: 1.2,
          color: const _Rgb(255, 250, 252),
          alpha: 0.18,
        );
      }
      for (var i = 0; i < 7; i++) {
        final x = 90.0 + i * 58;
        _strokeLine(rgb, x, 80, x + (i - 3) * 10, 250, 8, const _Rgb(255, 250, 252), 0.55);
      }
    case _Motif.crop:
      _roundRect(rgb, 150, 160, 240, 280, 80, const _Rgb(255, 250, 252), 0.35);
      _roundRect(rgb, 190, 210, 160, 180, 70, c, 0.4);
    case _Motif.melt:
      for (var i = 0; i < 5; i++) {
        _ribbon(
          rgb,
          yBase: 120 + i * 110,
          amplitude: 36,
          thickness: 28,
          phase: i * 0.9,
          frequency: 1.4,
          color: i.isEven ? const _Rgb(255, 251, 235) : c,
          alpha: 0.4,
        );
      }
    case _Motif.silk:
      for (var i = 0; i < 8; i++) {
        _strokeLine(rgb, 70, 80 + i * 70, 470, 120 + i * 70, 10, const _Rgb(255, 255, 255), 0.45);
      }
    case _Motif.nail:
      _capsule(rgb, _width * 0.5, _height * 0.48, 78, 210, const _Rgb(255, 248, 245), 0.92);
      _capsule(rgb, _width * 0.5, _height * 0.30, 78, 70, c, 0.85);
      _orb(rgb, _width * 0.42, _height * 0.36, 28, const _Rgb(255, 255, 255), 0.55);
    case _Motif.petals:
      for (var i = 0; i < 6; i++) {
        final angle = i * pi / 3;
        _orb(
          rgb,
          _width * 0.5 + cos(angle) * 90,
          _height * 0.42 + sin(angle) * 110,
          70,
          i.isEven ? const _Rgb(255, 241, 246) : c,
          0.45,
        );
      }
      _orb(rgb, _width * 0.5, _height * 0.42, 36, const _Rgb(255, 255, 255), 0.7);
    case _Motif.ripples:
      for (var i = 1; i <= 5; i++) {
        _ring(rgb, _width * 0.5, _height * 0.46, 40.0 + i * 38, 7, const _Rgb(255, 255, 255), 0.45);
      }
      _orb(rgb, _width * 0.62, _height * 0.28, 24, const _Rgb(255, 255, 255), 0.7);
      _orb(rgb, _width * 0.34, _height * 0.62, 16, const _Rgb(255, 255, 255), 0.65);
  }

  for (var y = 0; y < _height; y++) {
    for (var x = 0; x < _width; x++) {
      final dx = x / _width - 0.5;
      final dy = y / _height - 0.5;
      final vignette = (dx * dx * 1.2 + dy * dy) * 0.45;
      _blend(rgb, x, y, const _Rgb(36, 16, 32), vignette);
    }
  }
  return rgb;
}

void _set(Uint8List rgb, int x, int y, _Rgb color) {
  if (x < 0 || y < 0 || x >= _width || y >= _height) return;
  final index = (y * _width + x) * 3;
  rgb[index] = color.r;
  rgb[index + 1] = color.g;
  rgb[index + 2] = color.b;
}

void _blend(Uint8List rgb, int x, int y, _Rgb color, double alpha) {
  if (alpha <= 0 || x < 0 || y < 0 || x >= _width || y >= _height) return;
  final clamped = alpha > 1 ? 1.0 : alpha;
  final index = (y * _width + x) * 3;
  rgb[index] = (rgb[index] + (color.r - rgb[index]) * clamped).round();
  rgb[index + 1] = (rgb[index + 1] + (color.g - rgb[index + 1]) * clamped).round();
  rgb[index + 2] = (rgb[index + 2] + (color.b - rgb[index + 2]) * clamped).round();
}

void _orb(Uint8List rgb, double cx, double cy, double radius, _Rgb color, double alpha) {
  final minX = max(0, (cx - radius).floor());
  final maxX = min(_width - 1, (cx + radius).ceil());
  final minY = max(0, (cy - radius).floor());
  final maxY = min(_height - 1, (cy + radius).ceil());
  for (var y = minY; y <= maxY; y++) {
    for (var x = minX; x <= maxX; x++) {
      final dx = x - cx;
      final dy = y - cy;
      final distance = sqrt(dx * dx + dy * dy) / radius;
      if (distance >= 1) continue;
      final falloff = 1 - distance;
      _blend(rgb, x, y, color, alpha * falloff * falloff);
    }
  }
}

void _ring(
  Uint8List rgb,
  double cx,
  double cy,
  double radius,
  double thickness,
  _Rgb color,
  double alpha,
) {
  final outer = radius + thickness;
  final minX = max(0, (cx - outer).floor());
  final maxX = min(_width - 1, (cx + outer).ceil());
  final minY = max(0, (cy - outer).floor());
  final maxY = min(_height - 1, (cy + outer).ceil());
  for (var y = minY; y <= maxY; y++) {
    for (var x = minX; x <= maxX; x++) {
      final dx = x - cx;
      final dy = y - cy;
      final distance = (sqrt(dx * dx + dy * dy) - radius).abs();
      if (distance >= thickness) continue;
      _blend(rgb, x, y, color, alpha * (1 - distance / thickness));
    }
  }
}

void _ribbon(
  Uint8List rgb, {
  required double yBase,
  required double amplitude,
  required double thickness,
  required double phase,
  required double frequency,
  required _Rgb color,
  required double alpha,
}) {
  final minY = max(0, (yBase - amplitude - thickness).floor());
  final maxY = min(_height - 1, (yBase + amplitude + thickness).ceil());
  for (var y = minY; y <= maxY; y++) {
    for (var x = 0; x < _width; x++) {
      final wave = yBase + sin(x / _width * pi * frequency * 2 + phase) * amplitude;
      final distance = (y - wave).abs();
      if (distance >= thickness) continue;
      _blend(rgb, x, y, color, alpha * (1 - distance / thickness));
    }
  }
}

void _arc(
  Uint8List rgb,
  double cx,
  double cy,
  double rx,
  double ry,
  double thickness,
  _Rgb color,
  double alpha,
) {
  final minX = max(0, (cx - rx - thickness).floor());
  final maxX = min(_width - 1, (cx + rx + thickness).ceil());
  final minY = max(0, (cy - ry - thickness).floor());
  final maxY = min(_height - 1, (cy + ry + thickness).ceil());
  for (var y = minY; y <= maxY; y++) {
    if (y < cy) continue;
    for (var x = minX; x <= maxX; x++) {
      final nx = (x - cx) / rx;
      final ny = (y - cy) / ry;
      final distance = (sqrt(nx * nx + ny * ny) - 1).abs() * min(rx, ry);
      if (distance >= thickness) continue;
      _blend(rgb, x, y, color, alpha * (1 - distance / thickness));
    }
  }
}

void _strokeLine(
  Uint8List rgb,
  double x0,
  double y0,
  double x1,
  double y1,
  double thickness,
  _Rgb color,
  double alpha,
) {
  final length = sqrt(pow(x1 - x0, 2) + pow(y1 - y0, 2));
  final steps = max(1, length.ceil());
  for (var i = 0; i <= steps; i++) {
    final t = i / steps;
    _orb(rgb, x0 + (x1 - x0) * t, y0 + (y1 - y0) * t, thickness, color, alpha);
  }
}

void _roundRect(
  Uint8List rgb,
  double left,
  double top,
  double width,
  double height,
  double radius,
  _Rgb color,
  double alpha,
) {
  final right = left + width;
  final bottom = top + height;
  for (var y = max(0, top.floor()); y <= min(_height - 1, bottom.ceil()); y++) {
    for (var x = max(0, left.floor()); x <= min(_width - 1, right.ceil()); x++) {
      final dx = max(left + radius - x, max(0, x - (right - radius))).toDouble();
      final dy = max(top + radius - y, max(0, y - (bottom - radius))).toDouble();
      if (dx == 0 && dy == 0 || dx * dx + dy * dy <= radius * radius) {
        _blend(rgb, x, y, color, alpha);
      }
    }
  }
}

void _capsule(
  Uint8List rgb,
  double cx,
  double cy,
  double halfWidth,
  double halfHeight,
  _Rgb color,
  double alpha,
) {
  final radius = halfWidth;
  final minX = max(0, (cx - halfWidth).floor());
  final maxX = min(_width - 1, (cx + halfWidth).ceil());
  final minY = max(0, (cy - halfHeight).floor());
  final maxY = min(_height - 1, (cy + halfHeight).ceil());
  final bodyTop = cy - halfHeight + radius;
  final bodyBottom = cy + halfHeight - radius;
  for (var y = minY; y <= maxY; y++) {
    for (var x = minX; x <= maxX; x++) {
      final insideBody = y >= bodyTop && y <= bodyBottom && (x - cx).abs() <= halfWidth;
      final topCap = pow(x - cx, 2) + pow(y - bodyTop, 2) <= radius * radius && y < bodyTop;
      final bottomCap = pow(x - cx, 2) + pow(y - bodyBottom, 2) <= radius * radius && y > bodyBottom;
      if (insideBody || topCap || bottomCap) {
        _blend(rgb, x, y, color, alpha);
      }
    }
  }
}

class _Rgb {
  const _Rgb(this.r, this.g, this.b);

  factory _Rgb.fromInt(int value) {
    return _Rgb((value >> 16) & 255, (value >> 8) & 255, value & 255);
  }

  final int r;
  final int g;
  final int b;

  static _Rgb lerp(_Rgb a, _Rgb b, double t) {
    final clamped = t.clamp(0.0, 1.0);
    return _Rgb(
      (a.r + (b.r - a.r) * clamped).round(),
      (a.g + (b.g - a.g) * clamped).round(),
      (a.b + (b.b - a.b) * clamped).round(),
    );
  }

}

class _Rng {
  _Rng(this._state);

  int _state;

  double next() {
    _state = (1664525 * _state + 1013904223) & 0x7fffffff;
    return _state / 0x7fffffff;
  }
}

Uint8List _encodePng(Uint8List rgb, int width, int height) {
  final raw = BytesBuilder(copy: false);
  final stride = width * 3;
  for (var y = 0; y < height; y++) {
    raw.addByte(0);
    raw.add(rgb.sublist(y * stride, (y + 1) * stride));
  }
  final compressed = ZLibEncoder(level: 6).convert(raw.takeBytes());
  final output = BytesBuilder(copy: false);
  output.add(const [137, 80, 78, 71, 13, 10, 26, 10]);
  final header = ByteData(13)
    ..setUint32(0, width)
    ..setUint32(4, height)
    ..setUint8(8, 8)
    ..setUint8(9, 2);
  _chunk(output, 'IHDR', header.buffer.asUint8List());
  _chunk(output, 'IDAT', Uint8List.fromList(compressed));
  _chunk(output, 'IEND', Uint8List(0));
  return output.toBytes();
}

void _chunk(BytesBuilder output, String type, Uint8List data) {
  final typeBytes = type.codeUnits;
  final length = ByteData(4)..setUint32(0, data.length);
  output.add(length.buffer.asUint8List());
  output.add(typeBytes);
  output.add(data);
  final signed = Uint8List(typeBytes.length + data.length);
  signed.setRange(0, typeBytes.length, typeBytes);
  signed.setRange(typeBytes.length, signed.length, data);
  final crc = ByteData(4)..setUint32(0, _crc32(signed));
  output.add(crc.buffer.asUint8List());
}

int _crc32(Uint8List data) {
  var crc = 0xFFFFFFFF;
  for (final byte in data) {
    crc ^= byte;
    for (var bit = 0; bit < 8; bit++) {
      final lsb = crc & 1;
      crc = (crc >> 1) & 0x7FFFFFFF;
      if (lsb == 1) crc ^= 0xEDB88320;
    }
  }
  return (crc ^ 0xFFFFFFFF) & 0xFFFFFFFF;
}
