import 'package:flutter/material.dart';

import '../../../core/navigation/app_routes.dart';
import '../../../core/theme/app_dimensions.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../shared/widgets/app_search_field.dart';
import '../../../shared/widgets/empty_state.dart';
import '../data/inspiration_catalog.dart';
import '../models/inspiration_category.dart';
import '../state/wishlist_scope.dart';
import '../widgets/inspiration_card.dart';
import '../widgets/inspiration_filter_bar.dart';

class InspirationGalleryScreen extends StatefulWidget {
  const InspirationGalleryScreen({super.key});

  @override
  State<InspirationGalleryScreen> createState() => _InspirationGalleryScreenState();
}

class _InspirationGalleryScreenState extends State<InspirationGalleryScreen> {
  final _search = TextEditingController();
  final _scroll = ScrollController();
  InspirationCategory? _category;
  String _query = '';

  @override
  void dispose() {
    _search.dispose();
    _scroll.dispose();
    super.dispose();
  }

  void _onSearch(String value) {
    if (value == _query) return;
    setState(() => _query = value);
    _jumpToTop();
  }

  void _clearSearch() {
    _search.clear();
    _onSearch('');
  }

  void _selectCategory(InspirationCategory? category) {
    if (category == _category) return;
    setState(() => _category = category);
    _jumpToTop();
  }

  void _jumpToTop() {
    if (_scroll.hasClients) _scroll.jumpTo(0);
  }

  @override
  Widget build(BuildContext context) {
    final wishlist = WishlistScope.of(context);
    final looks = InspirationCatalog.filtered(query: _query, category: _category);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Beauty inspiration'),
        actions: [
          TextButton.icon(
            key: const Key('inspiration-open-wishlist'),
            onPressed: () {
              Navigator.of(context).pushNamed(AppRoutes.wishlist);
            },
            icon: const Icon(Icons.favorite_rounded, size: 18),
            label: Text('Wishlist (${wishlist.count})'),
          ),
          const SizedBox(width: 4),
        ],
      ),
      body: CustomScrollView(
        key: const PageStorageKey<String>('inspiration-gallery'),
        controller: _scroll,
        slivers: [
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(
                AppDimensions.screenPadding,
                4,
                AppDimensions.screenPadding,
                0,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Find a reference look',
                    style: AppTextStyles.body,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Ideas for hair, colour, nails, makeup, and skin. These images are not a photo of you.',
                    style: AppTextStyles.caption,
                  ),
                  const SizedBox(height: 14),
                  Row(
                    children: [
                      Expanded(
                        child: AppSearchField(
                          key: const Key('inspiration-search'),
                          controller: _search,
                          hint: 'Search looks or tags',
                          onChanged: _onSearch,
                        ),
                      ),
                      IconButton(
                        key: const Key('inspiration-clear-search'),
                        tooltip: 'Clear search',
                        onPressed: _query.isEmpty ? null : _clearSearch,
                        icon: const Icon(Icons.close_rounded),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  InspirationFilterBar(
                    selected: _category,
                    onSelected: _selectCategory,
                  ),
                  const SizedBox(height: 14),
                ],
              ),
            ),
          ),
          if (looks.isEmpty)
            const SliverFillRemaining(
              hasScrollBody: false,
              child: EmptyState(
                icon: Icons.search_off_rounded,
                title: 'No looks found',
                message: 'Try another search or category.',
              ),
            )
          else
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(
                AppDimensions.screenPadding,
                0,
                AppDimensions.screenPadding,
                24,
              ),
              sliver: SliverLayoutBuilder(
                builder: (context, constraints) {
                  final columns = constraints.crossAxisExtent >= 640 ? 3 : 2;
                  return SliverGrid(
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: columns,
                      mainAxisSpacing: 12,
                      crossAxisSpacing: 12,
                      childAspectRatio: 0.72,
                    ),
                    delegate: SliverChildBuilderDelegate(
                      (context, index) {
                        final look = looks[index];
                        return InspirationCard(
                          look: look,
                          index: index,
                          saved: wishlist.isSaved(look.id),
                          onOpen: () {
                            Navigator.of(context).pushNamed(
                              AppRoutes.inspirationDetail,
                              arguments: look.id,
                            );
                          },
                          onToggleSaved: () => wishlist.toggle(look.id),
                        );
                      },
                      childCount: looks.length,
                    ),
                  );
                },
              ),
            ),
        ],
      ),
    );
  }
}
