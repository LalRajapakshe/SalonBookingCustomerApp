import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_decorations.dart';
import '../../../core/theme/app_dimensions.dart';
import '../../../core/theme/app_text_styles.dart';

class HairStudioEntryCard extends StatelessWidget {
  const HairStudioEntryCard({required this.onPressed, super.key});

  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.cardBackground,
      elevation: 0,
      borderRadius: BorderRadius.circular(AppDimensions.cardRadius),
      child: InkWell(
        key: const Key('home-ai-hair-studio'),
        onTap: onPressed,
        borderRadius: BorderRadius.circular(AppDimensions.cardRadius),
        child: Ink(
          decoration: AppDecorations.surface(),
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  gradient: AppDecorations.brand,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: const Icon(
                  Icons.face_retouching_natural_rounded,
                  color: Colors.white,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'AI HAIR STUDIO',
                      style: AppTextStyles.caption.copyWith(
                        color: AppColors.primary,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 0.6,
                      ),
                    ),
                    const SizedBox(height: 2),
                    const Text(
                      'Try a hairstyle on your photo',
                      style: AppTextStyles.cardTitle,
                    ),
                    const SizedBox(height: 2),
                    const Text(
                      'Preview a look before you book.',
                      style: AppTextStyles.caption,
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              const Icon(Icons.arrow_forward_rounded, color: AppColors.primary),
            ],
          ),
        ),
      ),
    );
  }
}
