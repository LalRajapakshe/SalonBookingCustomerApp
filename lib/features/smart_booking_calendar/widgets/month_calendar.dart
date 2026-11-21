import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';

const _months = [
  'January',
  'February',
  'March',
  'April',
  'May',
  'June',
  'July',
  'August',
  'September',
  'October',
  'November',
  'December',
];

const _weekdays = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];

String calendarDayKey(DateTime date) {
  final year = date.year.toString().padLeft(4, '0');
  final month = date.month.toString().padLeft(2, '0');
  final day = date.day.toString().padLeft(2, '0');
  return 'calendar-day-$year-$month-$day';
}

String calendarMonthLabel(DateTime month) {
  return '${_months[month.month - 1]} ${month.year}';
}

class MonthCalendar extends StatelessWidget {
  const MonthCalendar({
    required this.visibleMonth,
    required this.selectedDate,
    required this.today,
    required this.onPrevious,
    required this.onNext,
    required this.onSelect,
    required this.hasSelectableSlots,
    super.key,
  });

  final DateTime visibleMonth;
  final DateTime selectedDate;
  final DateTime today;
  final VoidCallback onPrevious;
  final VoidCallback onNext;
  final ValueChanged<DateTime> onSelect;
  final bool Function(DateTime day) hasSelectableSlots;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          children: [
            IconButton(
              key: const Key('calendar-prev-month'),
              tooltip: 'Previous month',
              onPressed: onPrevious,
              icon: const Icon(Icons.chevron_left_rounded),
            ),
            Expanded(
              child: Text(
                calendarMonthLabel(visibleMonth),
                key: const Key('calendar-month-label'),
                textAlign: TextAlign.center,
                style: AppTextStyles.cardTitle,
              ),
            ),
            IconButton(
              key: const Key('calendar-next-month'),
              tooltip: 'Next month',
              onPressed: onNext,
              icon: const Icon(Icons.chevron_right_rounded),
            ),
          ],
        ),
        const SizedBox(height: 4),
        Row(
          children: [
            for (final label in _weekdays)
              Expanded(
                child: Text(
                  label,
                  textAlign: TextAlign.center,
                  style: AppTextStyles.caption.copyWith(fontWeight: FontWeight.w700),
                ),
              ),
          ],
        ),
        const SizedBox(height: 6),
        AnimatedSwitcher(
          duration: const Duration(milliseconds: 240),
          switchInCurve: Curves.easeOut,
          switchOutCurve: Curves.easeIn,
          child: _DayGrid(
            key: ValueKey('${visibleMonth.year}-${visibleMonth.month}'),
            visibleMonth: visibleMonth,
            selectedDate: selectedDate,
            today: today,
            onSelect: onSelect,
            hasSelectableSlots: hasSelectableSlots,
          ),
        ),
      ],
    );
  }
}

class _DayGrid extends StatelessWidget {
  const _DayGrid({
    required this.visibleMonth,
    required this.selectedDate,
    required this.today,
    required this.onSelect,
    required this.hasSelectableSlots,
    super.key,
  });

  final DateTime visibleMonth;
  final DateTime selectedDate;
  final DateTime today;
  final ValueChanged<DateTime> onSelect;
  final bool Function(DateTime day) hasSelectableSlots;

  @override
  Widget build(BuildContext context) {
    final first = DateTime(visibleMonth.year, visibleMonth.month);
    final leading = first.weekday - 1;
    final days = DateTime(visibleMonth.year, visibleMonth.month + 1, 0).day;

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: 42,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 7,
        mainAxisExtent: 44,
      ),
      itemBuilder: (context, index) {
        final dayNumber = index - leading + 1;
        if (dayNumber < 1 || dayNumber > days) {
          return const SizedBox.shrink();
        }
        final date = DateTime(visibleMonth.year, visibleMonth.month, dayNumber);
        final selected = _sameDay(date, selectedDate);
        final isToday = _sameDay(date, today);
        final past = date.isBefore(today);
        final open = hasSelectableSlots(date);
        final foreground = selected
            ? AppColors.onPrimary
            : past
                ? AppColors.subtitle
                : AppColors.heading;
        return Semantics(
          button: true,
          selected: selected,
          label: calendarDayKey(date),
          child: InkWell(
            key: ValueKey(calendarDayKey(date)),
            onTap: () => onSelect(date),
            customBorder: const CircleBorder(),
            child: Center(
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 180),
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: selected ? AppColors.primary : Colors.transparent,
                  shape: BoxShape.circle,
                  border: isToday && !selected
                      ? Border.all(color: AppColors.primary, width: 1.4)
                      : null,
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      '$dayNumber',
                      style: TextStyle(
                        fontSize: 12,
                        height: 1,
                        color: foreground,
                        fontWeight: selected ? FontWeight.w800 : FontWeight.w600,
                      ),
                    ),
                    AnimatedOpacity(
                      duration: const Duration(milliseconds: 180),
                      opacity: open ? 1 : 0,
                      child: Container(
                        width: 4,
                        height: 4,
                        decoration: BoxDecoration(
                          color: selected ? Colors.white : AppColors.primary,
                          shape: BoxShape.circle,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  bool _sameDay(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }
}
