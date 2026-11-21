class SalonService {
  const SalonService({
    required this.id,
    required this.categoryId,
    required this.salonId,
    required this.name,
    required this.description,
    required this.price,
    required this.durationMinutes,
    required this.stylistIds,
    this.popular = false,
    this.hasPhoto = false,
  });

  final String id;
  final String categoryId;
  final String salonId;
  final String name;
  final String description;
  final int price;
  final int durationMinutes;
  final List<String> stylistIds;
  final bool popular;
  final bool hasPhoto;

  int? get numericId => int.tryParse(id);

  int? get numericBranchId => int.tryParse(salonId);
}
