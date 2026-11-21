import 'package:flutter/widgets.dart';

import 'hair_studio_bindings.dart';

class HairStudioScope extends InheritedWidget {
  const HairStudioScope({
    required this.bindings,
    required super.child,
    super.key,
  });

  final HairStudioBindings bindings;

  static HairStudioBindings of(BuildContext context) {
    final scope = context.dependOnInheritedWidgetOfExactType<HairStudioScope>();
    assert(scope != null, 'HairStudioScope is missing above this widget');
    return scope!.bindings;
  }

  @override
  bool updateShouldNotify(HairStudioScope oldWidget) {
    return bindings != oldWidget.bindings;
  }
}
