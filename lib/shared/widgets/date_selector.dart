import 'package:flutter/material.dart';

import '../../core/format/display_format.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../features/booking/data/mock_availability.dart';

class DateSelector extends StatelessWidget {
  const DateSelector({
    required this.dates,
    required this.selected,
    required this.onSelected,
    super.key,
  });

  final List<DateTime> dates;
  final DateTime? selected;
  final ValueChanged<DateTime> onSelected;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 92,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: dates.length,
        separatorBuilder: (context, index) => const SizedBox(width: 10),
        itemBuilder: (context, index) {
          final date = dates[index];
          final isSelected = selected != null && MockAvailability.isSameDay(selected!, date);
          final foreground = isSelected ? Colors.white : AppColors.heading;
          return Material(
            key: ValueKey('pick-date-$index'),
            color: isSelected ? AppColors.primary : Colors.white,
            borderRadius: BorderRadius.circular(18),
            child: InkWell(
              onTap: () => onSelected(date),
              borderRadius: BorderRadius.circular(18),
              child: Container(
                width: 72,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(
                    color: isSelected ? AppColors.primary : AppColors.border,
                  ),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      DisplayFormat.weekday(date),
                      style: AppTextStyles.caption.copyWith(color: foreground),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      DisplayFormat.monthDay(date),
                      style: AppTextStyles.cardTitle.copyWith(color: foreground),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
