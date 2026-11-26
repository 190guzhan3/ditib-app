import 'package:flutter/material.dart';

/// Einheitlicher Rahmen für Bottom-Sheets: Griff, Titel, optionaler
/// Erklärtext und Inhalt mit den Abständen der übrigen App.
Future<T?> showAppBottomSheet<T>(
  BuildContext context, {
  required String title,
  String? subtitle,
  required WidgetBuilder builder,
}) {
  return showModalBottomSheet<T>(
    context: context,
    isScrollControlled: true,
    showDragHandle: true,
    builder: (sheetContext) {
      final theme = Theme.of(sheetContext);
      return SafeArea(
        child: ConstrainedBox(
          constraints: BoxConstraints(
            maxHeight: MediaQuery.sizeOf(sheetContext).height * 0.85,
          ),
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(20, 4, 20, 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(title, style: theme.textTheme.titleLarge),
                if (subtitle != null) ...[
                  const SizedBox(height: 8),
                  Text(
                    subtitle,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.textTheme.bodyMedium?.color?.withValues(
                        alpha: 0.72,
                      ),
                      height: 1.35,
                    ),
                  ),
                ],
                const SizedBox(height: 20),
                builder(sheetContext),
              ],
            ),
          ),
        ),
      );
    },
  );
}

/// QR-Code auf weißem Grund, damit er auch im dunklen Design lesbar bleibt.
class AppQrFrame extends StatelessWidget {
  const AppQrFrame({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
        ),
        child: child,
      ),
    );
  }
}
