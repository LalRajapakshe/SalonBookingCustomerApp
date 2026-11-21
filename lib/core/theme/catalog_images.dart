/// Original images bundled with the app for the preview catalog.
///
/// They are not loaded from a network. If an asset is missing, the UI falls
/// back to the category gradient.
class CatalogImages {
  CatalogImages._();

  static const hair = 'assets/images/hair.jpg';
  static const nails = 'assets/images/nails.jpg';
  static const facial = 'assets/images/facial.jpg';
  static const makeup = 'assets/images/makeup.jpg';
  static const spa = 'assets/images/spa.jpg';
  static const studioColombo = 'assets/images/studio_colombo.jpg';
  static const studioKandy = 'assets/images/studio_kandy.jpg';

  static String forCategory(String categoryId) {
    return switch (categoryId) {
      'nails' => nails,
      'facial' => facial,
      'makeup' => makeup,
      'spa' => spa,
      _ => hair,
    };
  }

  static String forSalon(String salonId) {
    return salonId == 'salon-kandy' ? studioKandy : studioColombo;
  }
}
