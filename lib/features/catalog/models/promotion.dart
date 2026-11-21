class Promotion {
  const Promotion({
    required this.id,
    required this.kicker,
    required this.title,
    required this.subtitle,
    required this.ctaLabel,
    this.categoryId,
  });

  final String id;
  final String kicker;
  final String title;
  final String subtitle;
  final String ctaLabel;

  /// When set, the offer opens that category. Otherwise it starts booking.
  final String? categoryId;
}
