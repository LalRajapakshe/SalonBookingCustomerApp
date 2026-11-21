import 'package:flutter/material.dart';

import '../../../core/navigation/app_routes.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_decorations.dart';
import '../../../core/theme/app_text_styles.dart';

class CalendarEntryTile extends StatelessWidget {
  const CalendarEntryTile({super.key});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.cardBackground,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        key: const Key('home-open-calendar'),
        onTap: () => Navigator.of(context).pushNamed(AppRoutes.smartCalendar),
        borderRadius: BorderRadius.circular(16),
        child: Ink(
          decoration: AppDecorations.surface(radius: 16),
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 12),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.calendar_month_rounded, color: AppColors.primary),
              const SizedBox(height: 6),
              Text(
                'Calendar',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: AppTextStyles.caption.copyWith(
                  color: AppColors.heading,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
