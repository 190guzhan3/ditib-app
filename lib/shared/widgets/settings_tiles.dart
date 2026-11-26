import 'package:flutter/material.dart';

/// Schriften der Einstellungen, abgeleitet aus dem Theme. Jede Zeile nutzt
/// genau diese drei Stile, damit nichts unterschiedlich groß wirkt.
class SettingsTextStyles {
  const SettingsTextStyles._();

  static TextStyle? title(BuildContext context, {bool enabled = true}) {
    final theme = Theme.of(context);
    return theme.textTheme.bodyLarge?.copyWith(
      color: enabled ? theme.colorScheme.onSurface : theme.disabledColor,
    );
  }

  static TextStyle? subtitle(BuildContext context) {
    final theme = Theme.of(context);
    return theme.textTheme.bodySmall?.copyWith(height: 1.3);
  }

  static TextStyle? value(BuildContext context, {bool enabled = true}) {
    final theme = Theme.of(context);
    return theme.textTheme.bodyMedium?.copyWith(
      fontWeight: FontWeight.w600,
      color: enabled ? theme.colorScheme.primary : theme.disabledColor,
    );
  }
}

/// Gemeinsames Aussehen aller Dropdowns: gleicher Pfeil, gleiche Rundung
/// und ein Menü, das sich auch im Darkmode vom Hintergrund abhebt.
class AppDropdownStyle {
  const AppDropdownStyle._();

  /// Im Darkmode etwas heller als die Karten, sonst verschwindet der
  /// Menürand (der Schatten ist auf dunklem Grund kaum zu sehen).
  static Color menuColor(BuildContext context) {
    final theme = Theme.of(context);
    final surface = theme.colorScheme.surface;
    return theme.brightness == Brightness.dark
        ? Color.lerp(surface, Colors.white, 0.09)!
        : surface;
  }

  static const radius = BorderRadius.all(Radius.circular(12));

  static Widget arrow(BuildContext context, {bool enabled = true}) {
    final theme = Theme.of(context);
    return Icon(
      Icons.unfold_more_rounded,
      size: 18,
      color: enabled ? theme.colorScheme.primary : theme.disabledColor,
    );
  }
}

/// Einstellungen untereinander, jeweils durch eine Linie getrennt.
class SettingsGroup extends StatelessWidget {
  const SettingsGroup({super.key, required this.children});

  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    final visible = children.whereType<Widget>().toList();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        for (var i = 0; i < visible.length; i++) ...[
          if (i > 0) const Divider(height: 1),
          visible[i],
        ],
      ],
    );
  }
}

/// Eine Einstellung in einer Zeile: Titel (und Untertitel) links, Wert oder
/// Bedienelement rechts.
class SettingsTile extends StatelessWidget {
  const SettingsTile({
    super.key,
    required this.title,
    this.subtitle,
    this.leading,
    this.trailing,
    this.onTap,
    this.enabled = true,
  });

  final String title;
  final String? subtitle;
  final Widget? leading;
  final Widget? trailing;
  final VoidCallback? onTap;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: enabled ? onTap : null,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 11),
        child: Row(
          children: [
            if (leading != null) ...[
              IconTheme.merge(
                data: IconThemeData(
                  size: 22,
                  color: Theme.of(context).colorScheme.primary,
                ),
                child: leading!,
              ),
              const SizedBox(width: 14),
            ],
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: SettingsTextStyles.title(context, enabled: enabled),
                  ),
                  if (subtitle != null) ...[
                    const SizedBox(height: 2),
                    Text(
                      subtitle!,
                      style: SettingsTextStyles.subtitle(context),
                    ),
                  ],
                ],
              ),
            ),
            // Bedienelemente bleiben flach, damit alle Zeilen gleich hoch
            // sind wie reine Textzeilen.
            if (trailing != null) ...[
              const SizedBox(width: 12),
              SizedBox(height: 26, child: Center(child: trailing!)),
            ],
          ],
        ),
      ),
    );
  }
}

class SettingsSwitchTile extends StatelessWidget {
  const SettingsSwitchTile({
    super.key,
    required this.title,
    required this.value,
    required this.onChanged,
    this.subtitle,
    this.leading,
  });

  final String title;
  final String? subtitle;
  final Widget? leading;
  final bool value;

  /// `null` deaktiviert den Schalter (z. B. für Mitglieder).
  final ValueChanged<bool>? onChanged;

  @override
  Widget build(BuildContext context) {
    return SettingsTile(
      leading: leading,
      title: title,
      subtitle: subtitle,
      enabled: onChanged != null,
      onTap: onChanged == null ? null : () => onChanged!(!value),
      trailing: Transform.scale(
        scale: 0.8,
        child: Switch(
          value: value,
          onChanged: onChanged,
          materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
        ),
      ),
    );
  }
}

/// Auswahl aus festen Werten; der aktuelle Wert steht rechts in einem
/// umrandeten Feld und öffnet beim Antippen die Liste.
class SettingsChoiceTile<T> extends StatelessWidget {
  const SettingsChoiceTile({
    super.key,
    required this.title,
    required this.value,
    required this.options,
    required this.onChanged,
    this.subtitle,
    this.leading,
  });

  final String title;
  final String? subtitle;
  final Widget? leading;
  final T value;
  final List<MapEntry<T, String>> options;
  final ValueChanged<T>? onChanged;

  @override
  Widget build(BuildContext context) {
    final enabled = onChanged != null;
    return SettingsTile(
      leading: leading,
      title: title,
      subtitle: subtitle,
      enabled: enabled,
      trailing: SettingsDropdown<T>(
        value: value,
        options: options,
        onChanged: onChanged,
      ),
    );
  }
}

/// Wert einer Einstellung direkt in der Zeile: normaler Text und ein
/// kleiner Pfeil; ein Tippen öffnet die Auswahl.
class SettingsDropdown<T> extends StatelessWidget {
  const SettingsDropdown({
    super.key,
    required this.value,
    required this.options,
    required this.onChanged,
    this.maxWidth = 180,
  });

  final T value;
  final List<MapEntry<T, String>> options;
  final ValueChanged<T>? onChanged;
  final double maxWidth;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final enabled = onChanged != null;
    final selected = options.any((option) => option.key == value)
        ? value
        : options.first.key;
    final valueStyle = theme.textTheme.bodyMedium?.copyWith(
      color: enabled
          ? theme.colorScheme.onSurface.withValues(alpha: 0.8)
          : theme.disabledColor,
    );
    // DropdownButton wäre sonst so breit wie der längste Eintrag und liefe
    // über (z. B. „Systemsprache“). Darum: so breit wie der gewählte Wert
    // (höchstens maxWidth, sonst „…“); das Menü darf breiter sein.
    double textWidth(String text) {
      final painter = TextPainter(
        text: TextSpan(text: text, style: valueStyle),
        maxLines: 1,
        textDirection: Directionality.of(context),
        textScaler: MediaQuery.textScalerOf(context),
      )..layout();
      return painter.width;
    }

    const iconWidth = 26.0;
    final selectedLabel = options.firstWhere((o) => o.key == selected).value;
    final width = (textWidth(selectedLabel) + iconWidth + 2).clamp(
      0.0,
      maxWidth,
    );
    final widest = options.fold<double>(
      0,
      (w, o) => textWidth(o.value) > w ? textWidth(o.value) : w,
    );
    return SizedBox(
      width: width,
      child: DropdownButtonHideUnderline(
        child: DropdownButton<T>(
          value: selected,
          isDense: true,
          isExpanded: true,
          menuWidth: (widest + 56).clamp(width, 320.0),
          borderRadius: AppDropdownStyle.radius,
          dropdownColor: AppDropdownStyle.menuColor(context),
          alignment: AlignmentDirectional.centerEnd,
          icon: Icon(
            Icons.unfold_more_rounded,
            size: 18,
            color: enabled ? theme.colorScheme.primary : theme.disabledColor,
          ),
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
                child: Text(
                  option.value,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.onSurface,
                  ),
                ),
              ),
          ],
          onChanged: enabled
              ? (value) {
                  if (value != null) onChanged!(value);
                }
              : null,
        ),
      ),
    );
  }
}

/// Einstellung mit größerem Bedienelement darunter (z. B. Schieberegler,
/// Farbauswahl oder mehrere Felder nebeneinander).
class SettingsBlock extends StatelessWidget {
  const SettingsBlock({
    super.key,
    required this.title,
    required this.child,
    this.subtitle,
    this.value,
    this.enabled = true,
  });

  final String title;
  final String? subtitle;
  final Widget child;
  final bool enabled;

  /// Aktueller Wert rechts neben dem Titel (z. B. bei Schiebereglern).
  final String? value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  title,
                  style: SettingsTextStyles.title(context, enabled: enabled),
                ),
              ),
              if (value != null)
                Text(
                  value!,
                  style: SettingsTextStyles.value(context, enabled: enabled),
                ),
            ],
          ),
          if (subtitle != null) ...[
            const SizedBox(height: 2),
            Text(subtitle!, style: SettingsTextStyles.subtitle(context)),
          ],
          const SizedBox(height: 10),
          child,
        ],
      ),
    );
  }
}

/// Eintrag einer Liste in den Einstellungen (Attribute, Formationen,
/// Positionen): umrandeter Kasten mit Symbol, Titel und Aktionen.
///
/// Bewusst kein [ListTile]: das reserviert links und rechts feste Breiten,
/// wodurch der Titel unnötig umbricht. Hier bekommt der Titel allen Platz,
/// der nach Symbol und Aktionen übrig bleibt.
class SettingsListItem extends StatelessWidget {
  const SettingsListItem({
    super.key,
    required this.title,
    this.subtitle,
    this.leading,
    this.trailing,
  });

  final Widget title;
  final Widget? subtitle;
  final Widget? leading;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 3),
      padding: const EdgeInsets.fromLTRB(10, 8, 12, 8),
      constraints: const BoxConstraints(minHeight: 52),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: theme.colorScheme.primary, width: 1),
      ),
      child: Row(
        children: [
          if (leading != null) ...[leading!, const SizedBox(width: 10)],
          Expanded(
            child: DefaultTextStyle.merge(
              style: theme.textTheme.bodyMedium,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  title,
                  if (subtitle != null) ...[
                    const SizedBox(height: 2),
                    DefaultTextStyle.merge(
                      style: SettingsTextStyles.subtitle(context),
                      child: subtitle!,
                    ),
                  ],
                ],
              ),
            ),
          ),
          if (trailing != null) ...[const SizedBox(width: 4), trailing!],
        ],
      ),
    );
  }
}

/// Kompakte Aktion (Bearbeiten, Löschen, …) rechts in einem
/// [SettingsListItem]: ohne den großen Standardabstand eines [IconButton].
class SettingsListAction extends StatelessWidget {
  const SettingsListAction({
    super.key,
    required this.icon,
    required this.onPressed,
    this.color,
    this.tooltip,
  });

  final IconData icon;
  final VoidCallback? onPressed;
  final Color? color;
  final String? tooltip;

  @override
  Widget build(BuildContext context) {
    return IconButton(
      tooltip: tooltip,
      onPressed: onPressed,
      // Gleiche Proportionen wie die Aktionen in der Spielkarte.
      icon: Icon(icon, size: 18, color: color),
      padding: const EdgeInsets.all(6),
      visualDensity: VisualDensity.compact,
      constraints: const BoxConstraints.tightFor(width: 30, height: 30),
      style: IconButton.styleFrom(
        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
      ),
    );
  }
}

/// Mehrere [SettingsListAction]s eng nebeneinander.
class SettingsListActions extends StatelessWidget {
  const SettingsListActions({super.key, required this.children});

  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Row(mainAxisSize: MainAxisSize.min, children: children);
  }
}

/// Rundes Symbol vorn in einem [SettingsListItem].
class SettingsListIcon extends StatelessWidget {
  const SettingsListIcon({super.key, this.icon, this.text});

  final IconData? icon;
  final String? text;

  @override
  Widget build(BuildContext context) {
    final primary = Theme.of(context).colorScheme.primary;
    return CircleAvatar(
      radius: 17,
      backgroundColor: primary.withValues(alpha: 0.1),
      child: icon != null
          ? Icon(icon, size: 20, color: primary)
          : Text(
              text ?? '',
              style: TextStyle(
                color: primary,
                fontWeight: FontWeight.w800,
                fontSize: 12,
              ),
            ),
    );
  }
}
