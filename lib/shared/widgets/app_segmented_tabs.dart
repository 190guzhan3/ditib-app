import 'package:flutter/material.dart';
import 'package:moschee_app/core/theme/app_design.dart';

/// Compact segmented navigation for choices that stay within the same screen.
class AppSegmentedTabs extends StatelessWidget {
  final List<String> labels;
  final int selectedIndex;
  final ValueChanged<int> onSelected;
  final EdgeInsetsGeometry margin;

  const AppSegmentedTabs({
    super.key,
    required this.labels,
    required this.selectedIndex,
    required this.onSelected,
    this.margin = EdgeInsets.zero,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final selectedLabelColor = theme.brightness == Brightness.dark
        ? Colors.white
        : Colors.black;
    return Container(
      margin: margin,
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: theme.dividerColor.withValues(alpha: 0.1)),
      ),
      child: Row(
        children: List.generate(labels.length, (index) {
          final isSelected = selectedIndex == index;
          return Expanded(
            child: Semantics(
              button: true,
              selected: isSelected,
              child: InkWell(
                borderRadius: BorderRadius.circular(10),
                onTap: () => onSelected(index),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 180),
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? theme.colorScheme.primary.withValues(alpha: 0.16)
                        : Colors.transparent,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    labels[index],
                    textAlign: TextAlign.center,
                    style: AppTypography.body.copyWith(
                      fontWeight: FontWeight.w700,
                      color: isSelected
                          ? selectedLabelColor
                          : theme.colorScheme.onSurface.withValues(alpha: 0.7),
                    ),
                  ),
                ),
              ),
            ),
          );
        }),
      ),
    );
  }
}
