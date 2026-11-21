import 'package:flutter/material.dart';

import '../../../core/state/app_scope.dart';
import '../../../core/theme/app_dimensions.dart';
import '../../../core/theme/category_visuals.dart';
import '../../../shared/widgets/category_chip.dart';

class CategoryScroller extends StatelessWidget {
  const CategoryScroller({
    required this.prefix,
    required this.selectedId,
    required this.onSelected,
    this.includeAll = false,
    super.key,
  });

  final String prefix;
  final String? selectedId;
  final ValueChanged<String?> onSelected;
  final bool includeAll;

  @override
  Widget build(BuildContext context) {
    final chips = <Widget>[
      if (includeAll)
        CategoryChip(
          key: ValueKey('$prefix-category-all'),
          label: 'All',
          icon: Icons.grid_view_rounded,
          selected: selectedId == null,
          onTap: () => onSelected(null),
        ),
      for (final category in AppScope.of(context).displayCatalog.categories)
        CategoryChip(
          key: ValueKey('$prefix-category-${category.id}'),
          label: category.name,
          icon: CategoryVisuals.icon(category.id),
          selected: selectedId == category.id,
          onTap: () => onSelected(category.id),
        ),
    ];

    return SizedBox(
      key: Key('$prefix-category-scroller'),
      height: 48,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: chips.length,
        separatorBuilder: (context, index) => const SizedBox(width: AppDimensions.spaceS),
        itemBuilder: (context, index) => chips[index],
      ),
    );
  }
}
