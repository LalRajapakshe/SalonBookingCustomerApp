class StylistQualification {
  const StylistQualification({
    required this.name,
    this.level,
    this.institution,
    this.year,
    this.isVerified = false,
  });

  final String name;
  final String? level;
  final String? institution;
  final int? year;
  final bool isVerified;
}

class Stylist {
  const Stylist({
    required this.id,
    required this.name,
    required this.initials,
    required this.specialty,
    required this.categoryId,
    required this.salonId,
    required this.rating,
    this.description = '',
    this.qualifications = const [],
    this.hasPhoto = false,
  });

  final String id;
  final String name;
  final String initials;
  final String specialty;
  final String categoryId;
  final String salonId;
  final double rating;
  final String description;
  final List<StylistQualification> qualifications;
  final bool hasPhoto;

  int? get numericId => int.tryParse(id);
}
