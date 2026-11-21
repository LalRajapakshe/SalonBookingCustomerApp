/// One sample opening in the local calendar preview.
class DemoSlot {
  const DemoSlot({
    required this.id,
    required this.start,
  });

  final String id;
  final DateTime start;

  static String idFor(DateTime start) {
    final year = start.year.toString().padLeft(4, '0');
    final month = start.month.toString().padLeft(2, '0');
    final day = start.day.toString().padLeft(2, '0');
    final hour = start.hour.toString().padLeft(2, '0');
    final minute = start.minute.toString().padLeft(2, '0');
    return '$year$month$day-$hour$minute';
  }
}
