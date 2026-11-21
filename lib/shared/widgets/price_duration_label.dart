import 'package:flutter/material.dart';

import '../../core/format/display_format.dart';
import '../../core/theme/app_text_styles.dart';

class PriceDurationLabel extends StatelessWidget {
  const PriceDurationLabel({
    required this.price,
    required this.durationMinutes,
    super.key,
  });

  final int price;
  final int durationMinutes;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Flexible(
          child: Text(
            DisplayFormat.money(price),
            style: AppTextStyles.price,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
        const SizedBox(width: 8),
        Text(
          DisplayFormat.duration(durationMinutes),
          style: AppTextStyles.caption,
          maxLines: 1,
        ),
      ],
    );
  }
}
