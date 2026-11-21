import 'package:flutter/material.dart';

import '../../core/theme/category_visuals.dart';

class CatalogImage extends StatelessWidget {
  const CatalogImage({
    required this.assetPath,
    required this.fallbackCategoryId,
    this.borderRadius = BorderRadius.zero,
    super.key,
  });

  final String assetPath;
  final String fallbackCategoryId;
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
        errorBuilder: (context, error, stackTrace) {
          return _ImageFallback(categoryId: fallbackCategoryId);
        },
      ),
    );
  }
}

class _ImageFallback extends StatelessWidget {
  const _ImageFallback({required this.categoryId});

  final String categoryId;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: CategoryVisuals.gradient(categoryId),
        ),
      ),
      child: Center(
        child: Icon(
          CategoryVisuals.icon(categoryId),
          color: Colors.white.withValues(alpha: 0.85),
          size: 36,
        ),
      ),
    );
  }
}
