import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:moschee_app/core/theme/theme.dart';
import 'package:moschee_app/shared/widgets/hyphenated_text.dart';
import 'package:moschee_app/shared/widgets/settings_tiles.dart';

/// Rahmen der Datentabellen (Spieler, Attribute, Teams).
class AppDataTable extends StatelessWidget {
  final Widget child;

  const AppDataTable({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Material(
      color: theme.colorScheme.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: theme.dividerColor.withValues(alpha: 0.12)),
      ),
      clipBehavior: Clip.antiAlias,
      child: child,
    );
  }
}

/// Eine Spalte von [AppTable].
class AppTableColumn {
  const AppTableColumn({
    required this.label,
    this.sortKey,
    this.isName = false,
    this.minWidth = 0,
    this.mergeGroup,
  });

  /// Kopfzeile (wird in Großbuchstaben gezeigt).
  final String label;

  /// Antippen des Kopfes sortiert nach diesem Schlüssel.
  final String? sortKey;

  /// Die Namensspalte bekommt den restlichen Platz und darf umbrechen.
  final bool isName;

  /// Mindestbreite des Inhalts, z. B. für Schalter.
  final double minWidth;

  /// Benachbarte Spalten mit gleicher Gruppe werden zu einer Spalte
  /// zusammengefasst („S-U-N“ statt „S“, „U“, „N“), wenn die Tabelle sonst
  /// nicht passt.
  final String? mergeGroup;

  /// Trennzeichen zwischen den Werten zusammengefasster Spalten.
  static const mergeSeparator = '-';
}

/// Eine Zelle: Text oder ein eigenes Widget (dann zählt [text] nur fürs
/// Messen und für die gestapelte Ansicht).
class AppTableCell {
  const AppTableCell(this.text, {this.color, this.bold = false, this.child});

  final String text;
  final Color? color;
  final bool bold;
  final Widget? child;
}

/// Eine Zeile von [AppTable].
class AppTableRow {
  const AppTableRow({
    required this.cells,
    this.mine = false,
    this.highlighted = false,
    this.accent,
    this.key,
    this.onTap,
  }) : section = null;

  /// Trennzeile mit Beschriftung (z. B. „Unter 5 Spielen“).
  const AppTableRow.section(String label)
    : section = label,
      cells = const [],
      mine = false,
      highlighted = false,
      accent = null,
      key = null,
      onTap = null;

  final List<AppTableCell> cells;
  final bool mine;
  final bool highlighted;

  /// Farbiger Streifen am linken Rand (z. B. Rangfarbe).
  final Color? accent;
  final Key? key;
  final String? section;

  /// Antippen der ganzen Zeile (z. B. Details öffnen).
  final VoidCallback? onTap;
}

/// Einheitliche Datentabelle.
///
/// Die Spaltenbreiten richten sich nach dem Inhalt, damit keine Zahl
/// abgeschnitten wird. Die Namensspalte bekommt genau so viel Platz, wie der
/// längste Name braucht (bei gleichen Spielern also in jeder Tabelle gleich
/// breit); was übrig bleibt, verteilt sich auf die Wertespalten. Reicht die
/// Breite nicht, werden zuerst Spalten einer [AppTableColumn.mergeGroup]
/// zusammengefasst; passt es dann immer noch nicht, scrollt die Tabelle
/// seitlich. Sie bleibt also immer eine Tabelle.
class AppTable extends StatelessWidget {
  const AppTable({
    super.key,
    required this.columns,
    required this.rows,
    this.sortKey,
    this.ascending = false,
    this.onSort,
    this.scrollWhenTooWide = false,
  });

  final List<AppTableColumn> columns;
  final List<AppTableRow> rows;

  /// Aktuelle Sortierung; die Spalte wird hervorgehoben.
  final String? sortKey;
  final bool ascending;
  final ValueChanged<String>? onSort;

  /// Passt die Tabelle nicht, sofort seitlich scrollen (ohne Spalten
  /// zusammenzufassen). Die Spalten stehen dann in voller Breite.
  final bool scrollWhenTooWide;

  static const _hPad = 5.0;

  /// Erste Spalte: Platz für den farbigen Streifen am Zeilenrand.
  static const _firstPad = 10.0;
  static const _arrowSpace = 14.0;
  static const _minName = 72.0;

  static TextStyle headerStyle(ThemeData theme) =>
      AppTypography.caption.copyWith(
        fontWeight: FontWeight.w700,
        letterSpacing: 0.5,
        color: theme.colorScheme.onSurface.withValues(alpha: 0.55),
      );

  static TextStyle cellStyle(ThemeData theme, {bool bold = false}) =>
      (theme.textTheme.bodyMedium ?? const TextStyle()).copyWith(
        fontWeight: bold ? FontWeight.w700 : FontWeight.w400,
        fontFeatures: const [FontFeature.tabularFigures()],
      );

  double _measure(BuildContext context, String text, TextStyle style) {
    final painter = TextPainter(
      text: TextSpan(text: text, style: style),
      textDirection: TextDirection.ltr,
      textScaler: MediaQuery.textScalerOf(context),
      maxLines: 1,
    )..layout();
    return painter.width;
  }

  /// Breite des längsten Wortes (Text darf an Leerzeichen umbrechen).
  double _longestWord(BuildContext context, String text, TextStyle style) {
    var widest = 0.0;
    for (final word in text.split(RegExp(r'\s+'))) {
      widest = math.max(widest, _measure(context, word, style));
    }
    return widest;
  }

  /// Breiten je Spalte. Ist das Ergebnis breiter als [maxWidth], passt die
  /// Tabelle nicht (dann sind es die Wunschbreiten fürs Scrollen).
  ///
  /// Jede Spalte hat eine Mindestbreite (längstes Wort; lange Überschriften
  /// werden getrennt) und eine Wunschbreite (alles in einer Zeile). Passen
  /// alle Wunschbreiten, gibt es keine Umbrüche; sonst wachsen die Spalten
  /// vom Minimum aus anteilig.
  List<double> _layout(
    BuildContext context,
    List<AppTableColumn> columns,
    List<AppTableRow> rows,
    double maxWidth,
  ) {
    final theme = Theme.of(context);
    final header = headerStyle(theme);
    final bold = cellStyle(theme, bold: true);
    final dataRows = rows.where((row) => row.section == null).toList();
    final mins = <double>[];
    final prefs = <double>[];
    var nameIndex = -1;
    for (var c = 0; c < columns.length; c++) {
      final column = columns[c];
      final label = column.label.toUpperCase();
      final arrow = column.sortKey != null ? _arrowSpace : 0.0;
      var pref = _measure(context, label, header) + arrow;
      // Lange Überschriften dürfen getrennt auf zwei Zeilen stehen.
      var min =
          math.max(
            _longestWord(context, label, header) * 0.6,
            _measure(
              context,
              label.length > 3 ? label.substring(0, 3) : label,
              header,
            ),
          ) +
          arrow;
      for (final row in dataRows) {
        if (c >= row.cells.length) continue;
        final text = row.cells[c].text;
        pref = math.max(pref, _measure(context, text, bold));
        min = math.max(min, _longestWord(context, text, bold));
      }
      final pad = c == 0 ? _firstPad + _hPad : 2 * _hPad;
      pref = (math.max(pref, column.minWidth) + pad).ceilToDouble();
      min = (math.max(min, column.minWidth) + pad).ceilToDouble();
      if (column.isName) {
        // Namen umbrechen notfalls auch im Wort; es reicht die feste
        // Mindestbreite.
        nameIndex = c;
        min = math.min(_minName, pref);
      }
      mins.add(math.min(min, pref));
      prefs.add(pref);
    }
    final minTotal = mins.fold<double>(0, (sum, w) => sum + w);
    if (minTotal > maxWidth) return prefs;
    final prefTotal = prefs.fold<double>(0, (sum, w) => sum + w);

    if (prefTotal <= maxWidth) {
      // Alles passt: übrigen Platz auf die Wertespalten (nicht „#“, nicht
      // den Namen, damit Namensspalten in allen Tabellen gleich breit sind).
      final widths = List.of(prefs);
      final spread = [
        for (var c = 1; c < columns.length; c++)
          if (c != nameIndex) c,
      ];
      final extra = maxWidth - prefTotal;
      if (spread.isEmpty) {
        widths[nameIndex < 0 ? widths.length - 1 : nameIndex] += extra;
      } else {
        for (final c in spread) {
          widths[c] += extra / spread.length;
        }
      }
      return widths;
    }

    // Zu eng für alles in einer Zeile: vom Minimum aus anteilig wachsen.
    final widths = List.of(mins);
    final room = maxWidth - minTotal;
    final want = prefTotal - minTotal;
    for (var c = 0; c < widths.length; c++) {
      widths[c] += (prefs[c] - mins[c]) * room / want;
    }
    return widths;
  }

  bool get _hasMergeGroups => columns.any((c) => c.mergeGroup != null);

  /// Spalten gleicher [AppTableColumn.mergeGroup] zu einer zusammenfassen.
  (List<AppTableColumn>, List<AppTableRow>) _merged() {
    const sep = AppTableColumn.mergeSeparator;
    final spans = <List<int>>[];
    for (var c = 0; c < columns.length; c++) {
      final group = columns[c].mergeGroup;
      if (group != null && spans.isNotEmpty) {
        final last = spans.last;
        if (columns[last.first].mergeGroup == group && last.last == c - 1) {
          last.add(c);
          continue;
        }
      }
      spans.add([c]);
    }
    final mergedColumns = [
      for (final span in spans)
        span.length == 1
            ? columns[span.first]
            : AppTableColumn(
                label: span.map((c) => columns[c].label).join(sep),
              ),
    ];
    final mergedRows = [
      for (final row in rows)
        if (row.section != null)
          row
        else
          AppTableRow(
            key: row.key,
            mine: row.mine,
            highlighted: row.highlighted,
            accent: row.accent,
            onTap: row.onTap,
            cells: [
              for (final span in spans)
                span.length == 1
                    ? row.cells[span.first]
                    : AppTableCell(
                        span.map((c) => row.cells[c].text).join(sep),
                        color: row.cells[span.first].color,
                      ),
            ],
          ),
    ];
    return (mergedColumns, mergedRows);
  }

  /// Mit [AppTableRow.onTap] reagiert die ganze Zeile auf Antippen.
  static Widget _tappable(AppTableRow row, Widget cell) =>
      row.onTap == null ? cell : TableRowInkWell(onTap: row.onTap, child: cell);

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final maxWidth = constraints.maxWidth;
        var shownColumns = columns;
        var shownRows = rows;
        var widths = _layout(context, shownColumns, shownRows, maxWidth);
        double total() => widths.fold<double>(0, (sum, w) => sum + w);
        if (total() > maxWidth + 0.5 && !scrollWhenTooWide && _hasMergeGroups) {
          (shownColumns, shownRows) = _merged();
          widths = _layout(context, shownColumns, shownRows, maxWidth);
        }
        final table = _table(context, shownColumns, shownRows, widths);
        if (total() <= maxWidth + 0.5) return AppDataTable(child: table);
        return AppDataTable(
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: SizedBox(width: total(), child: table),
          ),
        );
      },
    );
  }

  BoxDecoration _rowDecoration(ThemeData theme, AppTableRow row, int index) {
    return BoxDecoration(
      color: row.highlighted
          ? theme.colorScheme.primary.withValues(alpha: 0.2)
          : row.mine
          ? AppHighlight.ownFill(theme, on: theme.colorScheme.surface)
          : (index.isOdd
                ? theme.colorScheme.onSurface.withValues(alpha: 0.025)
                : null),
      border: Border(
        top: BorderSide(color: theme.dividerColor.withValues(alpha: 0.08)),
        left: row.highlighted
            ? BorderSide(color: theme.colorScheme.primary, width: 4)
            : row.accent != null
            ? BorderSide(color: row.accent!, width: 4)
            : BorderSide.none,
      ),
    );
  }

  static EdgeInsets _pad(int column, double vertical) => EdgeInsets.fromLTRB(
    column == 0 ? _firstPad : _hPad,
    vertical,
    _hPad,
    vertical,
  );

  Widget _header(
    BuildContext context,
    AppTableColumn column,
    int index,
    double width,
  ) {
    final theme = Theme.of(context);
    final active = column.sortKey != null && column.sortKey == sortKey;
    final style = headerStyle(
      theme,
    ).copyWith(color: active ? theme.colorScheme.primary : null);
    final align = column.isName
        ? MainAxisAlignment.start
        : MainAxisAlignment.center;
    final textWidth =
        width -
        (index == 0 ? _firstPad + _hPad : 2 * _hPad) -
        (active ? _arrowSpace : 0);
    final content = Padding(
      padding: _pad(index, 10),
      child: Row(
        mainAxisAlignment: align,
        children: [
          Flexible(
            child: HyphenatedText(
              column.label.toUpperCase(),
              style: style,
              maxLines: 2,
              maxWidth: textWidth,
              textAlign: column.isName ? TextAlign.left : TextAlign.center,
            ),
          ),
          if (active)
            Icon(
              ascending ? Icons.arrow_upward : Icons.arrow_downward,
              size: 12,
              color: theme.colorScheme.primary,
            ),
        ],
      ),
    );
    if (column.sortKey == null || onSort == null) return content;
    return InkWell(onTap: () => onSort!(column.sortKey!), child: content);
  }

  Widget _cell(
    BuildContext context,
    AppTableColumn column,
    AppTableCell cell,
    int index,
  ) {
    final theme = Theme.of(context);
    // Werte der sortierten Spalte hervorheben; Namen bleiben ruhig.
    final active =
        !column.isName && column.sortKey != null && column.sortKey == sortKey;
    final child =
        cell.child ??
        Text(
          cell.text,
          textAlign: column.isName ? TextAlign.left : TextAlign.center,
          // Texte dürfen an Leerzeichen umbrechen; Zahlen passen immer.
          maxLines: 2,
          softWrap: true,
          style: cellStyle(theme, bold: cell.bold || active).copyWith(
            color: cell.color ?? (active ? theme.colorScheme.primary : null),
          ),
        );
    return Padding(
      padding: _pad(index, 11),
      child: Align(
        alignment: column.isName ? Alignment.centerLeft : Alignment.center,
        child: child,
      ),
    );
  }

  Widget _table(
    BuildContext context,
    List<AppTableColumn> columns,
    List<AppTableRow> rows,
    List<double> widths,
  ) {
    final theme = Theme.of(context);
    final nameIndex = columns.indexWhere((c) => c.isName);
    var dataIndex = 0;
    return Table(
      columnWidths: {
        for (var c = 0; c < widths.length; c++) c: FixedColumnWidth(widths[c]),
      },
      defaultVerticalAlignment: TableCellVerticalAlignment.middle,
      children: [
        TableRow(
          children: [
            for (var c = 0; c < columns.length; c++)
              _header(context, columns[c], c, widths[c]),
          ],
        ),
        for (final row in rows)
          if (row.section != null)
            TableRow(
              decoration: BoxDecoration(
                color: theme.colorScheme.onSurface.withValues(alpha: 0.04),
                border: Border(
                  top: BorderSide(
                    color: theme.dividerColor.withValues(alpha: 0.08),
                  ),
                ),
              ),
              children: [
                for (var c = 0; c < columns.length; c++)
                  c == math.max(nameIndex, 0)
                      ? Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: _hPad,
                            vertical: 8,
                          ),
                          child: Text(
                            row.section!.toUpperCase(),
                            softWrap: false,
                            overflow: TextOverflow.visible,
                            style: headerStyle(theme),
                          ),
                        )
                      : const SizedBox.shrink(),
              ],
            )
          else
            TableRow(
              decoration: _rowDecoration(theme, row, dataIndex++),
              children: [
                for (var c = 0; c < columns.length; c++)
                  _tappable(
                    row,
                    // Schlüssel (z. B. zum Hinscrollen) an der ersten Zelle.
                    c == 0 && row.key != null
                        ? KeyedSubtree(
                            key: row.key,
                            child: _cell(context, columns[c], row.cells[c], c),
                          )
                        : _cell(context, columns[c], row.cells[c], c),
                  ),
              ],
            ),
      ],
    );
  }
}

/// Einheitliche Leiste über den Tabellen: links ein Filter (z. B.
/// Zeitraum), rechts die Sortierung mit ausgeschriebenen Namen und die
/// Richtung.
class AppTableToolbar<F, S> extends StatelessWidget {
  const AppTableToolbar({
    super.key,
    this.filterValue,
    this.filterOptions = const [],
    this.onFilterChanged,
    this.filterIcon = Icons.filter_list_rounded,
    required this.sortValue,
    required this.sortOptions,
    required this.onSortChanged,
    required this.ascending,
    required this.onDirectionChanged,
    this.directionTooltip,
    this.trailing,
    this.leading,
  });

  final F? filterValue;
  final List<MapEntry<F, String>> filterOptions;
  final ValueChanged<F>? onFilterChanged;
  final IconData filterIcon;
  final S sortValue;
  final List<MapEntry<S, String>> sortOptions;
  final ValueChanged<S> onSortChanged;
  final bool ascending;
  final VoidCallback onDirectionChanged;
  final String? directionTooltip;

  /// Z. B. ein Zahnrad zu den Tabellen-Einstellungen.
  final Widget? trailing;

  /// Links statt eines Filters, z. B. die Überschrift der Tabelle.
  final Widget? leading;

  @override
  Widget build(BuildContext context) {
    // Links der Filter, rechts Sortierung und Richtung. Der Filter darf
    // schrumpfen, die Sortierung behält ihre Breite.
    return Row(
      children: [
        if (filterOptions.isNotEmpty && onFilterChanged != null)
          Flexible(
            child: Align(
              alignment: Alignment.centerLeft,
              child: AppPillMenu<F>(
                icon: filterIcon,
                value: filterValue as F,
                options: filterOptions,
                onChanged: onFilterChanged!,
              ),
            ),
          )
        else if (leading != null)
          Expanded(child: leading!)
        else
          const Spacer(),
        const SizedBox(width: 8),
        AppPillMenu<S>(
          icon: Icons.sort_rounded,
          value: sortValue,
          options: sortOptions,
          onChanged: onSortChanged,
        ),
        const SizedBox(width: 6),
        AppToolbarIconButton(
          icon: ascending ? Icons.arrow_upward : Icons.arrow_downward,
          tooltip: directionTooltip,
          onPressed: onDirectionChanged,
        ),
        if (trailing != null) ...[const SizedBox(width: 6), trailing!],
      ],
    );
  }
}

/// Runder Knopf in Tabellen-Leisten, so hoch wie die Pillen daneben
/// (z. B. Sortierrichtung, Tabellen-Einstellungen).
class AppToolbarIconButton extends StatelessWidget {
  const AppToolbarIconButton({
    super.key,
    required this.icon,
    required this.onPressed,
    this.tooltip,
  });

  final IconData icon;
  final VoidCallback onPressed;
  final String? tooltip;

  @override
  Widget build(BuildContext context) {
    final primary = Theme.of(context).colorScheme.primary;
    return Tooltip(
      message: tooltip ?? '',
      child: InkWell(
        borderRadius: BorderRadius.circular(20),
        onTap: onPressed,
        child: Container(
          padding: const EdgeInsets.all(7),
          decoration: BoxDecoration(
            color: primary.withValues(alpha: 0.12),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, size: 16, color: primary),
        ),
      ),
    );
  }
}

/// Kleine Pille mit Symbol, Wert und Pfeil; Tippen öffnet die Auswahl.
class AppPillMenu<T> extends StatelessWidget {
  const AppPillMenu({
    super.key,
    required this.value,
    required this.options,
    required this.onChanged,
    this.icon,
    this.sectionHeaders = const {},
  });

  final T value;
  final List<MapEntry<T, String>> options;
  final ValueChanged<T> onChanged;
  final IconData? icon;

  /// Überschrift vor einer Option (Schlüssel = erste Option des Abschnitts).
  final Map<T, String> sectionHeaders;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final primary = theme.colorScheme.primary;
    final selected = options.firstWhere(
      (option) => option.key == value,
      orElse: () => options.first,
    );
    return PopupMenuButton<T>(
      // Mit Überschriften oben beginnen (sonst scrollt das Menü zur Auswahl
      // und die erste Überschrift ist nicht zu sehen).
      initialValue: sectionHeaders.isEmpty ? selected.key : null,
      tooltip: '',
      color: AppDropdownStyle.menuColor(context),
      shape: const RoundedRectangleBorder(
        borderRadius: AppDropdownStyle.radius,
      ),
      position: PopupMenuPosition.under,
      constraints: const BoxConstraints(maxHeight: 360),
      itemBuilder: (context) => [
        for (final option in options) ...[
          if (sectionHeaders[option.key] case final header?)
            PopupMenuItem<T>(
              enabled: false,
              height: 32,
              child: Text(
                header.toUpperCase(),
                style: theme.textTheme.labelSmall?.copyWith(
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.6,
                  color: theme.colorScheme.onSurface.withValues(alpha: 0.55),
                ),
              ),
            ),
          PopupMenuItem<T>(
            value: option.key,
            // Unter Überschriften eingerückt, damit Abschnitt und Werte
            // auseinanderzuhalten sind; die Auswahl ist fett.
            child: Padding(
              padding: EdgeInsets.only(left: sectionHeaders.isEmpty ? 0 : 14),
              child: Text(
                option.value,
                style: sectionHeaders.isNotEmpty && option.key == value
                    ? TextStyle(fontWeight: FontWeight.w700, color: primary)
                    : null,
              ),
            ),
          ),
        ],
      ],
      onSelected: onChanged,
      child: Container(
        padding: const EdgeInsets.fromLTRB(10, 6, 6, 6),
        decoration: BoxDecoration(
          color: primary.withValues(alpha: 0.12),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (icon != null) ...[
              Icon(icon, size: 16, color: primary),
              const SizedBox(width: 6),
            ],
            Flexible(
              child: Text(
                selected.value,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: primary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            Icon(Icons.expand_more, size: 16, color: primary),
          ],
        ),
      ),
    );
  }
}
