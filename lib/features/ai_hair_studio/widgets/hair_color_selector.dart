import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../data/hair_catalog.dart';
import '../models/hair_style_option.dart';

class HairColorSelector extends StatelessWidget {
  const HairColorSelector({
    required this.selectedId,
    required this.onSelected,
    super.key,
  });

  final String? selectedId;
  final ValueChanged<HairColorOption?> onSelected;

  @override
  Widget build(BuildContext context) {
    final options = <_ColorChoice>[
      const _ColorChoice.keep(),
      for (final color in HairCatalog.colors) _ColorChoice.color(color),
    ];
    return SizedBox(
      height: 112,
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: [
            for (var index = 0; index < options.length; index++) ...[
              _ColorChip(
                choice: options[index],
                selected: options[index].id == selectedId,
                onTap: () => onSelected(options[index].color),
              ),
              if (index != options.length - 1) const SizedBox(width: 8),
            ],
          ],
        ),
      ),
    );
  }
}

class _ColorChoice {
  const _ColorChoice.keep()
      : id = 'keep',
        label = 'Keep my colour',
        color = null,
        swatch = 0xFFFFFFFF;

  _ColorChoice.color(HairColorOption option)
      : id = option.id,
        label = option.name,
        color = option,
        swatch = option.swatch;

  final String id;
  final String label;
  final HairColorOption? color;
  final int swatch;
}

class _ColorChip extends StatelessWidget {
  const _ColorChip({
    required this.choice,
    required this.selected,
    required this.onTap,
  });

  final _ColorChoice choice;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final swatch = Color(choice.swatch);
    final bright = swatch.computeLuminance() > 0.55;
    final checkColor = choice.color == null
        ? AppColors.primary
        : bright
            ? AppColors.heading
            : Colors.white;
    return Semantics(
      button: true,
      selected: selected,
      label: choice.label,
      child: InkWell(
        key: Key('hair-color-${choice.id}'),
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: SizedBox(
          width: 76,
          child: Column(
            children: [
              Container(
                width: 52,
                height: 52,
                decoration: BoxDecoration(
                  color: swatch,
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: selected ? AppColors.primary : AppColors.border,
                    width: selected ? 3 : 1,
                  ),
                ),
                child: choice.color == null
                    ? Icon(
                        selected ? Icons.check_rounded : Icons.water_drop_outlined,
                        key: selected ? const Key('hair-color-check-keep') : null,
                        color: AppColors.primary,
                      )
                    : selected
                        ? Icon(
                            Icons.check_rounded,
                            key: Key('hair-color-check-${choice.id}'),
                            color: checkColor,
                          )
                        : null,
              ),
              const SizedBox(height: 6),
              Text(
                choice.label,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.center,
                style: AppTextStyles.caption.copyWith(
                  fontWeight: selected ? FontWeight.w800 : FontWeight.w500,
                  color: selected ? AppColors.primaryDark : AppColors.subtitle,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
