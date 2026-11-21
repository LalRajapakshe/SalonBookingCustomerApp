import 'package:flutter/widgets.dart';

import 'calendar_controller.dart';

class CalendarScope extends InheritedNotifier<CalendarController> {
  const CalendarScope({
    required CalendarController controller,
    required super.child,
    super.key,
  }) : super(notifier: controller);

  static CalendarController of(BuildContext context) {
    final scope = context.dependOnInheritedWidgetOfExactType<CalendarScope>();
    assert(scope != null, 'CalendarScope is missing above this widget');
    return scope!.notifier!;
  }

  static CalendarController read(BuildContext context) {
    final scope = context.getInheritedWidgetOfExactType<CalendarScope>();
    assert(scope != null, 'CalendarScope is missing above this widget');
    return scope!.notifier!;
  }
}
