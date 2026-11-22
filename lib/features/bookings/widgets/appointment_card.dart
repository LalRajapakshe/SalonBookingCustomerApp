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
  const AppointmentCard({
    required this.appointment,
    this.onRequestCancellation,
    super.key,
  });

  final Appointment appointment;
  final VoidCallback? onRequestCancellation;

  @override
  Widget build(BuildContext context) {
    final catalog = AppScope.of(context).displayCatalog;
    final service = catalog.serviceById(appointment.serviceId);
    final names = appointment.serviceNames.where((item) => item.trim().isNotEmpty).toList();
    final name = names.isNotEmpty
        ? names.join(', ')
        : appointment.serviceName ?? service?.name ?? 'Salon service';
    final stylist = appointment.scheduledStart != null
        ? (appointment.stylistName ?? 'Stylist assigned')
        : appointment.storedOnServer
            ? 'Stylist not assigned yet'
            : catalog.stylistLabel(appointment.stylistId);
    final when = appointment.scheduledStart ?? appointment.requestedStart ?? appointment.start;
    final whenLabel = appointment.scheduledStart != null
        ? 'Confirmed time'
        : appointment.storedOnServer
            ? 'Requested time'
            : 'Time';

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: AppDecorations.surface(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(
                width: 72,
                height: 72,
                child: service == null
                    ? const DecoratedBox(
                        decoration: BoxDecoration(
                          color: AppColors.primaryLight,
                          borderRadius: BorderRadius.all(Radius.circular(16)),
                        ),
                        child: Icon(Icons.content_cut_rounded, color: AppColors.primary),
                      )
                    : CatalogImage(
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
                            name,
                            style: AppTextStyles.cardTitle,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        const SizedBox(width: 8),
                        StatusPill(status: appointment.status),
                      ],
                    ),
                    if (appointment.branchName != null && appointment.branchName!.isNotEmpty) ...[
                      const SizedBox(height: 6),
                      Text(appointment.branchName!, style: AppTextStyles.body, maxLines: 1),
                    ],
                    const SizedBox(height: 6),
                    Text(stylist, style: AppTextStyles.body, maxLines: 1, overflow: TextOverflow.ellipsis),
                    const SizedBox(height: 4),
                    Text(
                      '$whenLabel · ${DisplayFormat.date(when)} · ${DisplayFormat.timeOf(when)}',
                      style: AppTextStyles.caption.copyWith(color: AppColors.heading),
                    ),
                    if (appointment.sample) ...[
                      const SizedBox(height: 4),
                      Text('Sample data', style: AppTextStyles.caption),
                    ],
                    if (service != null && !appointment.storedOnServer) ...[
                      const SizedBox(height: 8),
                      PriceDurationLabel(
                        price: service.price,
                        durationMinutes: service.durationMinutes,
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
          if (appointment.cancellationRequest == CancellationRequest.requested) ...[
            const SizedBox(height: 10),
            Text(
              'Cancellation request is waiting for the salon.',
              style: AppTextStyles.caption.copyWith(color: AppColors.heading),
            ),
          ],
          if (appointment.cancellationRequest == CancellationRequest.approved) ...[
            const SizedBox(height: 10),
            Text(
              'The salon approved the cancellation.',
              style: AppTextStyles.caption.copyWith(color: AppColors.heading),
            ),
          ],
          if (appointment.cancellationRequest == CancellationRequest.declined) ...[
            const SizedBox(height: 10),
            Text(
              'The salon declined the cancellation request.',
              style: AppTextStyles.caption.copyWith(color: AppColors.heading),
            ),
          ],
          if (appointment.canRequestCancellation && onRequestCancellation != null)
            Align(
              alignment: Alignment.centerLeft,
              child: TextButton(
                key: ValueKey('cancel-${appointment.id}'),
                onPressed: onRequestCancellation,
                child: const Text('Request cancellation'),
              ),
            ),
        ],
      ),
    );
  }
}
