import 'package:flutter/material.dart';

import '../../core/theme/app_text_styles.dart';

class InitialsAvatar extends StatelessWidget {
  const InitialsAvatar({
    required this.initials,
    required this.colors,
    this.size = 48,
    super.key,
  });

  final String initials;
  final List<Color> colors;
  final double size;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: colors,
        ),
      ),
      child: Text(
        initials,
        style: AppTextStyles.cardTitle.copyWith(
          color: Colors.white,
          fontSize: size * 0.34,
        ),
      ),
    );
  }
}
