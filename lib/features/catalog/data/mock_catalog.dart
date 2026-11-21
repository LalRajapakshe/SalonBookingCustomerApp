import '../models/app_currency.dart';
import '../models/customer_profile.dart';
import '../models/promotion.dart';
import '../models/salon_place.dart';
import '../models/salon_service.dart';
import '../models/service_category.dart';
import '../models/stylist.dart';

/// Preview catalog for the customer app.
///
/// Prices, people, and places are sample content. Nothing here is loaded from
/// the salon API or database.
class MockCatalog {
  MockCatalog._();

  static const currency = AppCurrency(code: 'LKR', symbol: 'Rs');
  static const anyStylistId = 'any';
  static const anyStylistLabel = 'Any available stylist';

  static const customer = CustomerProfile(
    id: 'customer-maya',
    firstName: 'Maya',
    lastName: 'Fernando',
    initials: 'MF',
    email: 'maya@lumiere.example',
    phone: '+94 77 555 0142',
    city: 'Colombo',
  );

  static const categories = <ServiceCategory>[
    ServiceCategory(id: 'hair', name: 'Hair'),
    ServiceCategory(id: 'nails', name: 'Nails'),
    ServiceCategory(id: 'facial', name: 'Facial'),
    ServiceCategory(id: 'makeup', name: 'Makeup'),
    ServiceCategory(id: 'spa', name: 'Spa'),
  ];

  static const salons = <SalonPlace>[
    SalonPlace(
      id: 'salon-colombo',
      name: 'Lumière Colombo',
      area: 'Kollupitiya',
      highlight: 'Flagship color studio',
      rating: 4.9,
    ),
    SalonPlace(
      id: 'salon-kandy',
      name: 'Lumière Kandy',
      area: 'Kandy city',
      highlight: 'Garden spa studio',
      rating: 4.7,
    ),
  ];

  static const stylists = <Stylist>[
    Stylist(
      id: 'stylist-amara',
      name: 'Amara Jayawardena',
      initials: 'AJ',
      specialty: 'Color and cuts',
      categoryId: 'hair',
      salonId: 'salon-colombo',
      rating: 4.9,
    ),
    Stylist(
      id: 'stylist-nia',
      name: 'Nia Perera',
      initials: 'NP',
      specialty: 'Blowouts and styling',
      categoryId: 'hair',
      salonId: 'salon-colombo',
      rating: 4.8,
    ),
    Stylist(
      id: 'stylist-noah',
      name: 'Noah Silva',
      initials: 'NS',
      specialty: 'Gel nails',
      categoryId: 'nails',
      salonId: 'salon-kandy',
      rating: 4.8,
    ),
    Stylist(
      id: 'stylist-sena',
      name: 'Sena Dias',
      initials: 'SD',
      specialty: 'Glow facials',
      categoryId: 'facial',
      salonId: 'salon-colombo',
      rating: 4.8,
    ),
    Stylist(
      id: 'stylist-lila',
      name: 'Lila Fernando',
      initials: 'LF',
      specialty: 'Soft glam makeup',
      categoryId: 'makeup',
      salonId: 'salon-colombo',
      rating: 5.0,
    ),
    Stylist(
      id: 'stylist-kai',
      name: 'Kai Rahman',
      initials: 'KR',
      specialty: 'Spa rituals',
      categoryId: 'spa',
      salonId: 'salon-kandy',
      rating: 4.7,
    ),
  ];

  static const services = <SalonService>[
    SalonService(
      id: 'svc-blowout',
      categoryId: 'hair',
      salonId: 'salon-colombo',
      name: 'Signature Blowout',
      description:
          'A smooth, bouncy finish with a scalp massage and style that holds through the evening.',
      price: 4500,
      durationMinutes: 45,
      stylistIds: ['stylist-nia', 'stylist-amara'],
      popular: true,
    ),
    SalonService(
      id: 'svc-balayage',
      categoryId: 'hair',
      salonId: 'salon-colombo',
      name: 'Balayage and Gloss',
      description:
          'Sunlit color painted by hand, finished with a glass-like gloss and a cut if you want one.',
      price: 18500,
      durationMinutes: 180,
      stylistIds: ['stylist-amara'],
      popular: true,
    ),
    SalonService(
      id: 'svc-silk-press',
      categoryId: 'hair',
      salonId: 'salon-colombo',
      name: 'Silk Press',
      description:
          'A gentle press for a sleek, shiny shape without losing the health of your hair.',
      price: 7500,
      durationMinutes: 90,
      stylistIds: ['stylist-nia', 'stylist-amara'],
    ),
    SalonService(
      id: 'svc-gel-manicure',
      categoryId: 'nails',
      salonId: 'salon-kandy',
      name: 'Gel Manicure',
      description:
          'Clean prep, a precise shape, and a glossy gel color that stays neat for weeks.',
      price: 3500,
      durationMinutes: 60,
      stylistIds: ['stylist-noah'],
      popular: true,
    ),
    SalonService(
      id: 'svc-soft-gel',
      categoryId: 'nails',
      salonId: 'salon-kandy',
      name: 'Soft Gel Extensions',
      description:
          'Lightweight extensions shaped to your hands, with a natural or bold finish.',
      price: 9000,
      durationMinutes: 100,
      stylistIds: ['stylist-noah'],
    ),
    SalonService(
      id: 'svc-glow-facial',
      categoryId: 'facial',
      salonId: 'salon-colombo',
      name: 'Glow Facial',
      description:
          'A brightening facial with a gentle peel, massage, and a dewy finish for events.',
      price: 6500,
      durationMinutes: 60,
      stylistIds: ['stylist-sena'],
      popular: true,
    ),
    SalonService(
      id: 'svc-hydra-facial',
      categoryId: 'facial',
      salonId: 'salon-colombo',
      name: 'Hydra Glow Facial',
      description:
          'Deep hydration for tired skin, with a calming mask and a light luminous finish.',
      price: 8500,
      durationMinutes: 75,
      stylistIds: ['stylist-sena'],
    ),
    SalonService(
      id: 'svc-event-makeup',
      categoryId: 'makeup',
      salonId: 'salon-colombo',
      name: 'Event Makeup',
      description:
          'Camera-ready makeup with skin prep, defined eyes, and a finish made for long nights.',
      price: 12000,
      durationMinutes: 80,
      stylistIds: ['stylist-lila'],
      popular: true,
    ),
    SalonService(
      id: 'svc-soft-glam',
      categoryId: 'makeup',
      salonId: 'salon-colombo',
      name: 'Soft Glam',
      description:
          'Everyday polish with a lifted lash, warm skin, and a shade that still looks like you.',
      price: 8000,
      durationMinutes: 60,
      stylistIds: ['stylist-lila'],
    ),
    SalonService(
      id: 'svc-aroma',
      categoryId: 'spa',
      salonId: 'salon-kandy',
      name: 'Aromatherapy Massage',
      description:
          'A slow full-body massage with warm oil and a scent chosen for how you want to feel.',
      price: 7000,
      durationMinutes: 60,
      stylistIds: ['stylist-kai'],
    ),
    SalonService(
      id: 'svc-hot-stone',
      categoryId: 'spa',
      salonId: 'salon-kandy',
      name: 'Hot Stone Ritual',
      description:
          'Heated stones and long strokes to ease tension through the back, neck, and shoulders.',
      price: 9500,
      durationMinutes: 90,
      stylistIds: ['stylist-kai'],
      popular: true,
    ),
  ];

  static const promotions = <Promotion>[
    Promotion(
      id: 'promo-season',
      kicker: 'This season',
      title: 'Your glow-up, booked in minutes',
      subtitle: 'Pick a service, a stylist, and a time that fits your week.',
      ctaLabel: 'Book a visit',
    ),
    Promotion(
      id: 'promo-facial',
      kicker: 'Featured',
      title: 'Facials worth leaving the house for',
      subtitle: 'Glow and hydration treatments are highlighted at the Colombo studio.',
      ctaLabel: 'Browse facials',
      categoryId: 'facial',
    ),
    Promotion(
      id: 'promo-nails',
      kicker: 'Studio note',
      title: 'Nail appointments open later',
      subtitle: 'Gel color and extensions are easy to pair with an evening plan.',
      ctaLabel: 'See nails',
      categoryId: 'nails',
    ),
  ];

  static Promotion get heroPromotion => promotions.first;

  static List<Promotion> get offers => promotions.skip(1).toList();

  static List<SalonService> get popularServices =>
      services.where((service) => service.popular).toList();

  static ServiceCategory? categoryById(String id) {
    for (final category in categories) {
      if (category.id == id) return category;
    }
    return null;
  }

  static SalonService? serviceById(String id) {
    for (final service in services) {
      if (service.id == id) return service;
    }
    return null;
  }

  static Stylist? stylistById(String id) {
    for (final stylist in stylists) {
      if (stylist.id == id) return stylist;
    }
    return null;
  }

  static SalonPlace? salonById(String id) {
    for (final salon in salons) {
      if (salon.id == id) return salon;
    }
    return null;
  }

  static String categoryName(String id) => categoryById(id)?.name ?? 'Service';

  static String stylistLabel(String id) {
    if (id == anyStylistId) return anyStylistLabel;
    return stylistById(id)?.name ?? 'Stylist';
  }

  static List<Stylist> stylistsForService(SalonService service) {
    return stylists
        .where((stylist) => service.stylistIds.contains(stylist.id))
        .toList();
  }

  static List<SalonService> search({
    String query = '',
    String? categoryId,
  }) {
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
