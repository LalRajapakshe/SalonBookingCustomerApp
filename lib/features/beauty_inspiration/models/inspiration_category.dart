/// Categories used only by the inspiration gallery.
enum InspirationCategory {
  haircuts('haircuts', 'Haircuts'),
  hairColour('hair-colour', 'Hair Colour'),
  nails('nails', 'Nails'),
  makeup('makeup', 'Makeup'),
  skincare('skincare', 'Skincare');

  const InspirationCategory(this.id, this.label);

  final String id;
  final String label;

  static InspirationCategory? byId(String id) {
    for (final category in values) {
      if (category.id == id) return category;
    }
    return null;
  }
}
