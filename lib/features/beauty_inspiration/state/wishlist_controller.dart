import 'package:flutter/foundation.dart';

import '../data/inspiration_catalog.dart';
import '../models/inspiration_look.dart';

/// Saved inspiration ids for the current app session.
///
/// Favourites are kept in memory. The project has no local key-value store,
/// and adding one would mean a new dependency.
class WishlistController extends ChangeNotifier {
  final List<String> _ids = [];

  int get count => _ids.length;

  bool isSaved(String id) => _ids.contains(id);

  List<InspirationLook> get savedLooks {
    final saved = <InspirationLook>[];
    for (final id in _ids) {
      final look = InspirationCatalog.byId(id);
      if (look != null) saved.add(look);
    }
    return saved;
  }

  void toggle(String id) {
    if (InspirationCatalog.byId(id) == null) return;
    if (_ids.remove(id)) {
      notifyListeners();
      return;
    }
    _ids.add(id);
    notifyListeners();
  }

  void remove(String id) {
    if (_ids.remove(id)) notifyListeners();
  }
}
