import 'package:flutter/material.dart';

import '../../../core/state/app_scope.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/theme/catalog_images.dart';
import '../../../shared/widgets/app_primary_button.dart';
import '../../../shared/widgets/catalog_image.dart';
import '../../catalog/models/salon_place.dart';

void showSalonSheet(BuildContext context, SalonPlace salon) {
  showModalBottomSheet<void>(
    context: context,
    showDragHandle: true,
    backgroundColor: Colors.white,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
    ),
    builder: (sheetContext) {
      return Padding(
        padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(18),
              child: SizedBox(
                height: 150,
                width: double.infinity,
                child: CatalogImage(
                  assetPath: CatalogImages.forSalon(salon.id),
                  fallbackCategoryId: 'spa',
                ),
              ),
            ),
            const SizedBox(height: 14),
            Text(salon.name, style: AppTextStyles.sectionTitle),
            const SizedBox(height: 6),
            Text(salon.area, style: AppTextStyles.body),
            const SizedBox(height: 8),
            Text(salon.highlight, style: AppTextStyles.body),
            const SizedBox(height: 8),
            Row(
              children: [
                const Icon(Icons.star_rounded, color: AppColors.warning, size: 20),
                const SizedBox(width: 4),
                Text(
                  salon.rating.toStringAsFixed(1),
                  style: AppTextStyles.cardTitle,
                ),
              ],
            ),
            const SizedBox(height: 18),
            AppPrimaryButton(
              label: 'Browse services',
              onPressed: () {
                Navigator.of(sheetContext).pop();
                AppScope.read(context).openExplore();
              },
            ),
          ],
        ),
      );
    },
  );
}
