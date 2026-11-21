import 'package:flutter/material.dart';

import '../../../core/navigation/app_routes.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_dimensions.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/theme/catalog_images.dart';
import '../../../shared/widgets/catalog_image.dart';
import '../../../shared/widgets/app_primary_button.dart';
import '../../../shared/widgets/empty_state.dart';
import '../../../shared/widgets/horizontal_card_list.dart';
import '../../../shared/widgets/price_duration_label.dart';
import '../../../shared/widgets/section_header.dart';
import '../../../shared/widgets/stylist_card.dart';
import '../../../core/state/app_scope.dart';

class ServiceDetailScreen extends StatelessWidget {
  const ServiceDetailScreen({required this.serviceId, super.key});

  final String serviceId;

  @override
  Widget build(BuildContext context) {
    final catalog = AppScope.of(context).displayCatalog;
    final service = catalog.serviceById(serviceId);
    if (service == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Service')),
        body: EmptyState(
          icon: Icons.error_outline_rounded,
          title: 'Service unavailable',
          message: catalog.isLive
              ? 'That service is not available.'
              : 'That service is not in this sample catalogue.',
        ),
      );
    }

    final salon = catalog.salonById(service.salonId);
    final stylists = catalog.stylistsForService(service);

    return Scaffold(
      appBar: AppBar(title: Text(service.name)),
      bottomNavigationBar: SafeArea(
        minimum: const EdgeInsets.fromLTRB(20, 8, 20, 12),
        child: AppPrimaryButton(
          key: const Key('book-appointment'),
          label: 'Book appointment',
          onPressed: () {
            Navigator.of(context).pushNamed(
              AppRoutes.booking,
              arguments: service.id,
            );
          },
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(
          AppDimensions.screenPadding,
          0,
          AppDimensions.screenPadding,
          24,
        ),
        children: [
          SizedBox(
            height: 220,
            child: Stack(
              fit: StackFit.expand,
              children: [
                CatalogImage(
                  assetPath: CatalogImages.forCategory(service.categoryId),
                  fallbackCategoryId: service.categoryId,
                  borderRadius: BorderRadius.circular(AppDimensions.cardRadius),
                ),
                Positioned(
                  left: 14,
                  bottom: 14,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.94),
                      borderRadius: BorderRadius.circular(999),
                    ),
                    child: Text(
                      catalog.categoryName(service.categoryId),
                      style: AppTextStyles.caption.copyWith(
                        color: AppColors.heading,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 18),
          Text(service.name, style: AppTextStyles.sectionTitle),
          const SizedBox(height: 8),
          Text(service.description, style: AppTextStyles.body),
          const SizedBox(height: 14),
          PriceDurationLabel(
            price: service.price,
            durationMinutes: service.durationMinutes,
          ),
          if (salon != null) ...[
            const SizedBox(height: 14),
            Text(salon.name, style: AppTextStyles.cardTitle.copyWith(fontSize: 15)),
            const SizedBox(height: 2),
            Text(salon.area, style: AppTextStyles.caption),
          ],
          const SizedBox(height: 28),
          const SectionHeader(title: 'Stylists'),
          const SizedBox(height: 8),
          Text(
            'Choose one of these stylists, or any available stylist, when you book.',
            style: AppTextStyles.caption,
          ),
          const SizedBox(height: 12),
          if (stylists.isEmpty)
            const EmptyState(
              icon: Icons.person_off_outlined,
              title: 'Stylists coming soon',
              message: 'You can still book any available stylist.',
            )
          else
            HorizontalCardList(
              height: 214,
              itemCount: stylists.length,
              itemBuilder: (context, index) {
                return StylistCard(stylist: stylists[index]);
              },
            ),
        ],
      ),
    );
  }
}
