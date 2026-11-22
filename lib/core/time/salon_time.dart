/// Asia/Colombo is UTC+5:30 all year. Booking dates use these clock numbers
/// and are not shifted into the phone's timezone.
class SalonTime {
  SalonTime._();

  static const offset = Duration(hours: 5, minutes: 30);

  static DateTime now([DateTime? utc]) {
    final base = (utc ?? DateTime.now()).toUtc();
    final shifted = base.add(offset);
    return DateTime(
      shifted.year,
      shifted.month,
      shifted.day,
      shifted.hour,
      shifted.minute,
      shifted.second,
    );
  }

  static DateTime today([DateTime? utc]) {
    final current = now(utc);
    return DateTime(current.year, current.month, current.day);
  }

  static bool isPastSlot(DateTime date, int hour, int minute, [DateTime? utc]) {
    final current = now(utc);
    final day = DateTime(date.year, date.month, date.day);
    final salonDay = DateTime(current.year, current.month, current.day);
    if (day != salonDay) return false;
    final slot = DateTime(day.year, day.month, day.day, hour, minute);
    return !slot.isAfter(current);
  }
}
