import 'package:flutter/material.dart';
import 'package:moschee_app/core/l10n/app_localizations.dart';

/// Einheitliche Anzeige für Vorgänge, die man abwarten muss (Speichern,
/// Hochladen, Löschen): Der Inhalt bleibt sichtbar, wird abgedunkelt und
/// gesperrt, darüber eine Karte mit Ladekreis und Text.
class BlockingProgress extends StatelessWidget {
  const BlockingProgress({
    super.key,
    required this.busy,
    required this.child,
    this.message,
  });

  final bool busy;
  final Widget child;

  /// Was gerade passiert; ohne Angabe „Bitte warten …“.
  final String? message;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final t = AppLocalizations.of(context)!;
    return Stack(
      children: [
        child,
        if (busy)
          Positioned.fill(
            child: AbsorbPointer(
              child: ColoredBox(
                color: theme.colorScheme.scrim.withValues(alpha: 0.35),
                child: Center(
                  child: Card(
                    margin: const EdgeInsets.symmetric(horizontal: 32),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 24,
                        vertical: 20,
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const SizedBox.square(
                            dimension: 24,
                            child: CircularProgressIndicator(strokeWidth: 3),
                          ),
                          const SizedBox(width: 16),
                          Flexible(
                            child: Text(
                              message ?? t.common_loading_please_wait,
                              style: theme.textTheme.bodyLarge,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }
}
