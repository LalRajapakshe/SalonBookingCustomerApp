import 'package:flutter/material.dart';

import '../models/inspiration_category.dart';

class InspirationVisuals {
  InspirationVisuals._();

  static IconData icon(InspirationCategory category) {
    return switch (category) {
      InspirationCategory.haircuts => Icons.content_cut_rounded,
      InspirationCategory.hairColour => Icons.palette_outlined,
      InspirationCategory.nails => Icons.back_hand_outlined,
      InspirationCategory.makeup => Icons.face_retouching_natural_outlined,
      InspirationCategory.skincare => Icons.spa_outlined,
    };
  }

  static List<Color> gradient(InspirationCategory category) {
    return switch (category) {
      InspirationCategory.haircuts => const [Color(0xFF6D28D9), Color(0xFFBE185D)],
      InspirationCategory.hairColour => const [Color(0xFFB45309), Color(0xFFBE185D)],
      InspirationCategory.nails => const [Color(0xFFFF6F61), Color(0xFFBE185D)],
      InspirationCategory.makeup => const [Color(0xFFBE185D), Color(0xFF4C1D95)],
      InspirationCategory.skincare => const [Color(0xFF0F766E), Color(0xFF7C3AED)],
    };
  }
}
