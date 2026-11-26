import 'package:flutter/material.dart';
import 'package:moschee_app/core/l10n/app_localizations.dart';
import 'package:moschee_app/core/theme/theme.dart';

class ConfirmDialog extends StatelessWidget {
  final String title;
  final String content;
  final String? confirmLabel;
  final Color? confirmColor;
  final bool isIrreversible;

  const ConfirmDialog({
    super.key,
    required this.title,
    required this.content,
    this.confirmLabel,
    this.confirmColor,
    this.isIrreversible = true,
  });

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context)!;

    return AlertDialog(
      title: Text(title),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(content),
          if (isIrreversible) ...[
            const SizedBox(height: 16),
            Text(
              t.common_irreversible,
              style: const TextStyle(
                color: AppColors.error,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(false),
          child: Text(t.common_cancel),
        ),
        // Wie überall: Abbrechen als Text, die Aktion als Button; Löschen
        // in der Fehlerfarbe.
        ElevatedButton(
          style: confirmColor == null
              ? AppButtonStyles.destructive(context)
              : ElevatedButton.styleFrom(backgroundColor: confirmColor),
          onPressed: () => Navigator.of(context).pop(true),
          child: Text(confirmLabel ?? t.common_delete),
        ),
      ],
    );
  }
}
