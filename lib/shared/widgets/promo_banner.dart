import 'package:flutter/material.dart';

import '../../core/theme/app_decorations.dart';
import '../../core/theme/app_dimensions.dart';
import '../../core/theme/app_text_styles.dart';
import '../../features/catalog/models/promotion.dart';
import 'app_primary_button.dart';

class PromoBanner extends StatelessWidget {
  const PromoBanner({
    required this.promotion,
    required this.onPressed,
    super.key,
  });

  final Promotion promotion;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: AppDecorations.brand,
        borderRadius: BorderRadius.circular(AppDimensions.cardRadius + 4),
        boxShadow: AppDecorations.cardShadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            promotion.kicker.toUpperCase(),
            style: AppTextStyles.caption.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.w800,
              letterSpacing: 1,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            promotion.title,
            style: AppTextStyles.display.copyWith(
              color: Colors.white,
              fontSize: 28,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            promotion.subtitle,
            style: AppTextStyles.body.copyWith(color: Colors.white),
          ),
          const SizedBox(height: 18),
          AppPrimaryButton(
            key: const Key('start-booking'),
            label: promotion.ctaLabel,
            inverted: true,
            onPressed: onPressed,
          ),
        ],
      ),
    );
  }
}
