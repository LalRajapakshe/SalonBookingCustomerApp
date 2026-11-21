import 'inspiration_category.dart';

/// A local reference look. It is not a photo of the current customer.
class InspirationLook {
  const InspirationLook({
    required this.id,
    required this.title,
    required this.category,
    required this.description,
    required this.imageAsset,
    required this.tags,
    this.suggestedServiceId,
  });

  final String id;
  final String title;
  final InspirationCategory category;
  final String description;
  final String imageAsset;
  final List<String> tags;

  /// An existing catalogue service id when this look resembles that service.
  ///
  /// Unknown ids are ignored by [InspirationLook] consumers.
  final String? suggestedServiceId;
}
