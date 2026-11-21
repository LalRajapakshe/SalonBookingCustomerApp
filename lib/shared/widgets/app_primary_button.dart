import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_dimensions.dart';
import '../../core/theme/app_text_styles.dart';

class AppPrimaryButton extends StatelessWidget {
  const AppPrimaryButton({
    required this.label,
    required this.onPressed,
    this.inverted = false,
    super.key,
  });

  final String label;
  final VoidCallback? onPressed;
  final bool inverted;

  @override
  Widget build(BuildContext context) {
    final enabled = onPressed != null;
    final background = !enabled
        ? AppColors.border
        : inverted
            ? Colors.white
            : AppColors.primary;
    final foreground = !enabled
        ? AppColors.subtitle
        : inverted
            ? AppColors.primary
            : AppColors.onPrimary;

    return SizedBox(
      width: double.infinity,
      height: AppDimensions.buttonHeight,
      child: Material(
        color: background,
        borderRadius: BorderRadius.circular(AppDimensions.buttonRadius),
        child: InkWell(
          onTap: onPressed,
          borderRadius: BorderRadius.circular(AppDimensions.buttonRadius),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Center(
              child: FittedBox(
                fit: BoxFit.scaleDown,
                child: Text(
                  label,
                  maxLines: 1,
                  style: AppTextStyles.button.copyWith(color: foreground),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
