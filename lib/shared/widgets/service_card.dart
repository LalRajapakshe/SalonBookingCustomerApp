import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_dimensions.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/theme/catalog_images.dart';
import '../../core/state/app_scope.dart';
import '../../features/catalog/models/salon_service.dart';
import 'catalog_image.dart';
import 'published_photo.dart';
import 'price_duration_label.dart';

class ServiceCard extends StatelessWidget {
  const ServiceCard({
    required this.service,
    required this.onTap,
    this.width = AppDimensions.serviceCardWidth,
    this.imageHeight = AppDimensions.serviceCardImageHeight,
    super.key,
  });

  final SalonService service;
  final VoidCallback onTap;
  final double? width;
  final double imageHeight;

  @override
  Widget build(BuildContext context) {
    final card = Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppDimensions.cardRadius),
        child: Ink(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(AppDimensions.cardRadius),
            border: Border.all(color: AppColors.border),
            boxShadow: const [
              BoxShadow(
                color: AppColors.shadow,
                blurRadius: 18,
                offset: Offset(0, 8),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(
                height: imageHeight,
                width: double.infinity,
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    PublishedPhoto(
                      enabled: service.hasPhoto,
                      path: '/api/CustomerCatalogue/services/${service.id}/photo',
                      borderRadius: const BorderRadius.vertical(
                        top: Radius.circular(AppDimensions.cardRadius),
                      ),
                      fallback: CatalogImage(
                        assetPath: CatalogImages.forCategory(service.categoryId),
                        fallbackCategoryId: service.categoryId,
                        borderRadius: const BorderRadius.vertical(
                          top: Radius.circular(AppDimensions.cardRadius),
                        ),
                      ),
                    ),
                    Positioned(
                      left: 10,
                      top: 10,
                      child: _Tag(
                        label: AppScope.of(context).displayCatalog.categoryName(service.categoryId),
                      ),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(12, 12, 12, 14),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(
                      height: 44,
                      child: Text(
                        service.name,
                        style: AppTextStyles.cardTitle,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
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
        ),
      ),
    );

    if (width == null) return card;
    return SizedBox(width: width, child: card);
  }
}

class _Tag extends StatelessWidget {
  const _Tag({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.94),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        label,
        style: AppTextStyles.caption.copyWith(
          color: AppColors.heading,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}
