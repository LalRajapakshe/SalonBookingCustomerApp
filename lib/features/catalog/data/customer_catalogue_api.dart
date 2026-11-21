import '../../../core/api/api_client.dart';
import '../models/salon_place.dart';
import '../models/salon_service.dart';
import '../models/service_category.dart';
import '../models/stylist.dart';
import 'salon_catalog.dart';

class CustomerCatalogueApi {
  CustomerCatalogueApi({ApiClient? client}) : _client = client ?? ApiClient();

  final ApiClient _client;

  Future<SalonCatalog> load(String accessToken) async {
    final branchRows = await _client.getJsonList(
      '/api/CustomerCatalogue/branches',
      accessToken: accessToken,
    );
    final salons = <SalonPlace>[];
    final services = <SalonService>[];
    final stylists = <Stylist>[];
    final categories = <ServiceCategory>[];
    final seenStylists = <String>{};
    final seenCategories = <String>{};

    for (final row in branchRows) {
      if (row is! Map<String, dynamic>) continue;
      final branchId = _int(row['branchId']);
      if (branchId <= 0) continue;
      final city = (row['city'] as String?)?.trim();
      salons.add(
        SalonPlace(
          id: '$branchId',
          name: row['branchName'] as String? ?? 'Studio',
          area: city == null || city.isEmpty ? 'Studio' : city,
          highlight: (row['highlight'] as String?)?.trim().isNotEmpty == true
              ? (row['highlight'] as String).trim()
              : (row['addressLine1'] as String? ?? ''),
          rating: -1,
          hasPhoto: row['hasPhoto'] == true,
        ),
      );

      final serviceRows = await _client.getJsonList(
        '/api/CustomerCatalogue/branches/$branchId/services',
        accessToken: accessToken,
      );
      for (final serviceRow in serviceRows) {
        if (serviceRow is! Map<String, dynamic>) continue;
        final serviceId = _int(serviceRow['serviceId']);
        if (serviceId <= 0) continue;
        final categoryName = (serviceRow['categoryName'] as String?)?.trim();
        final categoryId = _slug(categoryName == null || categoryName.isEmpty ? 'service' : categoryName);
        if (seenCategories.add(categoryId)) {
          categories.add(ServiceCategory(id: categoryId, name: categoryName ?? 'Service'));
        }
        final stylistRows = await _client.getJsonList(
          '/api/CustomerCatalogue/branches/$branchId/services/$serviceId/stylists',
          accessToken: accessToken,
        );
        final stylistIds = <String>[];
        for (final stylistRow in stylistRows) {
          if (stylistRow is! Map<String, dynamic>) continue;
          final employeeId = _int(stylistRow['employeeId']);
          if (employeeId <= 0) continue;
          final id = '$employeeId';
          stylistIds.add(id);
          if (!seenStylists.add(id)) continue;
          final name = stylistRow['displayName'] as String? ?? 'Stylist';
          stylists.add(
            Stylist(
              id: id,
              name: name,
              initials: _initials(name),
              specialty: (stylistRow['specialisation'] as String?)?.trim().isNotEmpty == true
                  ? (stylistRow['specialisation'] as String).trim()
                  : 'Stylist',
              categoryId: categoryId,
              salonId: '$branchId',
              rating: -1,
              description: stylistRow['professionalDescription'] as String? ?? '',
              hasPhoto: stylistRow['hasPhoto'] == true,
              qualifications: _qualifications(stylistRow['qualifications']),
            ),
          );
        }
        final price = serviceRow['price'];
        services.add(
          SalonService(
            id: '$serviceId',
            categoryId: categoryId,
            salonId: '$branchId',
            name: serviceRow['serviceName'] as String? ?? 'Service',
            description: serviceRow['description'] as String? ?? '',
            price: price is num ? price.round() : 0,
            durationMinutes: _int(serviceRow['durationMinutes']),
            stylistIds: stylistIds,
            popular: serviceRow['isPopular'] == true,
            hasPhoto: serviceRow['hasPhoto'] == true,
          ),
        );
      }
    }

    return SalonCatalog(
      isLive: true,
      categories: categories,
      salons: salons,
      services: services,
      stylists: stylists,
    );
  }

  Future<List<({DateTime start, bool available})>> availability({
    required String accessToken,
    required int branchId,
    required int serviceId,
    required DateTime date,
    int? employeeId,
  }) async {
    final query = StringBuffer(
      '/api/CustomerCatalogue/availability?branchId=$branchId&serviceId=$serviceId&date=${_date(date)}',
    );
    if (employeeId != null && employeeId > 0) {
      query.write('&employeeId=$employeeId');
    }
    final body = await _client.getJson(query.toString(), accessToken: accessToken);
    final slots = body['slots'];
    if (slots is! List) return const [];
    return [
      for (final slot in slots)
        if (slot is Map<String, dynamic> && DateTime.tryParse('${slot['startTime']}') != null)
          (
            start: DateTime.parse('${slot['startTime']}'),
            available: slot['available'] == true,
          ),
    ];
  }

  static List<StylistQualification> _qualifications(Object? value) {
    if (value is! List) return const [];
    return [
      for (final item in value)
        if (item is Map<String, dynamic>)
          StylistQualification(
            name: item['qualificationName'] as String? ?? '',
            level: item['qualificationLevel'] as String?,
            institution: item['awardingInstitution'] as String?,
            year: item['completionYear'] is num ? (item['completionYear'] as num).toInt() : null,
            isVerified: item['isVerified'] == true,
          ),
    ];
  }

  static int _int(Object? value) {
    if (value is num) return value.toInt();
    return int.tryParse('$value') ?? 0;
  }

  static String _slug(String value) {
    return value.toLowerCase().replaceAll(RegExp(r'[^a-z0-9]+'), '-');
  }

  static String _initials(String name) {
    final parts = name.trim().split(RegExp(r'\s+')).where((part) => part.isNotEmpty).toList();
    if (parts.isEmpty) return 'S';
    if (parts.length == 1) return parts.first.substring(0, 1).toUpperCase();
    return '${parts.first.substring(0, 1)}${parts.last.substring(0, 1)}'.toUpperCase();
  }

  static String _date(DateTime value) {
    final month = value.month.toString().padLeft(2, '0');
    final day = value.day.toString().padLeft(2, '0');
    return '${value.year}-$month-$day';
  }
}
