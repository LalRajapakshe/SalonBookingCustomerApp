import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';

/// Example hairstyle photograph. A missing asset shows a labeled placeholder
/// and is never treated as a generated result.
class StyleReferencePhoto extends StatelessWidget {
  const StyleReferencePhoto({
    required this.assetPath,
    this.semanticLabel = 'Example hairstyle photo',
    super.key,
  });

  final String assetPath;
  final String semanticLabel;

  @override
  Widget build(BuildContext context) {
    return Image.asset(
      assetPath,
      fit: BoxFit.cover,
      semanticLabel: semanticLabel,
      errorBuilder: (context, error, stackTrace) {
        return const StyleReferencePlaceholder();
      },
    );
  }
}

class StyleReferencePlaceholder extends StatelessWidget {
  const StyleReferencePlaceholder({super.key});

  @override
  Widget build(BuildContext context) {
    return const ColoredBox(
      color: AppColors.primaryLight,
      child: Center(
        child: Padding(
          padding: EdgeInsets.all(8),
          child: Text(
            'Example photo unavailable',
            key: Key('example-photo-placeholder'),
            textAlign: TextAlign.center,
            style: AppTextStyles.caption,
          ),
        ),
      ),
    );
  }
}
