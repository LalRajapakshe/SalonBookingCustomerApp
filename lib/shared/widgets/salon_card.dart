import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_dimensions.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/theme/catalog_images.dart';
import '../../features/catalog/models/salon_place.dart';
import 'catalog_image.dart';
import 'published_photo.dart';

class SalonCard extends StatelessWidget {
  const SalonCard({
    required this.salon,
    required this.onTap,
    super.key,
  });

  final SalonPlace salon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: AppDimensions.salonCardWidth,
      height: AppDimensions.salonCardHeight,
      child: Material(
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
                  height: AppDimensions.salonCardImageHeight,
                  width: double.infinity,
                  child: PublishedPhoto(
                    enabled: salon.hasPhoto,
                    path: '/api/CustomerCatalogue/branches/${salon.id}/photo',
                    borderRadius: const BorderRadius.vertical(
                      top: Radius.circular(AppDimensions.cardRadius),
                    ),
                    fallback: CatalogImage(
                      assetPath: CatalogImages.forSalon(salon.id),
                      fallbackCategoryId: 'spa',
                      borderRadius: const BorderRadius.vertical(
                        top: Radius.circular(AppDimensions.cardRadius),
                      ),
                    ),
                  ),
                ),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(14, 10, 14, 12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          salon.name,
                          style: AppTextStyles.cardTitle,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 2),
                        Text(
                          salon.area,
                          style: AppTextStyles.caption,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const Spacer(),
                        if (salon.rating >= 0)
                          Row(
                            children: [
                              const Icon(
                                Icons.star_rounded,
                                color: AppColors.warning,
                                size: 18,
                              ),
                              const SizedBox(width: 2),
                              Text(
                                salon.rating.toStringAsFixed(1),
                                style: AppTextStyles.caption.copyWith(
                                  color: AppColors.heading,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                            ],
                          ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
