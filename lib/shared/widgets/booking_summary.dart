import 'package:flutter/material.dart';

import '../../core/format/display_format.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_decorations.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/state/app_scope.dart';
import '../../features/catalog/data/salon_catalog.dart';
import '../../features/catalog/models/salon_service.dart';

class BookingSummary extends StatelessWidget {
  const BookingSummary({
    required this.service,
    required this.stylistId,
    required this.start,
    super.key,
  });

  final SalonService service;
  final String stylistId;
  final DateTime start;

  @override
  Widget build(BuildContext context) {
    final catalog = AppScope.maybeOf(context)?.displayCatalog ?? SalonCatalog.preview;
    final salon = catalog.salonById(service.salonId);
    final rows = <(String, String)>[
      ('Service', service.name),
      ('Category', catalog.categoryName(service.categoryId)),
      ('Stylist', catalog.stylistLabel(stylistId)),
      if (salon != null) ('Salon', salon.name),
      ('Date', DisplayFormat.date(start)),
      ('Time', DisplayFormat.timeOf(start)),
      ('Duration', DisplayFormat.duration(service.durationMinutes)),
      ('Price', DisplayFormat.money(service.price)),
    ];

    return Container(
      key: const Key('booking-summary'),
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: AppDecorations.surface(),
      child: Column(
        children: [
          for (var index = 0; index < rows.length; index++) ...[
            if (index > 0) const Divider(height: 20, color: AppColors.border),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(
                  width: 88,
                  child: Text(rows[index].$1, style: AppTextStyles.caption),
                ),
                Expanded(
                  child: Text(
                    rows[index].$2,
                    style: AppTextStyles.cardTitle.copyWith(fontSize: 15),
                    textAlign: TextAlign.right,
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}
