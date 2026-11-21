import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:salon_customer_app/app.dart';
import 'package:salon_customer_app/core/navigation/app_navigation.dart';
import 'package:salon_customer_app/core/theme/app_theme.dart';
import 'package:salon_customer_app/features/beauty_inspiration/data/inspiration_catalog.dart';
import 'package:salon_customer_app/features/beauty_inspiration/models/inspiration_category.dart';
import 'package:salon_customer_app/features/beauty_inspiration/models/inspiration_look.dart';
import 'package:salon_customer_app/features/beauty_inspiration/screens/inspiration_gallery_screen.dart';
import 'package:salon_customer_app/features/beauty_inspiration/state/wishlist_controller.dart';
import 'package:salon_customer_app/features/beauty_inspiration/state/wishlist_scope.dart';
import 'package:salon_customer_app/features/beauty_inspiration/widgets/inspiration_image.dart';

import 'support/pump_app.dart';

void main() {
  test('service mappings use only existing catalogue ids', () {
    expect(InspirationCatalog.looks.length, inInclusiveRange(18, 24));
    final ids = InspirationCatalog.looks.map((look) => look.id).toSet();
    expect(ids, hasLength(InspirationCatalog.looks.length));
    final images = InspirationCatalog.looks.map((look) => look.imageAsset).toSet();
    expect(images, hasLength(InspirationCatalog.looks.length));

    for (final look in InspirationCatalog.looks) {
      final service = InspirationCatalog.serviceFor(look);
      if (look.suggestedServiceId == null) {
        expect(service, isNull, reason: look.id);
      } else {
        expect(service?.id, look.suggestedServiceId, reason: look.id);
      }
    }

    const unknown = InspirationLook(
      id: 'look-unknown',
      title: 'Unknown mapping',
      category: InspirationCategory.makeup,
      description: 'A reference with a service id that is not in the catalogue.',
      imageAsset: 'assets/images/inspiration/missing.png',
      tags: ['unknown'],
      suggestedServiceId: 'svc-does-not-exist',
    );
    expect(InspirationCatalog.serviceFor(unknown), isNull);
    expect(InspirationCatalog.serviceFor(InspirationCatalog.byId('look-textured-bob')!), isNull);
    expect(
      InspirationCatalog.serviceFor(InspirationCatalog.byId('look-sunlit-balayage')!)?.id,
      'svc-balayage',
    );
  });

  test('search and category filters combine', () {
    final colour = InspirationCatalog.filtered(category: InspirationCategory.hairColour);
    expect(colour.every((look) => look.category == InspirationCategory.hairColour), isTrue);
    expect(colour.any((look) => look.id == 'look-textured-bob'), isFalse);

    final gloss = InspirationCatalog.filtered(
      query: 'chocolate',
      category: InspirationCategory.hairColour,
    );
    expect(gloss.map((look) => look.id), ['look-chocolate-gloss']);

    final none = InspirationCatalog.filtered(
      query: 'chocolate',
      category: InspirationCategory.nails,
    );
    expect(none, isEmpty);

    final bob = InspirationCatalog.filtered(query: 'textured bob');
    expect(bob.map((look) => look.id), ['look-textured-bob']);
  });

  test('wishlist keeps save order and ignores unknown ids', () {
    final wishlist = WishlistController();
    wishlist.toggle('missing-look');
    expect(wishlist.count, 0);

    wishlist.toggle('look-textured-bob');
    wishlist.toggle('look-soft-glam');
    expect(wishlist.savedLooks.map((look) => look.id), [
      'look-textured-bob',
      'look-soft-glam',
    ]);

    wishlist.toggle('look-textured-bob');
    expect(wishlist.isSaved('look-textured-bob'), isFalse);
    expect(wishlist.savedLooks.single.id, 'look-soft-glam');
    wishlist.remove('look-soft-glam');
    expect(wishlist.count, 0);
  });

  testWidgets('gallery renders reference looks and an empty wishlist', (tester) async {
    await pumpGallery(tester);

    expect(find.text('Beauty inspiration'), findsOneWidget);
    expect(find.textContaining('not a photo of you'), findsOneWidget);
    expect(find.text('Soft layered cut'), findsOneWidget);
    expect(find.text('Textured bob'), findsOneWidget);
    expect(find.text('Wishlist (0)'), findsOneWidget);

    await tester.tap(find.byKey(const Key('inspiration-open-wishlist')));
    await tester.pumpAndSettle();
    expect(find.text('No saved looks yet'), findsOneWidget);
    expect(find.text('Discover inspiration'), findsOneWidget);

    await tester.tap(find.text('Discover inspiration'));
    await tester.pumpAndSettle();
    expect(find.text('Beauty inspiration'), findsOneWidget);
    expect(find.text('Soft layered cut'), findsOneWidget);
  });

  testWidgets('category and search filters work together', (tester) async {
    await pumpGallery(tester);

    await tapFilter(tester, 'haircuts');
    expect(find.text('Textured bob'), findsOneWidget);
    expect(find.text('Glossy nude manicure'), findsNothing);

    await tapFilter(tester, 'hair-colour');
    await tester.enterText(find.byKey(const Key('inspiration-search')), 'chocolate');
    await tester.pumpAndSettle();
    expect(find.text('Chocolate gloss'), findsOneWidget);
    expect(find.text('Sunlit balayage'), findsNothing);
    expect(find.text('Textured bob'), findsNothing);

    await tapFilter(tester, 'nails');
    expect(find.text('No looks found'), findsOneWidget);

    await tester.tap(find.byKey(const Key('inspiration-clear-search')));
    await tester.pumpAndSettle();
    expect(find.text('Glossy nude manicure'), findsOneWidget);
    expect(find.text('No looks found'), findsNothing);
    expect(find.text('Chocolate gloss'), findsNothing);
  });

  testWidgets('favourites stay in sync across gallery, detail, and wishlist', (tester) async {
    await pumpGallery(tester);

    expect(heart('look-textured-bob', Icons.favorite_border_rounded), findsOneWidget);
    await tester.tap(find.byKey(const ValueKey('inspiration-favourite-look-textured-bob')));
    await tester.pumpAndSettle();
    expect(heart('look-textured-bob', Icons.favorite_rounded), findsOneWidget);
    expect(find.text('Wishlist (1)'), findsOneWidget);

    await tester.tap(find.text('Textured bob'));
    await tester.pumpAndSettle();
    expect(find.text('Remove from wishlist'), findsOneWidget);
    expect(find.text('bob'), findsOneWidget);
    await tester.tap(find.byKey(const Key('inspiration-detail-favourite')));
    await tester.pumpAndSettle();
    expect(find.text('Save look'), findsOneWidget);

    await tester.pageBack();
    await tester.pumpAndSettle();
    expect(find.text('Wishlist (0)'), findsOneWidget);
    expect(heart('look-textured-bob', Icons.favorite_border_rounded), findsOneWidget);

    await tester.tap(find.byKey(const ValueKey('inspiration-favourite-look-textured-bob')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('inspiration-open-wishlist')));
    await tester.pumpAndSettle();
    expect(find.text('1 saved'), findsOneWidget);
    expect(find.text('Textured bob'), findsOneWidget);

    await tester.tap(find.byKey(const ValueKey('wishlist-open-look-textured-bob')));
    await tester.pumpAndSettle();
    expect(find.text('Textured bob'), findsWidgets);
    await tester.pageBack();
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(const ValueKey('wishlist-remove-look-textured-bob')));
    await tester.pumpAndSettle();
    expect(find.text('No saved looks yet'), findsOneWidget);
    await tester.pageBack();
    await tester.pumpAndSettle();
    expect(find.text('Wishlist (0)'), findsOneWidget);
    expect(heart('look-textured-bob', Icons.favorite_border_rounded), findsOneWidget);
  });

  testWidgets('detail keeps the gallery search and can return', (tester) async {
    await pumpGallery(tester);
    await tapFilter(tester, 'nails');
    await tester.tap(find.text('Glossy nude manicure'));
    await tester.pumpAndSettle();
    expect(find.text('Reference image'), findsOneWidget);
    expect(find.text('Book a similar service'), findsOneWidget);

    await tester.pageBack();
    await tester.pumpAndSettle();
    expect(find.text('Glossy nude manicure'), findsOneWidget);
    expect(find.text('Textured bob'), findsNothing);
    expect(find.text('Beauty inspiration'), findsOneWidget);
  });

  testWidgets('gallery scroll position survives opening a look', (tester) async {
    tester.view.physicalSize = const Size(390, 700);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    await tester.pumpWidget(galleryApp());
    await tester.pumpAndSettle();

    await tester.scrollUntilVisible(
      find.text('Gentle glow prep'),
      300,
      scrollable: verticalScrollable().last,
    );
    await tester.pumpAndSettle();
    expect(find.text('Gentle glow prep').hitTestable(), findsOneWidget);

    await tester.tap(find.text('Gentle glow prep'));
    await tester.pumpAndSettle();
    expect(find.text('Reference image'), findsOneWidget);
    await tester.pageBack();
    await tester.pumpAndSettle();

    expect(find.text('Gentle glow prep').hitTestable(), findsOneWidget);
    expect(find.text('Soft layered cut').hitTestable(), findsNothing);
  });

  testWidgets('a missing reference image shows a fallback', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: SizedBox(
            width: 160,
            height: 200,
            child: InspirationImage(
              assetPath: 'assets/images/inspiration/missing.png',
              category: InspirationCategory.skincare,
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.byKey(const Key('inspiration-image-fallback')), findsOneWidget);
    expect(find.text('Reference'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('booking a similar service opens the existing flow', (tester) async {
    await pumpSalonApp(tester);
    await tester.scrollUntilVisible(
      find.byKey(const Key('home-open-inspiration')),
      400,
      scrollable: verticalScrollable(),
    );
    await tester.tap(find.byKey(const Key('home-open-inspiration')));
    await tester.pumpAndSettle();
    await tester.scrollUntilVisible(
      find.text('Textured bob'),
      250,
      scrollable: verticalScrollable().last,
    );
    await tester.tap(find.text('Textured bob'));
    await tester.pumpAndSettle();
    expect(
      find.textContaining("This look is for inspiration only"),
      findsOneWidget,
    );
    expect(find.byKey(const Key('inspiration-book-similar')), findsNothing);

    await tester.pageBack();
    await tester.pumpAndSettle();
    final sunlit = find.text('Sunlit balayage');
    await tester.scrollUntilVisible(
      sunlit,
      400,
      scrollable: verticalScrollable().last,
    );
    await tester.ensureVisible(sunlit);
    await tester.pumpAndSettle();
    await tester.tap(sunlit);
    await tester.pumpAndSettle();
    expect(find.text('Similar catalogue service: Balayage and Gloss'), findsOneWidget);
    await tester.tap(find.byKey(const Key('inspiration-book-similar')));
    await tester.pumpAndSettle();

    expect(find.text('Choose a stylist'), findsOneWidget);
    expect(find.text('Balayage and Gloss'), findsWidgets);
    expect(find.byKey(const ValueKey('pick-stylist-stylist-amara')), findsOneWidget);

    await tester.pageBack();
    await tester.pumpAndSettle();
    expect(find.text('Choose a service'), findsOneWidget);
    await tester.pageBack();
    await tester.pumpAndSettle();
    expect(find.text('Sunlit balayage'), findsWidgets);
  });

  testWidgets('inspiration and calendar fit a narrow phone', (tester) async {
    tester.view.physicalSize = const Size(320, 700);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(const SalonCustomerApp(requireLogin: false));
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);

    await tester.scrollUntilVisible(
      find.byKey(const Key('home-open-inspiration')),
      400,
      scrollable: verticalScrollable(),
    );
    await tester.tap(find.byKey(const Key('home-open-inspiration')));
    await tester.pumpAndSettle();
    expect(find.text('Beauty inspiration'), findsOneWidget);
    expect(tester.takeException(), isNull);

    await tester.pageBack();
    await tester.pumpAndSettle();
    await tester.scrollUntilVisible(
      find.byKey(const Key('home-open-calendar')),
      400,
      scrollable: verticalScrollable(),
    );
    await tester.tap(find.byKey(const Key('home-open-calendar')));
    await tester.pumpAndSettle();
    expect(find.text('Demo calendar'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}

Finder heart(String id, IconData icon) {
  return find.descendant(
    of: find.byKey(ValueKey('inspiration-favourite-$id')),
    matching: find.byIcon(icon),
  );
}

Widget galleryApp() {
  return WishlistScope(
    controller: WishlistController(),
    child: MaterialApp(
      theme: AppTheme.light,
      home: const InspirationGalleryScreen(),
      onGenerateRoute: AppNavigation.onGenerateRoute,
    ),
  );
}

Future<void> tapFilter(WidgetTester tester, String id) async {
  final key = ValueKey('inspiration-category-$id');
  final scrollable = find.descendant(
    of: find.byKey(const Key('inspiration-filters')),
    matching: find.byType(Scrollable),
  );
  await tester.scrollUntilVisible(find.byKey(key), 140, scrollable: scrollable);
  final target = tester.getRect(find.byKey(key));
  final viewport = tester.getRect(find.byKey(const Key('inspiration-filters')));
  if (target.right > viewport.right - 4) {
    await tester.drag(scrollable, Offset(viewport.right - target.right - 16, 0));
    await tester.pumpAndSettle();
  }
  await tester.tap(find.byKey(key));
  await tester.pumpAndSettle();
}

Future<void> pumpGallery(WidgetTester tester) async {
  tester.view.physicalSize = const Size(390, 900);
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);
  await tester.pumpWidget(galleryApp());
  await tester.pumpAndSettle();
}
