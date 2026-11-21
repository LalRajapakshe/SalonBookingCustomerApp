import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_decorations.dart';
import '../../../core/theme/app_dimensions.dart';
import '../../../core/theme/app_text_styles.dart';
import '../data/hair_catalog.dart';
import '../models/hair_style_option.dart';
import 'style_reference_photo.dart';

class ExampleLookCard extends StatelessWidget {
  const ExampleLookCard({super.key});

  @override
  Widget build(BuildContext context) {
    final first = HairCatalog.styles[0];
    final second = HairCatalog.styles[1];
    return Container(
      key: const Key('example-look'),
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: AppDecorations.surface(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: AppColors.primaryLight,
              borderRadius: BorderRadius.circular(AppDimensions.chipRadius),
            ),
            child: Text(
              'Example',
              style: AppTextStyles.caption.copyWith(
                color: AppColors.primaryDark,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Example style photos, not your photo.',
            style: AppTextStyles.caption.copyWith(color: AppColors.body),
          ),
          const SizedBox(height: 12),
          SizedBox(
            height: 168,
            child: Row(
              children: [
                Expanded(child: _ExamplePane(style: first)),
                const SizedBox(width: 10),
                Expanded(child: _ExamplePane(style: second)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ExamplePane extends StatelessWidget {
  const _ExamplePane({required this.style});

  final HairStyleOption style;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Expanded(
          child: ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: StyleReferencePhoto(
              key: Key('example-photo-${style.id}'),
              assetPath: style.assetPath,
              semanticLabel: 'Example of ${style.name}',
            ),
          ),
        ),
        const SizedBox(height: 6),
        Text(
          style.name,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: AppTextStyles.caption,
        ),
      ],
    );
  }
}
