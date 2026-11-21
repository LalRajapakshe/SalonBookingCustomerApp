import 'package:flutter/material.dart';

import '../../../core/navigation/app_routes.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_decorations.dart';
import '../../../core/theme/app_text_styles.dart';

class InspirationEntryTile extends StatelessWidget {
  const InspirationEntryTile({super.key});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.cardBackground,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        key: const Key('home-open-inspiration'),
        onTap: () => Navigator.of(context).pushNamed(AppRoutes.inspiration),
        borderRadius: BorderRadius.circular(16),
        child: Ink(
          decoration: AppDecorations.surface(radius: 16),
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 12),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.photo_library_outlined, color: AppColors.primary),
              const SizedBox(height: 6),
              Text(
                'Inspiration',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: AppTextStyles.caption.copyWith(
                  color: AppColors.heading,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
