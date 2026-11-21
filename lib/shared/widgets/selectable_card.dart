import 'package:flutter/material.dart';

import '../../core/theme/app_decorations.dart';

class SelectableCard extends StatelessWidget {
  const SelectableCard({
    required this.child,
    required this.onTap,
    this.selected = false,
    this.padding = const EdgeInsets.all(16),
    super.key,
  });

  final Widget child;
  final VoidCallback onTap;
  final bool selected;
  final EdgeInsets padding;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Ink(
          decoration: AppDecorations.surface(selected: selected),
          child: Padding(padding: padding, child: child),
        ),
      ),
    );
  }
}
