import '../models/salon_place.dart';
import '../models/salon_service.dart';
import '../models/service_category.dart';
import '../models/stylist.dart';
import 'mock_catalog.dart';

class SalonCatalog {
  const SalonCatalog({
    required this.isLive,
    required this.categories,
    required this.salons,
    required this.services,
    required this.stylists,
  });

  final bool isLive;
  final List<ServiceCategory> categories;
  final List<SalonPlace> salons;
  final List<SalonService> services;
  final List<Stylist> stylists;

  static const anyStylistId = MockCatalog.anyStylistId;
  static const anyStylistLabel = MockCatalog.anyStylistLabel;

  static final preview = SalonCatalog(
    isLive: false,
    categories: MockCatalog.categories,
    salons: MockCatalog.salons,
    services: MockCatalog.services,
    stylists: MockCatalog.stylists,
  );

  static const emptyLive = SalonCatalog(
    isLive: true,
    categories: [],
    salons: [],
    services: [],
    stylists: [],
  );

  List<SalonService> get popularServices =>
      services.where((service) => service.popular).toList();

  ServiceCategory? categoryById(String id) {
    for (final category in categories) {
      if (category.id == id) return category;
    }
    return null;
  }

  SalonService? serviceById(String id) {
    for (final service in services) {
      if (service.id == id) return service;
    }
    return null;
  }

  Stylist? stylistById(String id) {
    for (final stylist in stylists) {
      if (stylist.id == id) return stylist;
    }
    return null;
  }

  SalonPlace? salonById(String id) {
    for (final salon in salons) {
      if (salon.id == id) return salon;
    }
    return null;
  }

  String categoryName(String id) => categoryById(id)?.name ?? 'Service';

  String stylistLabel(String id) {
    if (id == anyStylistId) return anyStylistLabel;
    return stylistById(id)?.name ?? 'Stylist';
  }

  List<Stylist> stylistsForService(SalonService service) {
    return stylists.where((stylist) => service.stylistIds.contains(stylist.id)).toList();
  }

  List<SalonService> search({String query = '', String? categoryId}) {
    final needle = query.trim().toLowerCase();
    return services.where((service) {
      final categoryMatches = categoryId == null || service.categoryId == categoryId;
      if (!categoryMatches) return false;
      if (needle.isEmpty) return true;
      final category = categoryName(service.categoryId).toLowerCase();
      return service.name.toLowerCase().contains(needle) ||
          service.description.toLowerCase().contains(needle) ||
          category.contains(needle);
    }).toList();
  }
}
