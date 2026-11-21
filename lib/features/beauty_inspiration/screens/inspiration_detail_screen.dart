import 'package:flutter/material.dart';

import '../../../core/navigation/app_routes.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_dimensions.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../shared/widgets/app_primary_button.dart';
import '../../../shared/widgets/app_secondary_button.dart';
import '../../../shared/widgets/empty_state.dart';
import '../data/inspiration_catalog.dart';
import '../state/wishlist_scope.dart';
import '../widgets/inspiration_image.dart';

class InspirationDetailScreen extends StatelessWidget {
  const InspirationDetailScreen({required this.lookId, super.key});

  final String lookId;

  @override
  Widget build(BuildContext context) {
    final look = InspirationCatalog.byId(lookId);
    if (look == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Inspiration')),
        body: const EmptyState(
          icon: Icons.hide_image_outlined,
          title: 'Look unavailable',
          message: 'That reference is not in this preview.',
        ),
      );
    }

    final wishlist = WishlistScope.of(context);
    final saved = wishlist.isSaved(look.id);
    final service = InspirationCatalog.serviceFor(look);

    return Scaffold(
      appBar: AppBar(title: Text(look.title)),
      bottomNavigationBar: SafeArea(
        minimum: const EdgeInsets.fromLTRB(20, 8, 20, 12),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (service == null)
              Text(
                "This look is for inspiration only. There isn't a matching service in the catalogue.",
                style: AppTextStyles.caption,
              )
            else ...[
              Text(
                'Similar catalogue service: ${service.name}',
                style: AppTextStyles.caption.copyWith(color: AppColors.primary),
              ),
              const SizedBox(height: 8),
              AppPrimaryButton(
                key: const Key('inspiration-book-similar'),
                label: 'Book a similar service',
                onPressed: () {
                  Navigator.of(context).pushNamed(
                    AppRoutes.booking,
                    arguments: service.id,
                  );
                },
              ),
            ],
            const SizedBox(height: 8),
            AppSecondaryButton(
              key: const Key('inspiration-detail-favourite'),
              label: saved ? 'Remove from wishlist' : 'Save look',
              onPressed: () => wishlist.toggle(look.id),
            ),
          ],
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(
          AppDimensions.screenPadding,
          8,
          AppDimensions.screenPadding,
          24,
        ),
        children: [
          SizedBox(
            height: 320,
            child: InspirationImage(
              assetPath: look.imageAsset,
              category: look.category,
              borderRadius: BorderRadius.circular(AppDimensions.cardRadius),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Reference image',
            style: AppTextStyles.caption,
          ),
          const SizedBox(height: 14),
          Text(
            look.category.label,
            style: AppTextStyles.caption.copyWith(
              color: AppColors.primary,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 4),
          Text(look.title, style: AppTextStyles.sectionTitle),
          const SizedBox(height: 10),
          Text(look.description, style: AppTextStyles.body),
          const SizedBox(height: 16),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              for (final tag in look.tags)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: AppColors.primaryLight,
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: Text(
                    tag,
                    style: AppTextStyles.caption.copyWith(
                      color: AppColors.primaryDark,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }
}
