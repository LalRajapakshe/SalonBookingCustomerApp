import 'package:flutter/material.dart';

import '../../../core/navigation/app_routes.dart';
import '../../../core/state/app_scope.dart';
import '../../../core/theme/app_dimensions.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../shared/widgets/app_search_field.dart';
import '../../../shared/widgets/empty_state.dart';
import '../../../shared/widgets/horizontal_card_list.dart';
import '../../../shared/widgets/salon_card.dart';
import '../../../shared/widgets/section_header.dart';
import '../../../shared/widgets/service_card.dart';
import '../../../shared/widgets/stylist_card.dart';
import '../../home/widgets/category_scroller.dart';
import '../widgets/salon_sheet.dart';

class ExploreScreen extends StatefulWidget {
  const ExploreScreen({super.key});

  @override
  State<ExploreScreen> createState() => _ExploreScreenState();
}

class _ExploreScreenState extends State<ExploreScreen> {
  final _search = TextEditingController();
  AppScope? _scope;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final scope = context.dependOnInheritedWidgetOfExactType<AppScope>();
    if (!identical(_scope, scope)) {
      _scope?.notifier?.removeListener(_syncQuery);
      _scope = scope;
      scope?.notifier?.addListener(_syncQuery);
    }
    _syncQuery();
  }

  void _syncQuery() {
    final query = _scope?.notifier?.exploreQuery ?? '';
    if (_search.text == query) return;
    _search.value = TextEditingValue(
      text: query,
      selection: TextSelection.collapsed(offset: query.length),
    );
  }

  @override
  void dispose() {
    _scope?.notifier?.removeListener(_syncQuery);
    _search.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final app = AppScope.of(context);
    final catalog = app.displayCatalog;
    final results = catalog.search(
      query: app.exploreQuery,
      categoryId: app.categoryId,
    );
    final showFeatured = app.exploreQuery.trim().isEmpty && app.categoryId == null;

    return SafeArea(
      child: ListView(
        keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
        padding: const EdgeInsets.fromLTRB(
          AppDimensions.screenPadding,
          8,
          AppDimensions.screenPadding,
          28,
        ),
        children: [
          Text('Discover', style: AppTextStyles.display),
          const SizedBox(height: 6),
          Text(
            catalog.isLive ? 'Services, studios, and stylists' : 'Sample catalogue',
            style: AppTextStyles.body,
          ),
          if (app.catalogError != null)
            Text(app.catalogError!, style: AppTextStyles.caption),
          const SizedBox(height: 16),
          AppSearchField(
            key: const Key('explore-search'),
            hint: 'Search services by name',
            controller: _search,
            onChanged: app.setExploreQuery,
          ),
          const SizedBox(height: 16),
          CategoryScroller(
            prefix: 'explore',
            includeAll: true,
            selectedId: app.categoryId,
            onSelected: app.setCategory,
          ),
          if (showFeatured) ...[
            const SizedBox(height: AppDimensions.sectionGap),
            const SectionHeader(title: 'Studios'),
            const SizedBox(height: 12),
            HorizontalCardList(
              height: AppDimensions.salonCardHeight,
              itemCount: catalog.salons.length,
              itemBuilder: (context, index) {
                final salon = catalog.salons[index];
                return SalonCard(
                  salon: salon,
                  onTap: () => showSalonSheet(context, salon),
                );
              },
            ),
            const SizedBox(height: AppDimensions.sectionGap),
            const SectionHeader(title: 'Stylists'),
            const SizedBox(height: 12),
            HorizontalCardList(
              height: 214,
              itemCount: catalog.stylists.length,
              itemBuilder: (context, index) {
                final stylist = catalog.stylists[index];
                return StylistCard(
                  stylist: stylist,
                  onTap: () => app.setCategory(stylist.categoryId),
                );
              },
            ),
          ],
          const SizedBox(height: AppDimensions.sectionGap),
          SectionHeader(
            title: results.isEmpty
                ? 'Services'
                : results.length == 1
                    ? '1 service'
                    : '${results.length} services',
          ),
          const SizedBox(height: 12),
          if (results.isEmpty)
            EmptyState(
              icon: Icons.search_off_rounded,
              title: 'No matches',
              message: 'Try another name or category.',
              actionLabel: 'Clear filters',
              onAction: app.clearDiscoveryFilters,
            )
          else
            for (final service in results) ...[
              ServiceCard(
                key: ValueKey('explore-service-${service.id}'),
                service: service,
                width: null,
                imageHeight: 168,
                onTap: () {
                  Navigator.of(context).pushNamed(
                    AppRoutes.service,
                    arguments: service.id,
                  );
                },
              ),
              const SizedBox(height: 12),
            ],
        ],
      ),
    );
  }
}
