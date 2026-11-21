import 'package:flutter/material.dart';

import '../../../core/theme/app_text_styles.dart';
import '../models/inspiration_category.dart';
import 'inspiration_visuals.dart';

class InspirationImage extends StatelessWidget {
  const InspirationImage({
    required this.assetPath,
    required this.category,
    this.borderRadius = BorderRadius.zero,
    super.key,
  });

  final String assetPath;
  final InspirationCategory category;
  final BorderRadius borderRadius;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: borderRadius,
      child: Image.asset(
        assetPath,
        fit: BoxFit.cover,
        width: double.infinity,
        height: double.infinity,
        gaplessPlayback: true,
        errorBuilder: (context, error, stackTrace) {
          return InspirationImageFallback(category: category);
        },
      ),
    );
  }
}

class InspirationImageFallback extends StatelessWidget {
  const InspirationImageFallback({required this.category, super.key});

  final InspirationCategory category;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      key: const Key('inspiration-image-fallback'),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: InspirationVisuals.gradient(category),
        ),
      ),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              InspirationVisuals.icon(category),
              color: Colors.white,
              size: 36,
            ),
            const SizedBox(height: 8),
            Text(
              'Reference',
              style: AppTextStyles.caption.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
