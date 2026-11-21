import 'package:flutter/material.dart';

class CategoryVisuals {
  CategoryVisuals._();

  static IconData icon(String categoryId) {
    return switch (categoryId) {
      'hair' => Icons.content_cut_rounded,
      'nails' => Icons.back_hand_rounded,
      'facial' => Icons.spa_rounded,
      'makeup' => Icons.face_retouching_natural_rounded,
      'spa' => Icons.self_improvement_rounded,
      _ => Icons.auto_awesome_rounded,
    };
  }

  static List<Color> gradient(String categoryId) {
    return switch (categoryId) {
      'hair' => const [Color(0xFF6D28D9), Color(0xFFBE185D)],
      'nails' => const [Color(0xFFFF6F61), Color(0xFFBE185D)],
      'facial' => const [Color(0xFFFF8FAB), Color(0xFF7C3AED)],
      'makeup' => const [Color(0xFFBE185D), Color(0xFF4C1D95)],
      'spa' => const [Color(0xFF8B5CF6), Color(0xFFDB2777)],
      _ => const [Color(0xFFBE185D), Color(0xFF6D28D9)],
    };
  }
}
