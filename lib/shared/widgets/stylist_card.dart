import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_dimensions.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/theme/category_visuals.dart';
import '../../features/catalog/models/stylist.dart';
import 'initials_avatar.dart';
import 'published_photo.dart';

class StylistCard extends StatelessWidget {
  const StylistCard({
    required this.stylist,
    this.onTap,
    this.selected = false,
    this.width = AppDimensions.stylistCardWidth,
    super.key,
  });

  final Stylist stylist;
  final VoidCallback? onTap;
  final bool selected;
  final double? width;

  @override
  Widget build(BuildContext context) {
    final card = Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppDimensions.cardRadius),
        child: Ink(
          decoration: BoxDecoration(
            color: selected ? AppColors.primaryLight : Colors.white,
            borderRadius: BorderRadius.circular(AppDimensions.cardRadius),
            border: Border.all(
              color: selected ? AppColors.primary : AppColors.border,
              width: selected ? 2 : 1,
            ),
          ),
          padding: const EdgeInsets.all(14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(
                width: 58,
                height: 58,
                child: PublishedPhoto(
                  enabled: stylist.hasPhoto,
                  path: '/api/CustomerCatalogue/stylists/${stylist.id}/photo',
                  borderRadius: BorderRadius.circular(29),
                  fallback: InitialsAvatar(
                    initials: stylist.initials,
                    colors: CategoryVisuals.gradient(stylist.categoryId),
                    size: 58,
                  ),
                ),
              ),
              const SizedBox(height: 12),
              Text(
                stylist.name,
                style: AppTextStyles.cardTitle.copyWith(fontSize: 15),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 4),
              Text(
                stylist.specialty,
                style: AppTextStyles.caption,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              const Spacer(),
              if (stylist.rating >= 0)
                Row(
                  children: [
                    const Icon(Icons.star_rounded, color: AppColors.warning, size: 18),
                    const SizedBox(width: 2),
                    Text(
                      stylist.rating.toStringAsFixed(1),
                      style: AppTextStyles.caption.copyWith(
                        color: AppColors.heading,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
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
