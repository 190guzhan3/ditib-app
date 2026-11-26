import 'package:flutter/material.dart';

/// Auswahl in den Einstellungen: links die Bezeichnung, rechts der aktuelle
/// Wert als Dropdown. Aufgebaut wie die Schalter-Zeilen daneben, damit die
/// Einstellungen ruhig und einheitlich wirken.
class SettingsChoiceRow<T> extends StatelessWidget {
  const SettingsChoiceRow({
    super.key,
    required this.label,
    required this.value,
    required this.options,
    required this.onChanged,
  });

  final String label;
  final T value;
  final List<MapEntry<T, String>> options;

  /// `null` deaktiviert die Auswahl (z. B. für Mitglieder ohne Adminrechte).
  final ValueChanged<T>? onChanged;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final enabled = onChanged != null;
    final valueStyle = theme.textTheme.bodyLarge?.copyWith(
      color: enabled ? theme.colorScheme.primary : theme.disabledColor,
      fontWeight: FontWeight.w600,
    );
    final selected = options.any((option) => option.key == value)
        ? value
        : options.first.key;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Expanded(
            child: Text(
              label,
              style: theme.textTheme.bodyLarge?.copyWith(
                color: enabled ? null : theme.disabledColor,
              ),
            ),
          ),
          const SizedBox(width: 12),
          ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 190),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<T>(
                value: selected,
                isDense: true,
                borderRadius: BorderRadius.circular(12),
                dropdownColor: theme.colorScheme.surface,
                alignment: AlignmentDirectional.centerEnd,
                iconEnabledColor: theme.colorScheme.primary,
                selectedItemBuilder: (context) => [
                  for (final option in options)
                    Align(
                      alignment: AlignmentDirectional.centerEnd,
                      child: Text(
                        option.value,
                        overflow: TextOverflow.ellipsis,
                        style: valueStyle,
                      ),
                    ),
                ],
                items: [
                  for (final option in options)
                    DropdownMenuItem<T>(
                      value: option.key,
                      child: Text(option.value),
                    ),
                ],
                onChanged: enabled
                    ? (value) {
                        if (value != null) onChanged!(value);
                      }
                    : null,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
