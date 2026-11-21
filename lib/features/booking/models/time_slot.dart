import 'package:flutter/material.dart';

class TimeSlot {
  const TimeSlot({
    required this.time,
    required this.available,
  });

  final TimeOfDay time;
  final bool available;
}
