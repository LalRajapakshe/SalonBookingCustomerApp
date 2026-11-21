import 'package:flutter/material.dart';

import '../../../core/format/display_format.dart';
import '../../../core/navigation/app_routes.dart';
import '../../../core/state/app_scope.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_dimensions.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/theme/category_visuals.dart';
import '../../../shared/widgets/app_search_field.dart';
import '../../../shared/widgets/horizontal_card_list.dart';
import '../../../shared/widgets/initials_avatar.dart';
import '../../../shared/widgets/offer_card.dart';
import '../../../shared/widgets/promo_banner.dart';
import '../../../shared/widgets/salon_card.dart';
import '../../../shared/widgets/section_header.dart';
import '../../../shared/widgets/service_card.dart';
import '../../../shared/widgets/stylist_card.dart';
import '../../ai_hair_studio/widgets/hair_studio_entry_card.dart';
import '../../beauty_inspiration/widgets/inspiration_entry_tile.dart';
import '../../smart_booking_calendar/widgets/calendar_entry_tile.dart';
import '../../catalog/data/mock_catalog.dart';
import '../../explore/widgets/salon_sheet.dart';
import '../widgets/category_scroller.dart';

class CustomerHomeScreen extends StatelessWidget {
  const CustomerHomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final app = AppScope.of(context);
    final catalog = app.displayCatalog;
    final profile = MockCatalog.customer;
    final signedInName = app.signedIn?.fullName.trim();
    final firstName = signedInName == null || signedInName.isEmpty
        ? profile.firstName
        : signedInName.split(' ').first;
    final greeting = DisplayFormat.greeting(DateTime.now());

    return SafeArea(
      child: ListView(
        padding: const EdgeInsets.fromLTRB(
          AppDimensions.screenPadding,
          8,
          AppDimensions.screenPadding,
          28,
        ),
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Lumière',
                      style: AppTextStyles.caption.copyWith(
                        color: AppColors.primary,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 0.6,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(greeting, style: AppTextStyles.caption),
                    Text(firstName, style: AppTextStyles.display),
                    if (!catalog.isLive)
                      Text('Sample catalogue', style: AppTextStyles.caption),
                    if (app.catalogLoading)
                      const Padding(
                        padding: EdgeInsets.only(top: 8),
                        child: LinearProgressIndicator(),
                      ),
                    if (app.catalogError != null)
                      Text(app.catalogError!, style: AppTextStyles.caption),
                  ],
                ),
              ),
              InkWell(
                key: const Key('open-profile'),
                customBorder: const CircleBorder(),
                onTap: () => app.setTab(3),
                child: InitialsAvatar(
                  initials: profile.initials,
                  colors: CategoryVisuals.gradient('makeup'),
                  size: 56,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          AppSearchField(
            key: const Key('home-search'),
            hint: 'Search services, salons, or stylists',
            readOnly: true,
            onTap: () => app.openExplore(),
          ),
          const SizedBox(height: 16),
          HairStudioEntryCard(
            onPressed: () {
              Navigator.of(context).pushNamed(AppRoutes.aiHairStudio);
            },
          ),
          const SizedBox(height: 16),
          PromoBanner(
            promotion: MockCatalog.heroPromotion,
            onPressed: () {
              Navigator.of(context).pushNamed(AppRoutes.booking);
            },
          ),
          const SizedBox(height: AppDimensions.sectionGap),
          SectionHeader(
            title: 'Categories',
            actionLabel: 'See all',
            onAction: app.openExplore,
          ),
          const SizedBox(height: 12),
          CategoryScroller(
            prefix: 'home',
            selectedId: null,
            onSelected: (id) => app.openExplore(categoryId: id),
          ),
          const SizedBox(height: AppDimensions.sectionGap),
          SectionHeader(
            title: 'Popular services',
            actionLabel: 'See all',
            onAction: app.openExplore,
          ),
          const SizedBox(height: 12),
          HorizontalCardList(
            height: AppDimensions.serviceStripHeight,
            itemCount: catalog.popularServices.length,
            itemBuilder: (context, index) {
              final service = catalog.popularServices[index];
              return ServiceCard(
                service: service,
                onTap: () {
                  Navigator.of(context).pushNamed(
                    AppRoutes.service,
                    arguments: service.id,
                  );
                },
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
                onTap: () => app.openExplore(categoryId: stylist.categoryId),
              );
            },
          ),
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
          const SectionHeader(title: 'Offers'),
          const SizedBox(height: 12),
          for (final offer in MockCatalog.offers) ...[
            OfferCard(
              promotion: offer,
              onTap: () => app.openExplore(categoryId: offer.categoryId),
            ),
            const SizedBox(height: 12),
          ],
          const Row(
            children: [
              Expanded(child: InspirationEntryTile()),
              SizedBox(width: 12),
              Expanded(child: CalendarEntryTile()),
            ],
          ),
        ],
      ),
    );
  }
}
