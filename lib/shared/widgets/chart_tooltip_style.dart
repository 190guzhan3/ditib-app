import 'package:flutter/material.dart';

/// Einheitliches Aussehen der Diagramm-Tooltips: etwas heller als die Karte
/// (im Darkmode sonst kaum abgegrenzt), runde Ecken, feiner Rand und eine
/// feste Höchstbreite. Die Diagramme halten die Tooltips zusätzlich im
/// sichtbaren Bereich (`fitInsideHorizontally/Vertically`).
abstract final class ChartTooltipStyle {
  static Color background(ThemeData theme) {
    final surface = theme.colorScheme.surface;
    return theme.brightness == Brightness.dark
        ? Color.lerp(surface, Colors.white, 0.12)!
        : surface;
  }

  static BorderSide border(ThemeData theme) =>
      BorderSide(color: theme.dividerColor.withValues(alpha: 0.35));

  static const radius = BorderRadius.all(Radius.circular(10));
  static const padding = EdgeInsets.symmetric(horizontal: 10, vertical: 8);
  static const maxWidth = 220.0;
  static const margin = 10.0;

  /// Erste Zeile (z. B. Name), in der Farbe des Eintrags.
  static TextStyle title(Color color) =>
      TextStyle(color: color, fontWeight: FontWeight.w700, fontSize: 12);

  /// Weitere Zeilen (Werte), zurückhaltend.
  static TextStyle body(ThemeData theme) => TextStyle(
    color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
    fontWeight: FontWeight.w500,
    fontSize: 11,
    height: 1.35,
  );
}
