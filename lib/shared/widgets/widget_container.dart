import 'package:flutter/material.dart';

class WidgetContainer extends StatelessWidget {
  final Widget child;

  /// Innenabstand; Einstellungszeilen bringen eigenen Abstand mit.
  final EdgeInsetsGeometry padding;

  const WidgetContainer({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(20),
  });

  /// Für Karten aus Einstellungszeilen ([SettingsGroup]).
  static const settingsPadding = EdgeInsets.symmetric(
    horizontal: 18,
    vertical: 4,
  );

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    // Material statt Container-Dekoration, damit ListTiles und InkWells im
    // Inneren ihre Tipp-Effekte auf der Kartenfläche zeigen können.
    return SizedBox(
      width: double.infinity,
      child: Material(
        color: theme.colorScheme.surface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: BorderSide(color: theme.dividerColor.withValues(alpha: 0.1)),
        ),
        clipBehavior: Clip.antiAlias,
        child: Padding(padding: padding, child: child),
      ),
    );
  }
}

/// Einheitlicher Kopf für Widgets und Karten: Titel, optionaler Untertitel
/// und gleicher Abstand zum Inhalt.
class WidgetHeader extends StatelessWidget {
  const WidgetHeader(this.title, {super.key, this.subtitle, this.trailing});

  final String title;
  final String? subtitle;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: theme.textTheme.titleMedium),
                if (subtitle != null) ...[
                  const SizedBox(height: 2),
                  Text(
                    subtitle!,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.disabledColor,
                    ),
                  ),
                ],
              ],
            ),
          ),
          if (trailing != null) ...[const SizedBox(width: 8), trailing!],
        ],
      ),
    );
  }
}
