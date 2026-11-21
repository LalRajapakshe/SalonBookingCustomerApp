import 'package:flutter/widgets.dart';

import 'wishlist_controller.dart';

class WishlistScope extends InheritedNotifier<WishlistController> {
  const WishlistScope({
    required WishlistController controller,
    required super.child,
    super.key,
  }) : super(notifier: controller);

  static WishlistController of(BuildContext context) {
    final scope = context.dependOnInheritedWidgetOfExactType<WishlistScope>();
    assert(scope != null, 'WishlistScope is missing above this widget');
    return scope!.notifier!;
  }

  static WishlistController read(BuildContext context) {
    final scope = context.getInheritedWidgetOfExactType<WishlistScope>();
    assert(scope != null, 'WishlistScope is missing above this widget');
    return scope!.notifier!;
  }
}
