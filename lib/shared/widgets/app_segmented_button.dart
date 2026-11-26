import 'package:flutter/material.dart';
import 'package:moschee_app/shared/widgets/hyphenated_text.dart';

/// Einheitliche Auswahlknöpfe (2–4 Optionen nebeneinander).
///
/// Nimmt die volle Breite ein und teilt sie gleichmäßig. Beschriftungen
/// stehen mittig und dürfen auf zwei Zeilen umbrechen; der Innenabstand ist
/// so gewählt, dass ein- und zweizeilige Knöpfe gleich aussehen.
class AppSegmentedButton<T> extends StatelessWidget {
  const AppSegmentedButton({
    super.key,
    required this.segments,
    required this.selected,
    this.onSelectionChanged,
    this.emptySelectionAllowed = false,
    this.style,
  });

  final List<ButtonSegment<T>> segments;
  final Set<T> selected;
  final ValueChanged<Set<T>>? onSelectionChanged;
  final bool emptySelectionAllowed;

  /// Abweichende Farben (z. B. gefüllte Knöpfe auf einer Karte).
  final ButtonStyle? style;

  /// Beschriftung eines Segments: mittig, höchstens zwei Zeilen, lange
  /// Wörter mit Silbentrennung statt mitten im Wort umbrochen.
  static Widget label(String text, {TextStyle? style}) =>
      _SegmentLabel(text, style: style);

  static const _hPadding = 8.0;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        // Platz für die Beschriftung je Segment (ohne Rand, Innenabstand
        // und ggf. Symbol).
        final width = constraints.maxWidth.isFinite
            ? constraints.maxWidth / segments.length - 2 * _hPadding - 2
            : null;
        return _SegmentLabelWidth(width: width, child: _buildButton());
      },
    );
  }

  Widget _buildButton() {
    return SegmentedButton<T>(
      segments: segments,
      selected: selected,
      onSelectionChanged: onSelectionChanged,
      emptySelectionAllowed: emptySelectionAllowed,
      showSelectedIcon: false,
      expandedInsets: EdgeInsets.zero,
      style: const ButtonStyle(
        visualDensity: VisualDensity.standard,
        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
        minimumSize: WidgetStatePropertyAll(Size(0, 44)),
        padding: WidgetStatePropertyAll(
          EdgeInsets.symmetric(horizontal: _hPadding, vertical: 8),
        ),
      ).merge(style),
    );
  }
}

class _SegmentLabelWidth extends InheritedWidget {
  const _SegmentLabelWidth({required this.width, required super.child});

  final double? width;

  @override
  bool updateShouldNotify(_SegmentLabelWidth oldWidget) =>
      oldWidget.width != width;
}

class _SegmentLabel extends StatelessWidget {
  const _SegmentLabel(this.text, {this.style});

  final String text;
  final TextStyle? style;

  @override
  Widget build(BuildContext context) {
    final width = context
        .dependOnInheritedWidgetOfExactType<_SegmentLabelWidth>()
        ?.width;
    final effective = DefaultTextStyle.of(context).style.merge(style);
    if (width == null || width <= 0) {
      return Text(
        text,
        textAlign: TextAlign.center,
        maxLines: 2,
        overflow: TextOverflow.ellipsis,
        style: style,
      );
    }
    // Ein einzelnes Wort, das nur knapp nicht passt („Unentschieden“),
    // wird etwas kleiner statt getrennt.
    if (!text.contains(' ')) {
      final painter = TextPainter(
        text: TextSpan(text: text, style: effective),
        textDirection: Directionality.of(context),
        textScaler: MediaQuery.textScalerOf(context),
        maxLines: 1,
      )..layout();
      if (painter.width > width && painter.width * 0.8 <= width) {
        return FittedBox(
          fit: BoxFit.scaleDown,
          child: Text(text, maxLines: 1, style: effective),
        );
      }
    }
    return HyphenatedText(
      text,
      style: effective,
      maxLines: 2,
      maxWidth: width,
      textAlign: TextAlign.center,
    );
  }
}
