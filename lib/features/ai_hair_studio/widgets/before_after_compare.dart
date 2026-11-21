import 'dart:typed_data';

import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';

class StudioMemoryImage extends StatelessWidget {
  const StudioMemoryImage({
    required this.bytes,
    required this.semanticLabel,
    super.key,
  });

  final Uint8List bytes;
  final String semanticLabel;

  @override
  Widget build(BuildContext context) {
    return Image.memory(
      bytes,
      fit: BoxFit.cover,
      gaplessPlayback: true,
      semanticLabel: semanticLabel,
      errorBuilder: (context, error, stackTrace) {
        return const ColoredBox(
          color: AppColors.primaryLight,
          child: Center(
            child: Padding(
              padding: EdgeInsets.all(12),
              child: Text(
                'This image could not be displayed.',
                textAlign: TextAlign.center,
                style: AppTextStyles.caption,
              ),
            ),
          ),
        );
      },
    );
  }
}

class BeforeAfterCompare extends StatefulWidget {
  const BeforeAfterCompare({
    required this.before,
    required this.after,
    super.key,
  });

  final Uint8List before;
  final Uint8List after;

  @override
  State<BeforeAfterCompare> createState() => _BeforeAfterCompareState();
}

class _BeforeAfterCompareState extends State<BeforeAfterCompare> {
  double _beforeWidth = 0.5;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        AspectRatio(
          aspectRatio: 3 / 4,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(20),
            child: LayoutBuilder(
              builder: (context, constraints) {
                final clipWidth = constraints.maxWidth * _beforeWidth;
                return Stack(
                  fit: StackFit.expand,
                  children: [
                    StudioMemoryImage(
                      key: const Key('generated-look'),
                      bytes: widget.after,
                      semanticLabel: 'Generated look',
                    ),
                    ClipRect(
                      clipper: _LeftClipper(clipWidth),
                      child: StudioMemoryImage(
                        key: const Key('original-look'),
                        bytes: widget.before,
                        semanticLabel: 'Your photo',
                      ),
                    ),
                    Positioned(
                      left: (clipWidth - 8).clamp(0, constraints.maxWidth - 16),
                      top: 0,
                      bottom: 0,
                      child: const SizedBox(
                        width: 16,
                        child: Center(
                          child: SizedBox(
                            width: 3,
                            child: ColoredBox(color: Colors.white),
                          ),
                        ),
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
        ),
        Slider(
          key: const Key('before-after-slider'),
          value: _beforeWidth,
          onChanged: (value) => setState(() => _beforeWidth = value),
        ),
        const Row(
          children: [
            Expanded(
              child: Text('Your photo', style: AppTextStyles.caption),
            ),
            Text(
              'Generated look',
              textAlign: TextAlign.right,
              style: AppTextStyles.caption,
            ),
          ],
        ),
      ],
    );
  }
}

class _LeftClipper extends CustomClipper<Rect> {
  const _LeftClipper(this.width);

  final double width;

  @override
  Rect getClip(Size size) {
    return Rect.fromLTWH(0, 0, width.clamp(0, size.width), size.height);
  }

  @override
  bool shouldReclip(_LeftClipper oldClipper) => oldClipper.width != width;
}
