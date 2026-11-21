class SalonPlace {
  const SalonPlace({
    required this.id,
    required this.name,
    required this.area,
    required this.highlight,
    required this.rating,
    this.hasPhoto = false,
  });

  final String id;
  final String name;
  final String area;
  final String highlight;
  final double rating;
  final bool hasPhoto;
}
