import 'package:flutter/material.dart';
import 'package:moschee_app/core/theme/theme.dart';
import 'package:moschee_app/shared/fuzzy.dart';

/// Textfeld mit Vorschlägen aus vorhandenen Werten. Treffer am Wortanfang
/// zuerst; die Liste ist nach Häufigkeit vorsortiert.
class SuggestField extends StatefulWidget {
  const SuggestField({
    super.key,
    required this.controller,
    required this.label,
    required this.options,
    this.onSelected,
    this.icon,
    this.keyboardType,
  });

  final TextEditingController controller;
  final String label;

  /// Wird bei jeder Eingabe neu abgefragt (kann vom Kontext abhängen).
  final List<String> Function() options;
  final ValueChanged<String>? onSelected;
  final IconData? icon;
  final TextInputType? keyboardType;

  @override
  State<SuggestField> createState() => _SuggestFieldState();
}

class _SuggestFieldState extends State<SuggestField> {
  final _focus = FocusNode();

  @override
  void dispose() {
    _focus.dispose();
    super.dispose();
  }

  Iterable<String> _build(TextEditingValue value) {
    final q = searchKey(value.text);
    final all = widget.options();
    if (q.isEmpty) return all.take(8);
    final starts = <String>[];
    final contains = <String>[];
    for (final o in all) {
      final k = searchKey(o);
      if (k == q) continue;
      if (k.startsWith(q)) {
        starts.add(o);
      } else if (k.contains(q)) {
        contains.add(o);
      }
    }
    return [...starts, ...contains].take(8);
  }

  @override
  Widget build(BuildContext context) {
    return RawAutocomplete<String>(
      textEditingController: widget.controller,
      focusNode: _focus,
      optionsBuilder: _build,
      onSelected: widget.onSelected,
      fieldViewBuilder: (context, controller, focus, onSubmit) => TextField(
        controller: controller,
        focusNode: focus,
        keyboardType: widget.keyboardType,
        textCapitalization: TextCapitalization.words,
        decoration: AppFormStyles.decoration(
          context,
          labelText: widget.label,
          prefixIcon: widget.icon == null ? null : Icon(widget.icon, size: 20),
        ),
      ),
      optionsViewBuilder: (context, onSelect, options) => Align(
        alignment: Alignment.topLeft,
        child: Material(
          elevation: 6,
          borderRadius: BorderRadius.circular(12),
          color: Theme.of(context).popupMenuTheme.color,
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxHeight: 240, maxWidth: 360),
            child: ListView(
              padding: const EdgeInsets.symmetric(vertical: 6),
              shrinkWrap: true,
              children: [
                for (final o in options)
                  ListTile(
                    dense: true,
                    title: Text(o),
                    onTap: () => onSelect(o),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
