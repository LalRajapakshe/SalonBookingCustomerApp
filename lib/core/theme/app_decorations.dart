import 'package:flutter/material.dart';

import 'app_colors.dart';
import 'app_dimensions.dart';

class AppDecorations {
  AppDecorations._();

  static List<BoxShadow> get cardShadow => const [
        BoxShadow(
          color: AppColors.shadow,
          blurRadius: 22,
          offset: Offset(0, 10),
        ),
      ];

  static BoxDecoration surface({
    Color color = AppColors.cardBackground,
    bool selected = false,
    double radius = AppDimensions.cardRadius,
  }) {
    return BoxDecoration(
      color: selected ? AppColors.primaryLight : color,
      borderRadius: BorderRadius.circular(radius),
      border: Border.all(
        color: selected ? AppColors.primary : AppColors.border,
        width: selected ? 2 : 1,
      ),
      boxShadow: selected ? null : cardShadow,
    );
  }

  static const LinearGradient brand = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFFBE185D), Color(0xFF6D28D9)],
  );
}
