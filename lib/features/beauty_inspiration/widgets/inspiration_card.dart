import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_decorations.dart';
import '../../../core/theme/app_dimensions.dart';
import '../../../core/theme/app_text_styles.dart';
import '../models/inspiration_look.dart';
import 'inspiration_image.dart';

class InspirationCard extends StatelessWidget {
  const InspirationCard({
    required this.look,
    required this.saved,
    required this.onOpen,
    required this.onToggleSaved,
    this.index = 0,
    super.key,
  });

  final InspirationLook look;
  final bool saved;
  final VoidCallback onOpen;
  final VoidCallback onToggleSaved;
  final int index;

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: 1),
      duration: Duration(milliseconds: 220 + (index % 4) * 40),
      curve: Curves.easeOut,
      builder: (context, value, child) {
        return Opacity(
          opacity: value,
          child: Transform.translate(
            offset: Offset(0, (1 - value) * 12),
            child: child,
          ),
        );
      },
      child: Material(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(AppDimensions.cardRadius),
        child: InkWell(
          key: ValueKey('inspiration-card-${look.id}'),
          onTap: onOpen,
          borderRadius: BorderRadius.circular(AppDimensions.cardRadius),
          child: Ink(
            decoration: AppDecorations.surface(),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Expanded(
                  child: Stack(
                    children: [
                      Positioned.fill(
                        child: InspirationImage(
                          assetPath: look.imageAsset,
                          category: look.category,
                          borderRadius: const BorderRadius.vertical(
                            top: Radius.circular(AppDimensions.cardRadius),
                          ),
                        ),
                      ),
                      Positioned(
                        top: 6,
                        right: 6,
                        child: _FavouriteButton(
                          lookId: look.id,
                          saved: saved,
                          onPressed: onToggleSaved,
                        ),
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(10, 8, 10, 10),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        look.category.label,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: AppTextStyles.caption.copyWith(
                          color: AppColors.primary,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        look.title,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: AppTextStyles.cardTitle.copyWith(fontSize: 15),
                      ),
                    ],
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

class _FavouriteButton extends StatelessWidget {
  const _FavouriteButton({
    required this.lookId,
    required this.saved,
    required this.onPressed,
  });

  final String lookId;
  final bool saved;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white.withValues(alpha: 0.94),
      shape: const CircleBorder(),
      child: IconButton(
        key: ValueKey('inspiration-favourite-$lookId'),
        tooltip: saved ? 'Remove from wishlist' : 'Save look',
        onPressed: onPressed,
        iconSize: 22,
        visualDensity: VisualDensity.compact,
        constraints: const BoxConstraints.tightFor(width: 40, height: 40),
        padding: EdgeInsets.zero,
        icon: AnimatedScale(
          scale: saved ? 1 : 0.92,
          duration: const Duration(milliseconds: 180),
          curve: Curves.easeOut,
          child: AnimatedSwitcher(
            duration: const Duration(milliseconds: 180),
            child: Icon(
              saved ? Icons.favorite_rounded : Icons.favorite_border_rounded,
              key: ValueKey(saved),
              color: AppColors.primary,
            ),
          ),
        ),
      ),
    );
  }
}
