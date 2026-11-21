import 'package:flutter/material.dart';

import '../models/time_slot.dart';

/// Sample opening hours for the booking preview.
///
/// Slots are generated locally. They are not a live stylist calendar.
class MockAvailability {
  MockAvailability._();

  static const openingHour = 9;
  static const closingHour = 18;

  static List<DateTime> upcomingDates({int count = 14, DateTime? from}) {
    final now = from ?? DateTime.now();
    final start = DateTime(now.year, now.month, now.day);
    return List<DateTime>.generate(
      count,
      (index) => start.add(Duration(days: index)),
    );
  }

  static List<TimeSlot> slotsFor({
    required DateTime date,
    required String stylistId,
    DateTime? now,
  }) {
    final clock = now ?? DateTime.now();
    final day = DateTime(date.year, date.month, date.day);
    final slots = <TimeSlot>[];

    for (var hour = openingHour; hour < closingHour; hour++) {
      for (final minute in const [0, 30]) {
        final time = TimeOfDay(hour: hour, minute: minute);
        final moment = DateTime(day.year, day.month, day.day, hour, minute);
        final inPast = !moment.isAfter(clock);
        final held = _sampleHold(day, hour, minute, stylistId);
        slots.add(TimeSlot(time: time, available: !inPast && !held));
      }
    }

    if (slots.every((slot) => !slot.available)) {
      return _withFallbackOpens(slots, clock, day);
    }
    return slots;
  }

  static bool _sampleHold(DateTime day, int hour, int minute, String stylistId) {
    final seed = day.day + hour * 3 + minute + stylistId.hashCode;
    return seed.abs() % 5 == 0;
  }

  static List<TimeSlot> _withFallbackOpens(
    List<TimeSlot> slots,
    DateTime clock,
    DateTime day,
  ) {
    const fallback = [
      TimeOfDay(hour: 10, minute: 0),
      TimeOfDay(hour: 11, minute: 30),
      TimeOfDay(hour: 14, minute: 0),
      TimeOfDay(hour: 16, minute: 0),
    ];
    return slots.map((slot) {
      final moment = DateTime(
        day.year,
        day.month,
        day.day,
        slot.time.hour,
        slot.time.minute,
      );
      final keepOpen = fallback.contains(slot.time) && moment.isAfter(clock);
      if (!keepOpen) return slot;
      return TimeSlot(time: slot.time, available: true);
    }).toList();
  }

  static bool isSameDay(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }

  static String slotKey(TimeOfDay time) => 'pick-time-${time.hour}-${time.minute}';
}
