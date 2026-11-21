import 'package:flutter/material.dart';

import '../models/demo_slot.dart';

/// Sample openings for the calendar preview.
///
/// These times are generated on the device. They are not live salon
/// availability and they do not reserve a stylist.
class DemoAvailability {
  DemoAvailability._();

  static const notice =
      'Demo times only. These openings are sample data, not live salon availability.';

  static bool hasTemplate(DateTime date) => _template(date).isNotEmpty;

  static List<DemoSlot> slotsFor({
    required DateTime date,
    required DateTime now,
    Set<String> bookedSlotIds = const {},
  }) {
    final day = DateTime(date.year, date.month, date.day);
    final slots = <DemoSlot>[];
    for (final time in _template(day)) {
      final start = DateTime(day.year, day.month, day.day, time.hour, time.minute);
      if (!start.isAfter(now)) continue;
      final id = DemoSlot.idFor(start);
      if (bookedSlotIds.contains(id)) continue;
      slots.add(DemoSlot(id: id, start: start));
    }
    return slots;
  }

  static List<TimeOfDay> _template(DateTime date) {
    return switch (date.weekday) {
      DateTime.sunday => const [],
      DateTime.saturday => const [
          TimeOfDay(hour: 11, minute: 0),
          TimeOfDay(hour: 15, minute: 0),
        ],
      DateTime.wednesday => const [
          TimeOfDay(hour: 10, minute: 0),
          TimeOfDay(hour: 11, minute: 30),
        ],
      _ => const [
          TimeOfDay(hour: 10, minute: 0),
          TimeOfDay(hour: 11, minute: 30),
          TimeOfDay(hour: 14, minute: 0),
          TimeOfDay(hour: 16, minute: 30),
        ],
    };
  }
}
