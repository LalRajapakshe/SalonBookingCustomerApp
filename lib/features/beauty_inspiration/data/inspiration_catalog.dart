import '../../catalog/data/mock_catalog.dart';
import '../../catalog/models/salon_service.dart';
import '../models/inspiration_category.dart';
import '../models/inspiration_look.dart';

/// Local reference looks for the inspiration gallery.
///
/// Suggested service ids point only at services that already exist in
/// [MockCatalog]. A missing or unknown id means the look is inspiration only.
class InspirationCatalog {
  InspirationCatalog._();

  static const looks = <InspirationLook>[
    InspirationLook(
      id: 'look-layered-cut',
      title: 'Soft layered cut',
      category: InspirationCategory.haircuts,
      description:
          'A reference for face-framing layers with movement through the ends. The catalogue does not include a cut service for this shape.',
      imageAsset: 'assets/images/inspiration/layered_cut.png',
      tags: ['layers', 'movement', 'shoulder'],
    ),
    InspirationLook(
      id: 'look-textured-bob',
      title: 'Textured bob',
      category: InspirationCategory.haircuts,
      description:
          'A chin-length reference with piece-y texture and a soft edge. It is an idea, not a booked haircut.',
      imageAsset: 'assets/images/inspiration/textured_bob.png',
      tags: ['bob', 'texture', 'short'],
    ),
    InspirationLook(
      id: 'look-curtain-bangs',
      title: 'Curtain bangs',
      category: InspirationCategory.haircuts,
      description:
          'A reference for a centre part and bangs that fall away from the face. No matching cut is in the catalogue.',
      imageAsset: 'assets/images/inspiration/curtain_bangs.png',
      tags: ['bangs', 'fringe', 'face-framing'],
    ),
    InspirationLook(
      id: 'look-pixie-shape',
      title: 'Cropped pixie',
      category: InspirationCategory.haircuts,
      description:
          'A short reference shape with a little height through the crown. This look stays inspiration only.',
      imageAsset: 'assets/images/inspiration/pixie_shape.png',
      tags: ['pixie', 'short', 'crop'],
    ),
    InspirationLook(
      id: 'look-blunt-lob',
      title: 'Blunt lob',
      category: InspirationCategory.haircuts,
      description:
          'A one-length long bob shown as a reference. The catalogue has no matching cut.',
      imageAsset: 'assets/images/inspiration/blunt_lob.png',
      tags: ['lob', 'blunt', 'one-length'],
    ),
    InspirationLook(
      id: 'look-lived-in-shag',
      title: 'Lived-in shag',
      category: InspirationCategory.haircuts,
      description:
          'A reference for choppy layers and a relaxed outline. It is not tied to a catalogue cut.',
      imageAsset: 'assets/images/inspiration/lived_in_shag.png',
      tags: ['shag', 'layers', 'texture'],
    ),
    InspirationLook(
      id: 'look-silk-finish',
      title: 'Sleek silk finish',
      category: InspirationCategory.haircuts,
      description:
          'A smooth, glossy shape. The closest catalogue service is a silk press, which is a styling finish rather than a cut.',
      imageAsset: 'assets/images/inspiration/silk_finish.png',
      tags: ['sleek', 'silk', 'gloss'],
      suggestedServiceId: 'svc-silk-press',
    ),
    InspirationLook(
      id: 'look-blowout-waves',
      title: 'Bouncy blowout waves',
      category: InspirationCategory.haircuts,
      description:
          'A reference for rounded, bouncy waves. A signature blowout is the closest styling service in the catalogue.',
      imageAsset: 'assets/images/inspiration/blowout_waves.png',
      tags: ['blowout', 'waves', 'volume'],
      suggestedServiceId: 'svc-blowout',
    ),
    InspirationLook(
      id: 'look-sunlit-balayage',
      title: 'Sunlit balayage',
      category: InspirationCategory.hairColour,
      description:
          'A reference for soft, sunlit pieces through the mid-lengths. Balayage and gloss is the matching colour service.',
      imageAsset: 'assets/images/inspiration/sunlit_balayage.png',
      tags: ['balayage', 'blonde', 'dimension'],
      suggestedServiceId: 'svc-balayage',
    ),
    InspirationLook(
      id: 'look-chocolate-gloss',
      title: 'Chocolate gloss',
      category: InspirationCategory.hairColour,
      description:
          'A rich brown reference with a reflective finish. The catalogue colour service is balayage and gloss.',
      imageAsset: 'assets/images/inspiration/chocolate_gloss.png',
      tags: ['brown', 'gloss', 'rich'],
      suggestedServiceId: 'svc-balayage',
    ),
    InspirationLook(
      id: 'look-money-pieces',
      title: 'Honey money pieces',
      category: InspirationCategory.hairColour,
      description:
          'A reference for brighter pieces around the face. It maps to the existing balayage and gloss service.',
      imageAsset: 'assets/images/inspiration/money_pieces.png',
      tags: ['money pieces', 'honey', 'face-frame'],
      suggestedServiceId: 'svc-balayage',
    ),
    InspirationLook(
      id: 'look-rose-brown',
      title: 'Soft rose brown',
      category: InspirationCategory.hairColour,
      description:
          'A muted rose-brown colour reference. The similar catalogue service is balayage and gloss.',
      imageAsset: 'assets/images/inspiration/rose_brown.png',
      tags: ['rose', 'brown', 'colour'],
      suggestedServiceId: 'svc-balayage',
    ),
    InspirationLook(
      id: 'look-nude-manicure',
      title: 'Glossy nude manicure',
      category: InspirationCategory.nails,
      description:
          'A clean nude reference with a glossy finish. Gel manicure is the matching catalogue service.',
      imageAsset: 'assets/images/inspiration/nude_manicure.png',
      tags: ['nude', 'manicure', 'gloss'],
      suggestedServiceId: 'svc-gel-manicure',
    ),
    InspirationLook(
      id: 'look-cherry-tips',
      title: 'Cherry red tips',
      category: InspirationCategory.nails,
      description:
          'A reference for a bright red tip. The closest service is a gel manicure.',
      imageAsset: 'assets/images/inspiration/cherry_tips.png',
      tags: ['red', 'tips', 'manicure'],
      suggestedServiceId: 'svc-gel-manicure',
    ),
    InspirationLook(
      id: 'look-pink-nail-art',
      title: 'Soft pink nail art',
      category: InspirationCategory.nails,
      description:
          'A delicate pink art reference. Gel manicure is the similar catalogue service.',
      imageAsset: 'assets/images/inspiration/pink_nail_art.png',
      tags: ['pink', 'nail art', 'detail'],
      suggestedServiceId: 'svc-gel-manicure',
    ),
    InspirationLook(
      id: 'look-soft-gel',
      title: 'Sculpted soft gel',
      category: InspirationCategory.nails,
      description:
          'A longer shaped reference. Soft gel extensions are the matching catalogue service.',
      imageAsset: 'assets/images/inspiration/soft_gel.png',
      tags: ['extensions', 'soft gel', 'shape'],
      suggestedServiceId: 'svc-soft-gel',
    ),
    InspirationLook(
      id: 'look-soft-glam',
      title: 'Soft glam glow',
      category: InspirationCategory.makeup,
      description:
          'A warm, everyday makeup reference. Soft glam is the matching catalogue service.',
      imageAsset: 'assets/images/inspiration/soft_glam.png',
      tags: ['soft glam', 'warm', 'day'],
      suggestedServiceId: 'svc-soft-glam',
    ),
    InspirationLook(
      id: 'look-berry-evening',
      title: 'Evening berry makeup',
      category: InspirationCategory.makeup,
      description:
          'A deeper evening reference. Event makeup is the similar catalogue service.',
      imageAsset: 'assets/images/inspiration/berry_evening.png',
      tags: ['evening', 'berry', 'glam'],
      suggestedServiceId: 'svc-event-makeup',
    ),
    InspirationLook(
      id: 'look-dewy-day',
      title: 'Dewy daytime makeup',
      category: InspirationCategory.makeup,
      description:
          'A light, fresh makeup reference. Soft glam is the closest catalogue service.',
      imageAsset: 'assets/images/inspiration/dewy_day.png',
      tags: ['dewy', 'daytime', 'fresh'],
      suggestedServiceId: 'svc-soft-glam',
    ),
    InspirationLook(
      id: 'look-glass-skin',
      title: 'Morning glass skin',
      category: InspirationCategory.skincare,
      description:
          'A smooth, luminous skin reference. Glow facial is the matching catalogue service.',
      imageAsset: 'assets/images/inspiration/glass_skin.png',
      tags: ['glow', 'glass skin', 'luminous'],
      suggestedServiceId: 'svc-glow-facial',
    ),
    InspirationLook(
      id: 'look-hydration',
      title: 'Calm hydration ritual',
      category: InspirationCategory.skincare,
      description:
          'A calming, hydrated-skin reference. Hydra glow facial is the matching catalogue service.',
      imageAsset: 'assets/images/inspiration/hydration.png',
      tags: ['hydration', 'calm', 'moisture'],
      suggestedServiceId: 'svc-hydra-facial',
    ),
    InspirationLook(
      id: 'look-glow-prep',
      title: 'Gentle glow prep',
      category: InspirationCategory.skincare,
      description:
          'A pre-event skin reference. Glow facial is the similar catalogue service.',
      imageAsset: 'assets/images/inspiration/glow_prep.png',
      tags: ['prep', 'glow', 'gentle'],
      suggestedServiceId: 'svc-glow-facial',
    ),
  ];

  static InspirationLook? byId(String id) {
    for (final look in looks) {
      if (look.id == id) return look;
    }
    return null;
  }

  /// Returns the catalogue service only when the id is real.
  static SalonService? serviceFor(InspirationLook look) {
    final id = look.suggestedServiceId;
    if (id == null || id.isEmpty) return null;
    return MockCatalog.serviceById(id);
  }

  static List<InspirationLook> filtered({
    String query = '',
    InspirationCategory? category,
  }) {
    final needle = query.trim().toLowerCase();
    return looks.where((look) {
      if (category != null && look.category != category) return false;
      if (needle.isEmpty) return true;
      if (look.title.toLowerCase().contains(needle)) return true;
      if (look.description.toLowerCase().contains(needle)) return true;
      if (look.category.label.toLowerCase().contains(needle)) return true;
      return look.tags.any((tag) => tag.toLowerCase().contains(needle));
    }).toList();
  }
}
