import 'package:flutter/material.dart';

import '../../../core/format/display_format.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_decorations.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/theme/catalog_images.dart';
import '../../../shared/widgets/catalog_image.dart';
import '../../../shared/widgets/price_duration_label.dart';
import '../../../shared/widgets/status_pill.dart';
import '../../../core/state/app_scope.dart';
import '../../booking/models/appointment.dart';

class AppointmentCard extends StatelessWidget {
  const AppointmentCard({required this.appointment, super.key});

  final Appointment appointment;

  @override
  Widget build(BuildContext context) {
    final catalog = AppScope.of(context).displayCatalog;
    final service = catalog.serviceById(appointment.serviceId);
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: AppDecorations.surface(),
      child: service == null
          ? const Text('This service is not in the preview.')
          : Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(
                  width: 72,
                  height: 72,
                  child: CatalogImage(
                    assetPath: CatalogImages.forCategory(service.categoryId),
                    fallbackCategoryId: service.categoryId,
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: Text(
                              service.name,
                              style: AppTextStyles.cardTitle,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          const SizedBox(width: 8),
                          StatusPill(status: appointment.status),
                        ],
                      ),
                      const SizedBox(height: 6),
                      Text(
                        catalog.stylistLabel(appointment.stylistId),
                        style: AppTextStyles.body,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${DisplayFormat.date(appointment.start)} · ${DisplayFormat.timeOf(appointment.start)}',
                        style: AppTextStyles.caption.copyWith(color: AppColors.heading),
                      ),
                      const SizedBox(height: 8),
                      PriceDurationLabel(
                        price: service.price,
                        durationMinutes: service.durationMinutes,
                      ),
                    ],
                  ),
                ),
              ],
            ),
    );
  }
}
