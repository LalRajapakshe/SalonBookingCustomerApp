import 'package:flutter/material.dart';

import '../../core/format/display_format.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../features/booking/data/mock_availability.dart';
import '../../features/booking/models/time_slot.dart';

class TimeSlotSelector extends StatelessWidget {
  const TimeSlotSelector({
    required this.slots,
    required this.selected,
    required this.onSelected,
    super.key,
  });

  final List<TimeSlot> slots;
  final TimeOfDay? selected;
  final ValueChanged<TimeOfDay> onSelected;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 10,
      runSpacing: 10,
      children: [
        for (final slot in slots)
          _TimeChip(
            slot: slot,
            selected: selected == slot.time,
            onSelected: onSelected,
          ),
      ],
    );
  }
}

class _TimeChip extends StatelessWidget {
  const _TimeChip({
    required this.slot,
    required this.selected,
    required this.onSelected,
  });

  final TimeSlot slot;
  final bool selected;
  final ValueChanged<TimeOfDay> onSelected;

  @override
  Widget build(BuildContext context) {
    final enabled = slot.available;
    final background = !enabled
        ? AppColors.scaffoldBackground
        : selected
            ? AppColors.primary
            : Colors.white;
    final foreground = !enabled
        ? AppColors.subtitle
        : selected
            ? Colors.white
            : AppColors.heading;

    return Material(
      key: enabled ? ValueKey(MockAvailability.slotKey(slot.time)) : null,
      color: background,
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        onTap: enabled ? () => onSelected(slot.time) : null,
        borderRadius: BorderRadius.circular(14),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: selected ? AppColors.primary : AppColors.border,
            ),
          ),
          child: Text(
            DisplayFormat.time(slot.time),
            style: AppTextStyles.caption.copyWith(
              color: foreground,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      ),
    );
  }
}
