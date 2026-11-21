import 'package:flutter/material.dart';

import '../../features/catalog/data/mock_catalog.dart';

class DisplayFormat {
  DisplayFormat._();

  static const _weekdays = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
  static const _months = [
    'Jan',
    'Feb',
    'Mar',
    'Apr',
    'May',
    'Jun',
    'Jul',
    'Aug',
    'Sep',
    'Oct',
    'Nov',
    'Dec',
  ];

  static String money(num amount) {
    final rounded = amount.round().abs().toString();
    final digits = rounded.split('').reversed.toList();
    final buffer = StringBuffer();
    for (var index = 0; index < digits.length; index++) {
      if (index > 0 && index % 3 == 0) buffer.write(',');
      buffer.write(digits[index]);
    }
    final formatted = buffer.toString().split('').reversed.join();
    final sign = amount < 0 ? '-' : '';
    return '$sign${MockCatalog.currency.symbol} $formatted';
  }

  static String duration(int minutes) {
    final hours = minutes ~/ 60;
    final remainder = minutes % 60;
    if (hours == 0) return '$minutes min';
    if (remainder == 0) return hours == 1 ? '1 hr' : '$hours hr';
    return '$hours hr $remainder min';
  }

  static String weekday(DateTime date) => _weekdays[date.weekday - 1];

  static String monthDay(DateTime date) => '${date.day}';

  static String date(DateTime date) {
    return '${weekday(date)}, ${_months[date.month - 1]} ${date.day}, ${date.year}';
  }

  static String time(TimeOfDay time) {
    final hour = time.hourOfPeriod == 0 ? 12 : time.hourOfPeriod;
    final minute = time.minute.toString().padLeft(2, '0');
    final period = time.period == DayPeriod.am ? 'AM' : 'PM';
    return '$hour:$minute $period';
  }

  static String timeOf(DateTime date) => time(TimeOfDay.fromDateTime(date));

  static String greeting(DateTime now) {
    if (now.hour < 12) return 'Good morning';
    if (now.hour < 17) return 'Good afternoon';
    return 'Good evening';
  }
}
