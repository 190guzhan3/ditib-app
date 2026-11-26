import 'package:flutter/material.dart';
import 'package:moschee_app/core/theme/app_design.dart';

class SectionTitle extends StatelessWidget {
  final String title;
  final EdgeInsetsGeometry padding;

  const SectionTitle(
    this.title, {
    super.key,
    this.padding = const EdgeInsets.only(left: 4, bottom: 8, top: 12),
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: padding,
      child: Text(
        title.toUpperCase(),
        style: AppTypography.bodySmall.copyWith(
          fontWeight: FontWeight.bold,
          color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.8),
          letterSpacing: 1.1,
        ),
      ),
    );
  }
}
