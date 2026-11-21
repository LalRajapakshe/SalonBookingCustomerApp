import 'package:flutter/material.dart';

import '../../../core/navigation/app_routes.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_decorations.dart';
import '../../../core/theme/app_dimensions.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../shared/widgets/empty_state.dart';
import '../state/wishlist_scope.dart';
import '../widgets/inspiration_image.dart';

class WishlistScreen extends StatelessWidget {
  const WishlistScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final wishlist = WishlistScope.of(context);
    final looks = wishlist.savedLooks;

    return Scaffold(
      appBar: AppBar(title: const Text('Wishlist')),
      body: looks.isEmpty
          ? EmptyState(
              icon: Icons.favorite_border_rounded,
              title: 'No saved looks yet',
              message: 'Save a reference look and it will appear here.',
              actionLabel: 'Discover inspiration',
              onAction: () {
                if (Navigator.of(context).canPop()) {
                  Navigator.of(context).pop();
                  return;
                }
                Navigator.of(context).pushReplacementNamed(AppRoutes.inspiration);
              },
            )
          : ListView(
              padding: const EdgeInsets.fromLTRB(
                AppDimensions.screenPadding,
                8,
                AppDimensions.screenPadding,
                24,
              ),
              children: [
                Text(
                  '${looks.length} saved',
                  key: const Key('wishlist-count'),
                  style: AppTextStyles.body,
                ),
                const SizedBox(height: 12),
                for (final look in looks) ...[
                  Material(
                    color: AppColors.cardBackground,
                    borderRadius: BorderRadius.circular(AppDimensions.cardRadius),
                    child: InkWell(
                      key: ValueKey('wishlist-open-${look.id}'),
                      onTap: () {
                        Navigator.of(context).pushNamed(
                          AppRoutes.inspirationDetail,
                          arguments: look.id,
                        );
                      },
                      borderRadius: BorderRadius.circular(AppDimensions.cardRadius),
                      child: Ink(
                        decoration: AppDecorations.surface(),
                        padding: const EdgeInsets.all(10),
                        child: Row(
                          children: [
                            SizedBox(
                              width: 72,
                              height: 88,
                              child: InspirationImage(
                                assetPath: look.imageAsset,
                                category: look.category,
                                borderRadius: BorderRadius.circular(14),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    look.category.label,
                                    style: AppTextStyles.caption.copyWith(
                                      color: AppColors.primary,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    look.title,
                                    style: AppTextStyles.cardTitle,
                                  ),
                                ],
                              ),
                            ),
                            IconButton(
                              key: ValueKey('wishlist-remove-${look.id}'),
                              tooltip: 'Remove from wishlist',
                              onPressed: () => wishlist.remove(look.id),
                              icon: const Icon(
                                Icons.favorite_rounded,
                                color: AppColors.primary,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                ],
              ],
            ),
    );
  }
}
