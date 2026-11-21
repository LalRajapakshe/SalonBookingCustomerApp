class HairStyleOption {
  const HairStyleOption({
    required this.id,
    required this.name,
    required this.summary,
    required this.instruction,
    required this.assetPath,
  });

  final String id;
  final String name;
  final String summary;
  final String instruction;

  /// Bundled example portrait. This is a style reference, not a customer result.
  final String assetPath;
}

class HairColorOption {
  const HairColorOption({
    required this.id,
    required this.name,
    required this.instruction,
    required this.swatch,
  });

  final String id;
  final String name;
  final String instruction;

  /// ARGB colour used only for the on-device swatch.
  final int swatch;
}
